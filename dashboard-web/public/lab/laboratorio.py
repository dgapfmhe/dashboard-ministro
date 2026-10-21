"""Laboratorio de pronósticos (t+1) con sentimiento de prensa.

UN solo motor para dos lugares:
  · navegador (Pyodide, Web Worker)   → pestaña "Laboratorio de Pronósticos"
  · GitHub Actions (CPython)          → pronósticos oficiales y su historial de aciertos

Entrada: dict `payload` (JSON-serializable). Salida: dict JSON-serializable.
Basado en prediccionesIPC.ipynb (SARIMAX(1,0,1)+ISEC, VAR, backtest expanding/rolling,
conversión m/m → interanual) y en el veredicto de la investigación: SIEMPRE se reporta
contra referencias simples (paseo aleatorio y AR) con Diebold-Mariano.

Familias de modelos
  referencia   : rw, media, ar
  econométricos: arima, sarimax, arx, var          (dummies opcionales)
  machine learn: ridge, lasso, enet, rf, gbr, svr, knn, mlp   (hiperparámetros editables)
"""
from __future__ import annotations

import math
import warnings

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")

FREQ_PD = {"M": "MS", "Q": "QS"}
PER_ANIO = {"M": 12, "Q": 4}
Z80, Z95 = 1.2815515655, 1.959963985

NOMBRES = {
    "rw": "Paseo aleatorio", "media": "Media histórica", "ar": "AR(p) automático",
    "arima": "ARIMA", "sarimax": "SARIMAX", "arx": "ARX (MCO)", "var": "VAR",
    "ridge": "Ridge", "lasso": "Lasso", "enet": "Elastic Net", "rf": "Random Forest",
    "gbr": "Gradient Boosting", "svr": "SVR (máquina de soporte vectorial)",
    "knn": "K vecinos más cercanos", "mlp": "Red neuronal (MLP)",
}
ML_TIPOS = {"ridge", "lasso", "enet", "rf", "gbr", "svr", "knn", "mlp"}


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
    r = s.resample("MS" if freq == "M" else "QS")
    out = {"promedio": r.mean, "ultimo": r.last, "suma": r.sum}[agregacion]()
    if agregacion == "suma":
        out = out.where(r.count() > 0)
    return out.dropna()


def transformar(s: pd.Series, t: str, freq: str) -> pd.Series:
    k = PER_ANIO[freq]
    if t == "nivel":
        return s
    if t == "log":
        return np.log(s.where(s > 0))
    if t == "pct_mm":
        return (s / s.shift(1) - 1) * 100
    if t == "pct_aa":
        return (s / s.shift(k) - 1) * 100
    if t == "dif":
        return s.diff()
    if t == "dif_aa":
        return s.diff(k)
    if t == "logdif":
        return np.log(s.where(s > 0)).diff() * 100
    raise ValueError(f"transformación desconocida: {t}")


def dummies(indice: pd.DatetimeIndex, cfg: dict, freq: str) -> pd.DataFrame:
    """Variables determinísticas (conocidas en t+1): estacionales e intervenciones."""
    D = pd.DataFrame(index=indice)
    if cfg.get("estacionales"):
        if freq == "M":
            for m in range(2, 13):
                D[f"D: mes {m:02d}"] = (indice.month == m).astype(float)
        else:
            for q in range(2, 5):
                D[f"D: trim {q}"] = (indice.quarter == q).astype(float)
    for i, d in enumerate(cfg.get("lista", []) or []):
        nombre = f"D: {d.get('nombre') or d['tipo']}"
        if nombre in D.columns:
            nombre += f" {i + 1}"
        t = d["tipo"]
        a = pd.Timestamp(d.get("desde") or indice[0])
        b = pd.Timestamp(d.get("hasta") or a)
        if t == "impulso":
            D[nombre] = (indice.to_period(freq) == a.to_period(freq)).astype(float)
        elif t == "escalon":
            D[nombre] = (indice >= a).astype(float)
        elif t == "rango":
            D[nombre] = ((indice >= a) & (indice <= b)).astype(float)
        elif t == "tendencia":
            D[nombre] = np.arange(len(indice), dtype=float) / PER_ANIO[freq]
        else:
            raise ValueError(f"dummy desconocida: {t}")
    return D


