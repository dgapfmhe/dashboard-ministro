"""Laboratorio de pronósticos (t+1) con sentimiento de prensa.

UN solo motor para dos lugares:
  · navegador (Pyodide, Web Worker)   → pestaña "Laboratorio de Pronósticos"
  · GitHub Actions (CPython)          → pronósticos oficiales y su historial de aciertos

Entrada: dict `payload` (JSON-serializable). Salida: dict JSON-serializable.
Basado en prediccionesIPC.ipynb (SARIMAX(1,0,1)+ISEC, VAR, backtest expanding/rolling,
conversión m/m → interanual) y en el veredicto de la investigación: SIEMPRE se reporta
contra benchmarks simples (paseo aleatorio y AR) con Diebold-Mariano.
"""
from __future__ import annotations

import math
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")

FREQ_PD = {"M": "MS", "Q": "QS"}
PER_ANIO = {"M": 12, "Q": 4}

NOMBRES = {
    "rw": "Paseo aleatorio",
    "media": "Media histórica",
    "ar": "AR(p) automático",
    "arima": "ARIMA",
    "sarimax": "SARIMAX + exógenas",
    "arx": "Regresión ARX (MCO)",
    "var": "VAR",
}


# ══════════════════════════════════════════════════════════════════════════════
# 1. PREPARACIÓN DE DATOS
# ══════════════════════════════════════════════════════════════════════════════
def _serie(fechas, valores) -> pd.Series:
    s = pd.Series(pd.to_numeric(pd.Series(valores), errors="coerce").values,
                  index=pd.to_datetime(pd.Series(fechas)))
    s = s[~s.index.duplicated(keep="last")].sort_index()
    return s.dropna()


def a_frecuencia(s: pd.Series, freq: str, agregacion: str = "promedio") -> pd.Series:
    if s.empty:
        return s
    regla = "MS" if freq == "M" else "QS"
    r = s.resample(regla)
    out = {"promedio": r.mean, "ultimo": r.last, "suma": r.sum}[agregacion]()
    if agregacion == "suma":
        out = out.where(r.count() > 0)
    return out.dropna()


def transformar(s: pd.Series, t: str, freq: str) -> pd.Series:
    k = PER_ANIO[freq]
    if t == "nivel":
        return s
    if t == "pct_mm":      # % respecto al período anterior
        return (s / s.shift(1) - 1) * 100
    if t == "pct_aa":      # % interanual
        return (s / s.shift(k) - 1) * 100
    if t == "dif":
        return s.diff()
    if t == "dif_aa":
        return s.diff(k)
    if t == "logdif":
        return np.log(s).diff() * 100
    raise ValueError(f"transformación desconocida: {t}")