def preparar(p: dict):
    """→ (df muestra, X_sig, fecha t+1, nivel original, exógenas, determinísticas, avisos)"""
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
        if ex.get("estandarizar"):
            s = (s - s.mean()) / (s.std() or 1)
        rez = int(ex.get("rezago", 0))
        nombre = ex.get("nombre", ex["id"]) + (f" (t-{rez})" if rez else " (t)")
        cols[nombre] = s.shift(rez, freq=FREQ_PD[freq]) if rez else s
        nombres.append(nombre)
    df = pd.DataFrame(cols)
    df = df[df.index >= pd.Timestamp(p.get("desde", "2000-01-01"))]
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

    # Exógena sin dato en los últimos períodos de y (p. ej. hueco de noticias): se
    # rellena con su último valor solo si faltan ≤ 3 períodos; si no, la muestra
    # terminaría antes que y y el "t+1" sería engañoso → error explícito.
    for n in nombres:
        ult_x = df[n].loc[:ult_y].last_valid_index()
        if ult_x is None or ult_x >= ult_y:
            continue
        faltan = len(df.loc[ult_x:ult_y]) - 1
        if faltan <= 3:
            df.loc[ult_x:ult_y, n] = df.loc[ult_x:ult_y, n].ffill()
            avisos.append(f"«{n}» no tiene dato en los últimos {faltan} período(s) de la variable objetivo "
                          f"(hasta {ult_y:%Y-%m}): se rellenan con su último valor ({ult_x:%Y-%m}).")
        else:
            raise ValueError(f"«{n}» termina en {ult_x:%Y-%m} pero la variable objetivo llega a {ult_y:%Y-%m} "
                             f"({faltan} períodos sin dato). Hay un hueco en la serie: usa otra exógena, "
                             f"un rezago mayor o espera a que se complete.")
    muestra = df.loc[:ult_y].dropna()
    if len(muestra) < 24:
        rangos = []
        for c in ["y"] + nombres:
            s = df[c].dropna()
            etq = "objetivo" if c == "y" else f"«{c}»"
            rangos.append(f"{etq}: {s.index[0]:%Y-%m}→{s.index[-1]:%Y-%m} ({len(s)})" if len(s) else f"{etq}: sin datos")
        raise ValueError(f"Muestra muy corta ({len(muestra)} períodos con todas las variables; mínimo 24). "
                         f"Datos disponibles — " + "; ".join(rangos))

    # determinísticas sobre muestra + t+1
    D = dummies(muestra.index.append(pd.DatetimeIndex([fecha_sig])), p.get("dummies", {}), freq)
    det = list(D.columns)
    vacias = [c for c in det if D.loc[muestra.index, c].nunique() < 2 and "tendencia" not in c]
    if vacias:
        avisos.append("Dummies constantes en la muestra (se descartan): " + ", ".join(vacias))
        D = D.drop(columns=vacias); det = [c for c in det if c not in vacias]
    muestra = pd.concat([muestra, D.loc[muestra.index]], axis=1)
    for c in det:
        X_sig[c] = float(D.loc[fecha_sig, c])
    return muestra, X_sig, fecha_sig, nivel, nombres, det, avisos


# ══════════════════════════════════════════════════════════════════════════════
# 2. MODELOS
# ══════════════════════════════════════════════════════════════════════════════
class Base:
    familia = "referencia"
    def __init__(self, spec: dict, nombres: list[str], det: list[str]):
        self.spec, self.nombres, self.det = spec, nombres, det
        self.res = None
        self.cols_x: list[str] = []
        self.activas: list[str] = []
        self.sd_empirico: float | None = None
    def _X(self, X, ajuste: bool = True):
        """Columnas de X del modelo. Al ajustar descarta las constantes en la ventana
        (p. ej. una dummy de 2022 en una ventana de 2018) y recuerda cuáles quedaron."""
        if X is None or not self.cols_x:
            if ajuste:
                self.activas = []
            return None
        if ajuste:
            self.activas = [c for c in self.cols_x if X[c].nunique(dropna=True) > 1]
        return X[self.activas] if self.activas else None
    def ajustar(self, y, X): ...
    def actualizar(self, y, X):
        self.ajustar(y, X)
    def predecir(self, X_sig): ...
    def coeficientes(self):
        return []
    def residuos(self):
        return None
    def propiedades(self) -> dict:
        return {}
    def ecuacion(self) -> str:
        return ""


class RW(Base):
    def ajustar(self, y, X):
        self.y = y
        self.sd = float(np.nanstd(y.diff().dropna(), ddof=1)) if len(y) > 2 else float("nan")
    def predecir(self, X_sig):
        return float(self.y.iloc[-1]), self.sd
    def ecuacion(self):
        return "ŷ(t+1) = y(t)"
    def propiedades(self):
        return {"desv_cambios": _f(self.sd), "n_obs": len(self.y)}