def preparar(p: dict) -> tuple[pd.DataFrame, pd.Series, pd.Timestamp, pd.Series, list[str], list[str]]:
    """→ (df muestra [y + X], X de t+1, fecha t+1, nivel original, nombres exógenas, avisos)"""
    freq = p.get("frecuencia", "M")
    avisos: list[str] = []
    ob = p["objetivo"]
    nivel = a_frecuencia(_serie(ob["fechas"], ob["valores"]), freq, ob.get("agregacion", "promedio"))
    y = transformar(nivel, p.get("transformacion", "nivel"), freq).rename("y")
    cols = {"y": y}
    nombres = []
    for ex in p.get("exogenas", []):
        s = a_frecuencia(_serie(ex["fechas"], ex["valores"]), freq, ex.get("agregacion", "promedio"))
        s = transformar(s, ex.get("transformacion", "nivel"), freq)
        rez = int(ex.get("rezago", 0))
        nombre = ex.get("nombre", ex["id"]) + (f" (t-{rez})" if rez else " (t)")
        cols[nombre] = s.shift(rez, freq=FREQ_PD[freq]) if rez else s
        nombres.append(nombre)
    df = pd.DataFrame(cols)
    desde = pd.Timestamp(p.get("desde", "2000-01-01"))
    df = df[df.index >= desde]
    ult_y = df["y"].last_valid_index()
    if ult_y is None:
        raise ValueError("La variable objetivo no tiene datos en la muestra elegida.")
    fecha_sig = ult_y + pd.tseries.frequencies.to_offset(FREQ_PD[freq])
    X_sig = pd.Series({n: (df[n].get(fecha_sig, np.nan) if fecha_sig in df.index else np.nan) for n in nombres}, dtype=float)
    for n in nombres:
        if np.isnan(X_sig.get(n, np.nan)):
            ultimo = df[n].loc[:ult_y].dropna()
            if len(ultimo):
                X_sig[n] = ultimo.iloc[-1]
                avisos.append(f"«{n}» aún no tiene dato para {fecha_sig:%Y-%m}: se usa su último valor (persistencia).")
    muestra = df.loc[:ult_y].dropna()
    if len(muestra) < 24:
        rangos = []
        for c in ["y"] + nombres:
            s = df[c].dropna()
            etq = "objetivo" if c == "y" else f"«{c}»"
            rangos.append(f"{etq}: {s.index[0]:%Y-%m}→{s.index[-1]:%Y-%m} ({len(s)})" if len(s) else f"{etq}: sin datos")
        raise ValueError(f"Muestra muy corta ({len(muestra)} períodos con todas las variables; mínimo 24). "
                         f"Datos disponibles — " + "; ".join(rangos))
    return muestra, X_sig, fecha_sig, nivel, nombres, avisos


# ══════════════════════════════════════════════════════════════════════════════
# 2. MODELOS — cada uno: ajustar(y, X) → objeto; predecir(obj, X_sig) → (media, sd)
# ══════════════════════════════════════════════════════════════════════════════
Z80, Z95 = 1.2815515655, 1.959963985


class Base:
    usa_exog = False
    def __init__(self, spec: dict, nombres: list[str]):
        self.spec, self.nombres = spec, nombres
        self.res = None
    def ajustar(self, y: pd.Series, X: pd.DataFrame | None): ...
    def actualizar(self, y: pd.Series, X: pd.DataFrame | None):
        """Re-estimación barata (mismos parámetros, datos nuevos). Por defecto, re-ajusta."""
        self.ajustar(y, X)
    def predecir(self, X_sig: pd.Series | None) -> tuple[float, float]: ...
    def coeficientes(self) -> list[dict]:
        return []
    def residuos(self) -> np.ndarray | None:
        return None


class RW(Base):
    def ajustar(self, y, X):
        self.y = y
        self.sd = float(np.nanstd(y.diff().dropna(), ddof=1)) if len(y) > 2 else float("nan")
    def predecir(self, X_sig):
        return float(self.y.iloc[-1]), self.sd


class Media(Base):
    def ajustar(self, y, X):
        self.mu, self.sd = float(y.mean()), float(y.std(ddof=1))
    def predecir(self, X_sig):
        return self.mu, self.sd