class Media(Base):
    def ajustar(self, y, X):
        self.mu, self.sd, self.n = float(y.mean()), float(y.std(ddof=1)), len(y)
    def predecir(self, X_sig):
        return self.mu, self.sd
    def ecuacion(self):
        return "ŷ(t+1) = media de y en la muestra de entrenamiento"
    def propiedades(self):
        return {"media": _f(self.mu), "desv_estandar": _f(self.sd), "n_obs": self.n}


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
        return _tabla_coef(self.res, ["const"] + [f"y(t-{l})" for l in (self.res.ar_lags or [])])
    def residuos(self):
        return self.res.resid
    def ecuacion(self):
        return f"y(t) = c + Σ φᵢ·y(t-i) + ε(t),  rezagos = {list(self.res.ar_lags or [])} (elegidos por AIC)"
    def propiedades(self):
        r = self.res
        raices = np.abs(r.roots) if len(r.roots) else np.array([])
        return {"n_obs": int(r.nobs), "rezagos": list(map(int, r.ar_lags or [])), "aic": _f(r.aic), "bic": _f(r.bic),
                "hqic": _f(r.hqic), "log_verosimilitud": _f(r.llf), "sigma2": _f(r.sigma2),
                "modulo_raices_ar": _lst(raices), "estacionario": bool((raices > 1).all()) if len(raices) else True}


class SARIMAX_(Base):
    familia = "econometrico"
    def __init__(self, spec, nombres, det):
        super().__init__(spec, nombres, det)
        usa_exog = bool(spec.get("exog", spec["tipo"] == "sarimax")) and bool(nombres)
        self.cols_x = (nombres if usa_exog else []) + (det if spec.get("dummies", True) else [])
    def _orden(self):
        s = self.spec
        o = (int(s.get("p", 1)), int(s.get("d", 0)), int(s.get("q", 1)))
        so = (int(s.get("P", 0)), int(s.get("D", 0)), int(s.get("Q", 0)), int(s.get("s", 12)))
        return o, (so if any(so[:3]) else (0, 0, 0, 0))
    def ajustar(self, y, X):
        from statsmodels.tsa.statespace.sarimax import SARIMAX
        o, so = self._orden()
        tend = self.spec.get("tendencia") or ("c" if o[1] == 0 and so[1] == 0 else "n")
        Xx = self._X(X)
        self.mod = SARIMAX(y.values, exog=Xx.values if Xx is not None else None, order=o, seasonal_order=so,
                           trend=tend, enforce_stationarity=False, enforce_invertibility=False)
        self.res = self.mod.fit(disp=False, maxiter=200)
    def actualizar(self, y, X):
        try:
            Xx = self._X(X, ajuste=False)
            self.res = self.res.apply(y.values, exog=Xx.values if Xx is not None else None)
        except Exception:
            self.ajustar(y, X)
    def predecir(self, X_sig):
        ex = X_sig[self.activas].values.reshape(1, -1) if self.activas else None
        f = self.res.get_forecast(steps=1, exog=ex)
        return float(f.predicted_mean[0]), float(np.sqrt(f.var_pred_mean[0]))
    def coeficientes(self):
        nombres = []
        for n in self.res.model.param_names:
            if n.startswith("x") and n[1:].isdigit():
                n = self.activas[int(n[1:]) - 1]
            nombres.append(n)
        return _tabla_coef(self.res, nombres)
    def residuos(self):
        return self.res.resid[max(1, self._orden()[0][1]):]
    def ecuacion(self):
        (p, d, q), (P, D, Q, s) = self._orden()
        base = f"φ_{p}(L)" + (f"·Φ_{P}(L^{s})" if P else "") + (f"·(1−L)^{d}" if d else "") + (f"·(1−L^{s})^{D}" if D else "")
        x = " + β'·x(t)" if self.activas else ""
        return f"{base}·y(t) = c{x} + θ_{q}(L)" + (f"·Θ_{Q}(L^{s})" if Q else "") + "·ε(t)" + \
            (f"   x = {', '.join(self.activas)}" if self.activas else "")
    def propiedades(self):
        r = self.res
        ar = np.abs(np.atleast_1d(getattr(r, "arroots", []))) if len(np.atleast_1d(getattr(r, "arroots", []))) else np.array([])
        ma = np.abs(np.atleast_1d(getattr(r, "maroots", []))) if len(np.atleast_1d(getattr(r, "maroots", []))) else np.array([])
        (o, so) = self._orden()
        return {"orden": list(o), "orden_estacional": list(so), "n_obs": int(r.nobs), "k_parametros": int(len(r.params)),
                "aic": _f(r.aic), "bic": _f(r.bic), "hqic": _f(r.hqic), "log_verosimilitud": _f(r.llf),
                "sigma2": _f(r.params[-1]), "modulo_raices_ar": _lst(ar), "modulo_raices_ma": _lst(ma),
                "estacionario": bool((ar > 1).all()) if len(ar) else True,
                "invertible": bool((ma > 1).all()) if len(ma) else True,
                "regresores": self.activas}