class AR(Base):
    def ajustar(self, y, X):
        from statsmodels.tsa.ar_model import AutoReg, ar_select_order
        pmax = int(self.spec.get("pmax", 6))
        p = self.spec.get("p", "auto")
        if p == "auto":
            sel = ar_select_order(y.values, maxlag=min(pmax, max(1, len(y) // 5)), ic="aic", trend="c")
            lags = sel.ar_lags or [1]
        else:
            lags = int(p)
        self.res = AutoReg(y.values, lags=lags, trend="c").fit()
        self.n = len(y)
    def predecir(self, X_sig):
        f = self.res.predict(start=self.n, end=self.n)
        return float(f[0]), float(np.sqrt(self.res.sigma2))
    def coeficientes(self):
        return _tabla_coef(self.res, None)
    def residuos(self):
        return self.res.resid


class SARIMAX_(Base):
    """ARIMA / SARIMAX (statsmodels SARIMAX). Exógenas opcionales."""
    def __init__(self, spec, nombres):
        super().__init__(spec, nombres)
        self.usa_exog = bool(spec.get("exog", spec["tipo"] == "sarimax")) and bool(nombres)
    def _orden(self):
        s = self.spec
        o = (int(s.get("p", 1)), int(s.get("d", 0)), int(s.get("q", 1)))
        so = (int(s.get("P", 0)), int(s.get("D", 0)), int(s.get("Q", 0)), int(s.get("s", 12)))
        return o, (so if any(so[:3]) else (0, 0, 0, 0))
    def ajustar(self, y, X):
        from statsmodels.tsa.statespace.sarimax import SARIMAX
        o, so = self._orden()
        tendencia = "c" if o[1] == 0 and so[1] == 0 else "n"
        self.mod = SARIMAX(y.values, exog=X.values if self.usa_exog else None, order=o,
                           seasonal_order=so, trend=tendencia,
                           enforce_stationarity=False, enforce_invertibility=False)
        self.res = self.mod.fit(disp=False, maxiter=200)
    def actualizar(self, y, X):
        # mismos parámetros, filtra con los datos nuevos (rápido)
        try:
            self.res = self.res.apply(y.values, exog=X.values if self.usa_exog else None)
        except Exception:
            self.ajustar(y, X)
    def predecir(self, X_sig):
        ex = X_sig.values.reshape(1, -1) if self.usa_exog else None
        f = self.res.get_forecast(steps=1, exog=ex)
        return float(f.predicted_mean[0]), float(np.sqrt(f.var_pred_mean[0]))
    def coeficientes(self):
        nombres = list(self.res.model.param_names)
        if self.usa_exog:
            nombres = [self.nombres[int(n[1:]) - 1] if n.startswith("x") and n[1:].isdigit() else n for n in nombres]
        return _tabla_coef(self.res, nombres)
    def residuos(self):
        return self.res.resid[max(1, int(self._orden()[0][1])):]


class ARX(Base):
    """y_t = c + Σ φ_i y_{t-i} + Σ β_j x_{j,t} + e_t  (MCO; exógenas con su rezago elegido)."""
    usa_exog = True
    def _diseno(self, y, X):
        p = int(self.spec.get("p", 2))
        D = pd.DataFrame({f"y(t-{i})": y.shift(i) for i in range(1, p + 1)})
        if X is not None and len(self.nombres):
            D = pd.concat([D, X], axis=1)
        return D
    def ajustar(self, y, X):
        import statsmodels.api as sm
        D = self._diseno(y, X)
        ok = D.notna().all(axis=1)
        self.res = sm.OLS(y[ok].values, sm.add_constant(D[ok].values, has_constant="add")).fit()
        self.cols = ["const"] + list(D.columns)
        self.y = y
    def predecir(self, X_sig):
        p = int(self.spec.get("p", 2))
        fila = [1.0] + [float(self.y.iloc[-i]) for i in range(1, p + 1)]
        if len(self.nombres):
            fila += [float(X_sig[n]) for n in self.nombres]
        fila = np.array(fila).reshape(1, -1)
        pr = self.res.get_prediction(fila)
        sd = float(np.sqrt(pr.var_pred_mean[0] + self.res.scale))
        return float(pr.predicted_mean[0]), sd
    def coeficientes(self):
        return _tabla_coef(self.res, self.cols)
    def residuos(self):
        return self.res.resid


class VAR_(Base):
    """VAR(p) con la objetivo + exógenas como endógenas (solo usa información rezagada)."""
    usa_exog = True
    def ajustar(self, y, X):
        from statsmodels.tsa.api import VAR
        D = pd.concat([y, X], axis=1) if X is not None else y.to_frame()
        self.D = D.values
        mod = VAR(self.D)
        p = self.spec.get("p", "auto")
        if p == "auto":
            sel = mod.select_order(maxlags=min(int(self.spec.get("pmax", 4)), max(1, len(D) // 10)))
            p = max(1, int(sel.selected_orders.get("aic") or 1))
        self.res = mod.fit(int(p))
        self.k = self.res.k_ar
        self.cols = ["y"] + list(X.columns if X is not None else [])
    def predecir(self, X_sig):
        f = self.res.forecast(self.D[-self.k:], steps=1)[0][0]
        sd = float(np.sqrt(self.res.forecast_cov(1)[0][0, 0]))
        return float(f), sd
    def coeficientes(self):
        import re
        out = []
        params, se, pv = self.res.params[:, 0], self.res.stderr[:, 0], self.res.pvalues[:, 0]
        nombres = list(getattr(self.res, "exog_names", None) or range(len(params)))
        def bonito(n):
            m = re.match(r"L(\d+)\.y(\d+)", str(n))
            if not m:
                return str(n)
            k = int(m.group(2)) - 1
            return f"{'y' if k == 0 else self.cols[k]} (t-{m.group(1)})"
        for nombre, b, s, pp in zip(nombres, params, se, pv):
            out.append({"nombre": bonito(nombre), "valor": _f(b), "ee": _f(s), "p": _f(pp)})
        return out
    def residuos(self):
        return self.res.resid[:, 0]


CLASES = {"rw": RW, "media": Media, "ar": AR, "arima": SARIMAX_, "sarimax": SARIMAX_, "arx": ARX, "var": VAR_}


# ══════════════════════════════════════════════════════════════════════════════
# 3. BACKTEST (1 paso adelante, fuera de muestra)
# ══════════════════════════════════════════════════════════════════════════════
def backtest(spec, nombres, df, cfg, progreso=None):
    y, X = df["y"], (df[nombres] if nombres else None)
    n = len(df)
    min_train = max(12, int(cfg.get("min_train", 36)))
    esquema = cfg.get("esquema", "expanding")
    ventana = int(cfg.get("ventana", 60))
    cada = max(1, int(cfg.get("reestimar_cada", 12)))
    fechas, pred, sd, real = [], [], [], []
    m = None
    for i, t in enumerate(range(min_train, n)):
        a = 0 if esquema == "expanding" else max(0, t - ventana)
        yt, Xt = y.iloc[a:t], (X.iloc[a:t] if X is not None else None)
        try:
            if m is None or i % cada == 0 or esquema == "rolling":
                m = CLASES[spec["tipo"]](spec, nombres)
                m.ajustar(yt, Xt)
            else:
                m.actualizar(yt, Xt)
            mu, s = m.predecir(X.iloc[t] if X is not None else None)
        except Exception:
            mu, s = np.nan, np.nan
        fechas.append(df.index[t]); pred.append(mu); sd.append(s); real.append(float(y.iloc[t]))
        if progreso and i % 10 == 0:
            progreso(i / max(1, n - min_train))
    return pd.DataFrame({"pred": pred, "sd": sd, "real": real}, index=pd.DatetimeIndex(fechas))


# ══════════════════════════════════════════════════════════════════════════════
# 4. MÉTRICAS + PRUEBAS
# ══════════════════════════════════════════════════════════════════════════════
def diebold_mariano(e1: np.ndarray, e2: np.ndarray, h: int = 1) -> tuple[float, float]:
    """DM con corrección HLN. H1: modelo 1 tiene MENOR pérdida cuadrática que el 2.
    → (estadístico, p unilateral). Positivo = el modelo 1 es mejor."""
    d = e2 ** 2 - e1 ** 2
    d = d[~np.isnan(d)]
    T = len(d)
    if T < 8 or np.allclose(d.var(), 0):
        return float("nan"), float("nan")
    dbar = d.mean()
    gamma = [np.mean((d[k:] - dbar) * (d[:T - k] - dbar)) for k in range(h)]
    var = (gamma[0] + 2 * sum(gamma[1:])) / T
    if var <= 0:
        return float("nan"), float("nan")
    dm = dbar / math.sqrt(var)
    dm *= math.sqrt((T + 1 - 2 * h + h * (h - 1) / T) / T)
    from scipy import stats
    return float(dm), float(1 - stats.t.cdf(dm, T - 1))


def metricas(bt: pd.DataFrame, ref_ar: pd.DataFrame | None, ref_rw: pd.DataFrame | None,
             y_prev: pd.Series) -> dict:
    ok = bt.dropna(subset=["pred"])
    e = (ok["real"] - ok["pred"]).values
    out = {"n": int(len(ok))}
    if not len(ok):
        return out
    out["mae"] = float(np.mean(np.abs(e)))
    out["rmse"] = float(np.sqrt(np.mean(e ** 2)))
    out["sesgo"] = float(np.mean(ok["pred"] - ok["real"]))
    prev = y_prev.reindex(ok.index).values
    m = ~np.isnan(prev)
    if m.sum() > 3 and not np.allclose(ok["pred"].values[m], prev[m]):   # no aplica al paseo aleatorio
        out["acierto_dir"] = float(np.mean(np.sign(ok["pred"].values[m] - prev[m]) == np.sign(ok["real"].values[m] - prev[m])))
    cob = ok.dropna(subset=["sd"])
    if len(cob):
        out["cobertura95"] = float(np.mean(np.abs(cob["real"] - cob["pred"]) <= Z95 * cob["sd"]))
    for nombre, ref in (("ar", ref_ar), ("rw", ref_rw)):
        if ref is None:
            continue
        r = ref.reindex(ok.index).dropna(subset=["pred"])
        comun = ok.index.intersection(r.index)
        if len(comun) < 8:
            continue
        e1 = (ok.loc[comun, "real"] - ok.loc[comun, "pred"]).values
        e2 = (r.loc[comun, "real"] - r.loc[comun, "pred"]).values
        out[f"rrmse_{nombre}"] = float(np.sqrt(np.mean(e1 ** 2)) / max(1e-12, np.sqrt(np.mean(e2 ** 2))))
        dm, p = diebold_mariano(e1, e2)
        out[f"dm_{nombre}"], out[f"p_dm_{nombre}"] = dm, p
    return out


def a_interanual(bt: pd.DataFrame, nivel: pd.Series, freq: str) -> pd.DataFrame:
    """m/m (%) → interanual (%) sustituyendo solo el período t por su pronóstico
    (prediccionesIPC.ipynb, convertir_a_interanual_v2)."""
    k = PER_ANIO[freq]
    I = nivel
    i_l1 = I.shift(1).reindex(bt.index)
    i_lk = I.shift(k).reindex(bt.index)
    real = (I.reindex(bt.index) / i_lk - 1) * 100
    pred = (i_l1 * (1 + bt["pred"] / 100) / i_lk - 1) * 100
    return pd.DataFrame({"pred": pred, "real": real, "sd": bt["sd"]}).dropna(subset=["real"])


def diagnostico(res: np.ndarray | None) -> dict:
    if res is None:
        return {}
    r = np.asarray(res, float)
    r = r[~np.isnan(r)]
    if len(r) < 15:
        return {}
    from statsmodels.stats.diagnostic import acorr_ljungbox, het_arch
    from scipy import stats
    out = {}
    try:
        lb = acorr_ljungbox(r, lags=[min(10, len(r) // 4)], return_df=True)
        out["ljung_box_p"] = float(lb["lb_pvalue"].iloc[0])
    except Exception:
        pass
    try:
        out["jarque_bera_p"] = float(stats.jarque_bera(r).pvalue)
    except Exception:
        pass
    try:
        out["arch_p"] = float(het_arch(r, nlags=min(10, len(r) // 5))[1])
    except Exception:
        pass
    return out


# ══════════════════════════════════════════════════════════════════════════════
# 5. CORRIDA COMPLETA
# ══════════════════════════════════════════════════════════════════════════════
def correr(p: dict, progreso=None) -> dict:
    df, X_sig, fecha_sig, nivel, nombres, avisos = preparar(p)
    freq = p.get("frecuencia", "M")
    bt_cfg = p.get("backtest", {})
    modelos = list(p.get("modelos", []))
    tipos = [m["tipo"] for m in modelos]
    # benchmarks obligatorios
    if "rw" not in tipos:
        modelos.insert(0, {"tipo": "rw", "id": "rw"})
    if "ar" not in tipos:
        modelos.insert(1, {"tipo": "ar", "id": "ar", "p": "auto"})
    interanual = bool(p.get("escala_interanual")) and p.get("transformacion") == "pct_mm"
    resultados, bts = [], {}
    y_prev = df["y"].shift(1)

    for j, spec in enumerate(modelos):
        mid = spec.get("id") or f"{spec['tipo']}_{j}"
        r = {"id": mid, "tipo": spec["tipo"], "nombre": spec.get("nombre") or _nombre(spec, nombres),
             "benchmark": mid in ("rw", "ar"), "error": None}
        try:
            def prog(f, j=j):
                if progreso:
                    progreso((j + f) / len(modelos), r["nombre"])
            bt = backtest(spec, nombres, df, bt_cfg, prog)
            bts[mid] = bt
            # modelo final con toda la muestra → pronóstico t+1
            m = CLASES[spec["tipo"]](spec, nombres)
            m.ajustar(df["y"], df[nombres] if nombres else None)
            mu, sd = m.predecir(X_sig if nombres else None)
            r["pronostico"] = _intervalos(fecha_sig, mu, sd)
            r["usa_exog"] = bool(getattr(m, "usa_exog", False) and nombres)
            r["coef"] = m.coeficientes()
            r["diagnostico"] = diagnostico(m.residuos())
            r["backtest"] = {"fechas": [d.strftime("%Y-%m-%d") for d in bt.index],
                             "pred": _lst(bt["pred"]), "real": _lst(bt["real"]), "sd": _lst(bt["sd"])}
            if interanual:
                ia = a_interanual(bt, nivel, freq)
                r["backtest_interanual"] = {"fechas": [d.strftime("%Y-%m-%d") for d in ia.index],
                                            "pred": _lst(ia["pred"]), "real": _lst(ia["real"])}
                k = PER_ANIO[freq]
                if len(nivel) > k and nivel.index[-1] + pd.tseries.frequencies.to_offset(FREQ_PD[freq]) == fecha_sig:
                    base = nivel.iloc[-1] * (1 + mu / 100)
                    ref = nivel.get(fecha_sig - pd.DateOffset(months=12 if freq == "M" else 12))
                    if ref is not None and not np.isnan(ref):
                        r["pronostico"]["interanual"] = _f((base / ref - 1) * 100)
        except Exception as e:
            r["error"] = f"{type(e).__name__}: {e}"
        resultados.append(r)

    ar_bt, rw_bt = bts.get("ar"), bts.get("rw")
    for r in resultados:
        if r["error"] or r["id"] not in bts:
            continue
        r["metricas"] = metricas(bts[r["id"]], None if r["id"] == "ar" else ar_bt,
                                 None if r["id"] == "rw" else rw_bt, y_prev)
        if interanual and "backtest_interanual" in r:
            bi = r["backtest_interanual"]
            ia = pd.DataFrame({"pred": bi["pred"], "real": bi["real"]}, index=pd.to_datetime(bi["fechas"]))
            ar_ia = a_interanual(ar_bt, nivel, freq) if ar_bt is not None and r["id"] != "ar" else None
            rw_ia = a_interanual(rw_bt, nivel, freq) if rw_bt is not None and r["id"] != "rw" else None
            ia["sd"] = np.nan
            r["metricas_interanual"] = metricas(ia, ar_ia, rw_ia, pd.Series(dtype=float))

    return {
        "fecha_pronostico": fecha_sig.strftime("%Y-%m-%d"),
        "muestra": {"desde": df.index[0].strftime("%Y-%m-%d"), "hasta": df.index[-1].strftime("%Y-%m-%d"), "n": int(len(df))},
        "serie": {"fechas": [d.strftime("%Y-%m-%d") for d in df.index], "y": _lst(df["y"])},
        "exogenas": {n: _lst(df[n]) for n in nombres},
        "exog_sig": {n: _f(X_sig[n]) for n in nombres},
        "modelos": resultados,
        "avisos": avisos,
        "interanual": interanual,
    }


# ── utilidades ───────────────────────────────────────────────────────────────
def _f(x):
    try:
        x = float(x)
    except Exception:
        return None
    return None if (math.isnan(x) or math.isinf(x)) else round(x, 6)


def _lst(s):
    return [_f(v) for v in s]


def _intervalos(fecha, mu, sd):
    return {"fecha": fecha.strftime("%Y-%m-%d"), "media": _f(mu), "sd": _f(sd),
            "li80": _f(mu - Z80 * sd), "ls80": _f(mu + Z80 * sd),
            "li95": _f(mu - Z95 * sd), "ls95": _f(mu + Z95 * sd)}


def _tabla_coef(res, nombres):
    params = np.asarray(res.params)
    se = np.asarray(getattr(res, "bse", np.full(len(params), np.nan)))
    pv = np.asarray(getattr(res, "pvalues", np.full(len(params), np.nan)))
    nombres = nombres or [f"b{i}" for i in range(len(params))]
    return [{"nombre": str(n), "valor": _f(b), "ee": _f(s), "p": _f(q)}
            for n, b, s, q in zip(nombres, params, se, pv)]


def _nombre(spec, nombres):
    t = spec["tipo"]
    if t in ("arima", "sarimax"):
        o = f"({spec.get('p', 1)},{spec.get('d', 0)},{spec.get('q', 1)})"
        if any(int(spec.get(k, 0)) for k in ("P", "D", "Q")):
            o += f"({spec.get('P', 0)},{spec.get('D', 0)},{spec.get('Q', 0)})[{spec.get('s', 12)}]"
        base = "SARIMAX" if t == "sarimax" else "ARIMA"
        return f"{base}{o}" + (" + exógenas" if t == "sarimax" and nombres else "")
    if t == "arx":
        return f"ARX({spec.get('p', 2)})" + (" + exógenas" if nombres else "")
    if t == "var":
        return f"VAR({spec.get('p', 'auto')})"
    return NOMBRES.get(t, t)


# ══════════════════════════════════════════════════════════════════════════════
# 6. ISEC en Python (igual a dashboard-web/lib/sentimiento.ts → calcularISEC)
# ══════════════════════════════════════════════════════════════════════════════
def isec_desde_agregado(ag: pd.DataFrame, freq: str = "M",
                        pesos=(0.7, 0.1, 0.1, 0.1)) -> pd.DataFrame:
    """ag: columnas fecha, n, n_pos, n_neg, suma_pol (una categoría/universo)."""
    L = {"D": 365, "W": 52, "M": 12}[freq]
    regla = {"D": "D", "W": "W-MON", "M": "MS"}[freq]
    a = ag.copy()
    a["fecha"] = pd.to_datetime(a["fecha"])
    a = a.set_index("fecha").sort_index()
    idx = pd.date_range(a.index.min(), a.index.max(), freq=regla)
    a = a.reindex(idx)
    a["n"] = a["n"].fillna(0)
    sps = a["suma_pol"] / a["n"].replace(0, np.nan)
    med = a["n"].rolling(L, min_periods=math.ceil(L / 2)).median()
    sg = np.sign(sps).fillna(0)
    lnatm = np.log(a["n"].replace(0, np.nan) / med) * sg
    idm = (np.minimum(a["n_pos"], a["n_neg"]) / a["n"].replace(0, np.nan)) * -sg
    vs = -sps.rolling(L, min_periods=max(3, math.ceil(math.ceil(L / 2) / 2))).std()
    w1, w2, w3, w4 = pesos
    isec = w1 * sps + w2 * lnatm + w3 * idm + w4 * vs
    return pd.DataFrame({"sps": sps, "lnatm": lnatm, "idm": idm, "vs": vs, "isec": isec})