class ARX(Base):
    familia = "econometrico"
    def __init__(self, spec, nombres, det):
        super().__init__(spec, nombres, det)
        self.cols_x = nombres + (det if spec.get("dummies", True) else [])
    def _diseno(self, y, X):
        p = int(self.spec.get("p", 2))
        D = pd.DataFrame({f"y(t-{i})": y.shift(i) for i in range(1, p + 1)}, index=y.index)
        Xx = self._X(X)
        return pd.concat([D, Xx], axis=1) if Xx is not None else D
    def ajustar(self, y, X):
        import statsmodels.api as sm
        D = self._diseno(y, X)
        ok = D.notna().all(axis=1)
        cov = "HAC" if self.spec.get("hac") else "nonrobust"
        kw = {"cov_kwds": {"maxlags": 3}} if cov == "HAC" else {}
        self.res = sm.OLS(y[ok].values, sm.add_constant(D[ok].values, has_constant="add")).fit(cov_type=cov, **kw)
        self.cols = ["const"] + list(D.columns)
        self.y = y
    def predecir(self, X_sig):
        p = int(self.spec.get("p", 2))
        fila = [1.0] + [float(self.y.iloc[-i]) for i in range(1, p + 1)] + [float(X_sig[c]) for c in self.activas]
        pr = self.res.get_prediction(np.array(fila).reshape(1, -1))
        return float(pr.predicted_mean[0]), float(np.sqrt(pr.var_pred_mean[0] + self.res.scale))
    def coeficientes(self):
        return _tabla_coef(self.res, self.cols)
    def residuos(self):
        return self.res.resid
    def ecuacion(self):
        p = int(self.spec.get("p", 2))
        return f"y(t) = c + Σ_{{i=1..{p}}} φᵢ·y(t-i)" + (" + β'·x(t)" if self.activas else "") + " + ε(t)   (MCO" + \
            (", errores HAC)" if self.spec.get("hac") else ")")
    def propiedades(self):
        from statsmodels.stats.stattools import durbin_watson
        r = self.res
        return {"n_obs": int(r.nobs), "k_parametros": int(len(r.params)), "r2": _f(r.rsquared), "r2_ajustado": _f(r.rsquared_adj),
                "aic": _f(r.aic), "bic": _f(r.bic), "log_verosimilitud": _f(r.llf), "sigma2": _f(r.scale),
                "f_p_valor": _f(r.f_pvalue), "durbin_watson": _f(durbin_watson(r.resid)),
                "numero_condicion": _f(r.condition_number), "errores": "HAC (Newey-West)" if self.spec.get("hac") else "clásicos",
                "regresores": self.cols[1:]}


class VAR_(Base):
    familia = "econometrico"
    def __init__(self, spec, nombres, det):
        super().__init__(spec, nombres, det)
        self.endog = nombres
        self.cols_x = det if spec.get("dummies", True) else []
    def ajustar(self, y, X):
        from statsmodels.tsa.api import VAR
        En = pd.concat([y, X[self.endog]], axis=1) if self.endog else y.to_frame()
        Ex = self._X(X)
        self.D = En.values
        mod = VAR(self.D, exog=Ex.values if Ex is not None else None)
        p = self.spec.get("p", "auto")
        if p == "auto":
            try:
                sel = mod.select_order(maxlags=min(int(self.spec.get("pmax", 4)), max(1, len(En) // 10)))
                p = max(1, int(sel.selected_orders.get("aic") or 1))
            except Exception:
                p = 1
        self.res = mod.fit(int(p))
        self.k = self.res.k_ar
        self.cols = ["y"] + self.endog
    def predecir(self, X_sig):
        ex = X_sig[self.activas].values.reshape(1, -1) if self.activas else None
        f = self.res.forecast(self.D[-self.k:], steps=1, exog_future=ex)[0][0]
        return float(f), float(np.sqrt(self.res.forecast_cov(1)[0][0, 0]))
    def coeficientes(self):
        import re
        params, se, pv = self.res.params[:, 0], self.res.stderr[:, 0], self.res.pvalues[:, 0]
        nombres = list(getattr(self.res, "exog_names", None) or range(len(params)))
        def bonito(n):
            m = re.match(r"L(\d+)\.y(\d+)", str(n))
            if m:
                k = int(m.group(2)) - 1
                return f"{self.cols[k]} (t-{m.group(1)})"
            m = re.match(r"exog(\d+)", str(n))
            if m and int(m.group(1)) < len(self.activas):
                return self.activas[int(m.group(1))]
            return str(n)
        return [{"nombre": bonito(n), "valor": _f(b), "ee": _f(s), "p": _f(q)} for n, b, s, q in zip(nombres, params, se, pv)]
    def residuos(self):
        return self.res.resid[:, 0]
    def ecuacion(self):
        return f"Y(t) = c + Σ_{{i=1..{self.k}}} Aᵢ·Y(t-i)" + (" + B·D(t)" if self.activas else "") + \
            f" + u(t),   Y = ({', '.join(self.cols)})"
    def propiedades(self):
        r = self.res
        out = {"rezagos": int(self.k), "n_obs": int(r.nobs), "variables": self.cols, "aic": _f(r.aic), "bic": _f(r.bic),
               "hqic": _f(r.hqic), "fpe": _f(r.fpe), "log_verosimilitud": _f(r.llf),
               "estable": bool(r.is_stable()), "determinísticas": self.activas}
        if self.endog:
            try:
                g = r.test_causality(0, causing=list(range(1, len(self.cols))), kind="f")
                out["granger_exogenas_a_y_p"] = _f(g.pvalue)
            except Exception:
                pass
        return out


class ML(Base):
    """Modelos de machine learning (scikit-learn) con rezagos de y + exógenas + dummies."""
    familia = "ml"
    def __init__(self, spec, nombres, det):
        super().__init__(spec, nombres, det)
        self.cols_x = nombres + (det if spec.get("dummies", True) else [])
        self.p = int(spec.get("p", 3))
        self.hp = dict(spec.get("hp", {}))
    def _estimador(self):
        from sklearn import ensemble, linear_model, neighbors, neural_network, svm
        t, h = self.spec["tipo"], self.hp
        if t == "ridge":
            return linear_model.Ridge(alpha=float(h.get("alpha", 1.0)))
        if t == "lasso":
            return linear_model.Lasso(alpha=float(h.get("alpha", 0.01)), max_iter=20000)
        if t == "enet":
            return linear_model.ElasticNet(alpha=float(h.get("alpha", 0.01)), l1_ratio=float(h.get("l1_ratio", 0.5)), max_iter=20000)
        if t == "rf":
            md = int(h.get("max_depth", 0))
            mf = h.get("max_features", "1.0")
            return ensemble.RandomForestRegressor(n_estimators=int(h.get("n_estimators", 300)), max_depth=md or None,
                                                  min_samples_leaf=int(h.get("min_samples_leaf", 3)),
                                                  max_features=mf if mf in ("sqrt", "log2") else float(mf), random_state=42)
        if t == "gbr":
            return ensemble.GradientBoostingRegressor(n_estimators=int(h.get("n_estimators", 200)),
                                                      learning_rate=float(h.get("learning_rate", 0.05)),
                                                      max_depth=int(h.get("max_depth", 2)), subsample=float(h.get("subsample", 0.8)),
                                                      loss=h.get("loss", "squared_error"), random_state=42)
        if t == "svr":
            return svm.SVR(C=float(h.get("C", 1.0)), epsilon=float(h.get("epsilon", 0.05)), kernel=h.get("kernel", "rbf"),
                           gamma=h.get("gamma", "scale"))
        if t == "knn":
            return neighbors.KNeighborsRegressor(n_neighbors=int(h.get("n_neighbors", 7)), weights=h.get("weights", "distance"))
        if t == "mlp":
            capas = tuple(int(x) for x in str(h.get("capas", "16,8")).replace(" ", "").split(",") if x)
            return neural_network.MLPRegressor(hidden_layer_sizes=capas or (16,), activation=h.get("activation", "relu"),
                                               alpha=float(h.get("alpha", 0.001)), learning_rate_init=float(h.get("learning_rate_init", 0.005)),
                                               max_iter=int(h.get("max_iter", 1500)), random_state=42)
        raise ValueError(t)
    def _diseno(self, y, X):
        D = pd.DataFrame({f"y(t-{i})": y.shift(i) for i in range(1, self.p + 1)}, index=y.index)
        Xx = self._X(X)
        return pd.concat([D, Xx], axis=1) if Xx is not None else D
    def ajustar(self, y, X):
        from sklearn.pipeline import make_pipeline
        from sklearn.preprocessing import StandardScaler
        D = self._diseno(y, X)
        ok = D.notna().all(axis=1)
        self.Xtr, self.ytr = D[ok].values, y[ok].values
        self.pipe = make_pipeline(StandardScaler(), self._estimador()).fit(self.Xtr, self.ytr)
        self.cols = list(D.columns)
        self.y = y
        self.resid_tr = self.ytr - self.pipe.predict(self.Xtr)
    def predecir(self, X_sig):
        fila = [float(self.y.iloc[-i]) for i in range(1, self.p + 1)] + [float(X_sig[c]) for c in self.activas]
        mu = float(self.pipe.predict(np.array(fila).reshape(1, -1))[0])
        sd = self.sd_empirico if self.sd_empirico else float(np.std(self.resid_tr, ddof=1))
        return mu, sd
    def residuos(self):
        return self.resid_tr
    def coeficientes(self):
        est = self.pipe[-1]
        if hasattr(est, "coef_"):
            c = np.atleast_1d(est.coef_)
            return [{"nombre": "const", "valor": _f(est.intercept_), "ee": None, "p": None}] + \
                   [{"nombre": n + " (estandarizado)", "valor": _f(v), "ee": None, "p": None} for n, v in zip(self.cols, c)]
        return []
    def importancias(self):
        est = self.pipe[-1]
        if hasattr(est, "feature_importances_"):
            v = est.feature_importances_
            tipo = "impureza (MDI)"
        elif hasattr(est, "coef_"):
            v = np.abs(np.atleast_1d(est.coef_)); v = v / (v.sum() or 1)
            tipo = "|coeficiente| estandarizado"
        else:
            from sklearn.inspection import permutation_importance
            r = permutation_importance(self.pipe, self.Xtr, self.ytr, n_repeats=5, random_state=42)
            v = np.clip(r.importances_mean, 0, None); v = v / (v.sum() or 1)
            tipo = "permutación"
        orden = np.argsort(-v)
        return tipo, [{"nombre": self.cols[i], "valor": _f(v[i])} for i in orden]
    def ecuacion(self):
        return f"y(t) = f(y(t-1)…y(t-{self.p})" + (", " + ", ".join(self.activas) if self.activas else "") + \
            f") + ε(t),   f = {NOMBRES[self.spec['tipo']]} (variables estandarizadas)"
    def propiedades(self):
        tipo, imp = self.importancias()
        pred = self.pipe.predict(self.Xtr)
        ss = float(np.sum((self.ytr - self.ytr.mean()) ** 2)) or 1.0
        return {"hiperparametros": {k: (str(v) if not isinstance(v, (int, float, bool)) else v)
                                    for k, v in self.pipe[-1].get_params().items() if not callable(v)},
                "rezagos_y": self.p, "n_obs": int(len(self.ytr)), "n_variables": len(self.cols),
                "r2_entrenamiento": _f(1 - float(np.sum((self.ytr - pred) ** 2)) / ss),
                "rmse_entrenamiento": _f(float(np.sqrt(np.mean((self.ytr - pred) ** 2)))),
                "importancia_tipo": tipo, "importancias": imp,
                "nota": "Los intervalos del pronóstico final usan el error fuera de muestra del backtest (no el de entrenamiento)."}


CLASES = {"rw": RW, "media": Media, "ar": AR, "arima": SARIMAX_, "sarimax": SARIMAX_, "arx": ARX, "var": VAR_,
          **{t: ML for t in ML_TIPOS}}


# ══════════════════════════════════════════════════════════════════════════════
# 3. BACKTEST (1 paso adelante, fuera de muestra)
# ══════════════════════════════════════════════════════════════════════════════
def backtest(spec, nombres, det, df, cfg, progreso=None):
    y = df["y"]
    X = df[nombres + det] if (nombres or det) else None
    n = len(df)
    min_train = max(12, int(cfg.get("min_train", 36)))
    esquema = cfg.get("esquema", "expanding")
    ventana = int(cfg.get("ventana", 60))
    cada = max(1, int(cfg.get("reestimar_cada", 12)))
    fechas, pred, sd, real = [], [], [], []
    m = None
    errs: list[float] = []
    for i, t in enumerate(range(min_train, n)):
        a = 0 if esquema == "expanding" else max(0, t - ventana)
        yt, Xt = y.iloc[a:t], (X.iloc[a:t] if X is not None else None)
        try:
            if m is None or i % cada == 0 or esquema == "rolling":
                m = CLASES[spec["tipo"]](spec, nombres, det)
                m.ajustar(yt, Xt)
            else:
                m.actualizar(yt, Xt)
            if isinstance(m, ML) and len(errs) >= 6:
                m.sd_empirico = float(np.sqrt(np.mean(np.square(errs))))
            mu, s = m.predecir(X.iloc[t] if X is not None else None)
        except Exception:
            mu, s = np.nan, np.nan
        fechas.append(df.index[t]); pred.append(mu); sd.append(s); real.append(float(y.iloc[t]))
        if not np.isnan(mu):
            errs.append(float(y.iloc[t]) - mu)
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
    dm = dbar / math.sqrt(var) * math.sqrt((T + 1 - 2 * h + h * (h - 1) / T) / T)
    from scipy import stats
    return float(dm), float(1 - stats.t.cdf(dm, T - 1))


def metricas(bt: pd.DataFrame, ref_ar, ref_rw, y_prev: pd.Series) -> dict:
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
    if m.sum() > 3 and not np.allclose(ok["pred"].values[m], prev[m]):
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
        out[f"dm_{nombre}"], out[f"p_dm_{nombre}"] = diebold_mariano(e1, e2)
    return out


def a_interanual(bt: pd.DataFrame, nivel: pd.Series, freq: str) -> pd.DataFrame:
    """m/m (%) → interanual (%) sustituyendo solo el período t por su pronóstico."""
    k = PER_ANIO[freq]
    i_l1 = nivel.shift(1).reindex(bt.index)
    i_lk = nivel.shift(k).reindex(bt.index)
    real = (nivel.reindex(bt.index) / i_lk - 1) * 100
    pred = (i_l1 * (1 + bt["pred"] / 100) / i_lk - 1) * 100
    return pd.DataFrame({"pred": pred, "real": real, "sd": bt["sd"]}).dropna(subset=["real"])


def diagnostico(res) -> dict:
    if res is None:
        return {}
    r = np.asarray(res, float)
    r = r[~np.isnan(r)]
    if len(r) < 15:
        return {}
    from scipy import stats
    from statsmodels.stats.diagnostic import acorr_ljungbox, het_arch
    out = {}
    try:
        out["ljung_box_p"] = float(acorr_ljungbox(r, lags=[min(10, len(r) // 4)], return_df=True)["lb_pvalue"].iloc[0])
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
    out["media_residuos"] = _f(r.mean())
    out["asimetria"] = _f(stats.skew(r))
    out["curtosis"] = _f(stats.kurtosis(r, fisher=False))
    return out


# ══════════════════════════════════════════════════════════════════════════════
# 5. CORRIDA COMPLETA
# ══════════════════════════════════════════════════════════════════════════════
def correr(p: dict, progreso=None) -> dict:
    df, X_sig, fecha_sig, nivel, nombres, det, avisos = preparar(p)
    freq = p.get("frecuencia", "M")
    bt_cfg = p.get("backtest", {})
    modelos = list(p.get("modelos", []))
    tipos = [m["tipo"] for m in modelos]
    if "rw" not in tipos:
        modelos.insert(0, {"tipo": "rw", "id": "rw"})
    if "ar" not in tipos:
        modelos.insert(1, {"tipo": "ar", "id": "ar", "p": "auto"})
    interanual = bool(p.get("escala_interanual")) and p.get("transformacion") == "pct_mm"
    resultados, bts = [], {}
    y_prev = df["y"].shift(1)
    Xall = df[nombres + det] if (nombres or det) else None

    for j, spec in enumerate(modelos):
        mid = spec.get("id") or f"{spec['tipo']}_{j}"
        clase = CLASES[spec["tipo"]]
        r = {"id": mid, "tipo": spec["tipo"], "familia": clase.familia, "nombre": spec.get("nombre") or _nombre(spec, nombres, det),
             "benchmark": mid in ("rw", "ar"), "error": None, "spec": spec}
        try:
            def prog(f, j=j, nombre=r["nombre"]):
                if progreso:
                    progreso((j + f) / len(modelos), nombre)
            bt = backtest(spec, nombres, det, df, bt_cfg, prog)
            bts[mid] = bt
            m = clase(spec, nombres, det)
            m.ajustar(df["y"], Xall)
            if isinstance(m, ML):
                e = (bt["real"] - bt["pred"]).dropna()
                if len(e) >= 6:
                    m.sd_empirico = float(np.sqrt(np.mean(e ** 2)))
            mu, sd = m.predecir(X_sig if (nombres or det) else None)
            r["pronostico"] = _intervalos(fecha_sig, mu, sd)
            r["usa_exog"] = bool(getattr(m, "activas", []))
            r["coef"] = m.coeficientes()
            r["diagnostico"] = diagnostico(m.residuos())
            r["ecuacion"] = m.ecuacion()
            r["propiedades"] = m.propiedades()
            r["backtest"] = {"fechas": [d.strftime("%Y-%m-%d") for d in bt.index],
                             "pred": _lst(bt["pred"]), "real": _lst(bt["real"]), "sd": _lst(bt["sd"])}
            if interanual:
                ia = a_interanual(bt, nivel, freq)
                r["backtest_interanual"] = {"fechas": [d.strftime("%Y-%m-%d") for d in ia.index],
                                            "pred": _lst(ia["pred"]), "real": _lst(ia["real"])}
                if nivel.index[-1] + pd.tseries.frequencies.to_offset(FREQ_PD[freq]) == fecha_sig:
                    ref = nivel.get(fecha_sig - pd.DateOffset(months=12))
                    if ref is not None and not np.isnan(ref):
                        r["pronostico"]["interanual"] = _f((nivel.iloc[-1] * (1 + mu / 100) / ref - 1) * 100)
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
            ia["sd"] = np.nan
            ar_ia = a_interanual(ar_bt, nivel, freq) if ar_bt is not None and r["id"] != "ar" else None
            rw_ia = a_interanual(rw_bt, nivel, freq) if rw_bt is not None and r["id"] != "rw" else None
            r["metricas_interanual"] = metricas(ia, ar_ia, rw_ia, pd.Series(dtype=float))

    return {
        "fecha_pronostico": fecha_sig.strftime("%Y-%m-%d"),
        "muestra": {"desde": df.index[0].strftime("%Y-%m-%d"), "hasta": df.index[-1].strftime("%Y-%m-%d"), "n": int(len(df))},
        "serie": {"fechas": [d.strftime("%Y-%m-%d") for d in df.index], "y": _lst(df["y"])},
        "exogenas": {n: _lst(df[n]) for n in nombres},
        "dummies": det,
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
    nombres = nombres if nombres and len(nombres) == len(params) else [f"b{i}" for i in range(len(params))]
    return [{"nombre": str(n), "valor": _f(b), "ee": _f(s), "p": _f(q)} for n, b, s, q in zip(nombres, params, se, pv)]


def _nombre(spec, nombres, det):
    t = spec["tipo"]
    extra = (" + exógenas" if nombres else "") + (" + dummies" if det and spec.get("dummies", True) else "")
    if t in ("arima", "sarimax"):
        o = f"({spec.get('p', 1)},{spec.get('d', 0)},{spec.get('q', 1)})"
        if any(int(spec.get(k, 0)) for k in ("P", "D", "Q")):
            o += f"({spec.get('P', 0)},{spec.get('D', 0)},{spec.get('Q', 0)})[{spec.get('s', 12)}]"
        if t == "arima":
            return f"ARIMA{o}" + (" + dummies" if det and spec.get("dummies", True) else "")
        return f"SARIMAX{o}" + extra
    if t == "arx":
        return f"ARX({spec.get('p', 2)})" + extra
    if t == "var":
        return f"VAR({spec.get('p', 'auto')})" + (" + dummies" if det and spec.get("dummies", True) else "")
    if t in ML_TIPOS:
        return f"{NOMBRES[t]} [y(t-1..{spec.get('p', 3)})]" + extra
    return NOMBRES.get(t, t)


# ══════════════════════════════════════════════════════════════════════════════
# 6. ISEC en Python (igual a dashboard-web/lib/sentimiento.ts → calcularISEC)
# ══════════════════════════════════════════════════════════════════════════════
def isec_desde_agregado(ag: pd.DataFrame, freq: str = "M", pesos=(0.7, 0.1, 0.1, 0.1)) -> pd.DataFrame:
    """ag: columnas fecha, n, n_pos, n_neg, suma_pol (una categoría/universo)."""
    L = {"D": 365, "W": 52, "M": 12}[freq]
    regla = {"D": "D", "W": "W-MON", "M": "MS"}[freq]
    a = ag.copy()
    a["fecha"] = pd.to_datetime(a["fecha"])
    a = a.set_index("fecha").sort_index()
    a = a.reindex(pd.date_range(a.index.min(), a.index.max(), freq=regla))
    a["n"] = a["n"].fillna(0)
    sps = a["suma_pol"] / a["n"].replace(0, np.nan)
    med = a["n"].rolling(L, min_periods=math.ceil(L / 2)).median()
    sg = np.sign(sps).fillna(0)
    lnatm = np.log(a["n"].replace(0, np.nan) / med) * sg
    idm = (np.minimum(a["n_pos"], a["n_neg"]) / a["n"].replace(0, np.nan)) * -sg
    vs = -sps.rolling(L, min_periods=max(3, math.ceil(math.ceil(L / 2) / 2))).std()
    w1, w2, w3, w4 = pesos
    return pd.DataFrame({"sps": sps, "lnatm": lnatm, "idm": idm, "vs": vs,
                         "isec": w1 * sps + w2 * lnatm + w3 * idm + w4 * vs})
