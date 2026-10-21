"""Etiquetado + agregados diarios + ISEP (Kalman) + Markov → Supabase.

    python -m pipelines.noticias.indices                 # incremental (sube solo lo que cambió)
    python -m pipelines.noticias.indices --completo      # re-sube todo

Universos (se calculan aparte, ver investigación §16):
    query   noticias que trajo la búsqueda de la categoría (set congelado del paper)
    amplio  query ∪ etiquetado por palabras clave sobre TODO lo capturado (incl. barrido)

Tablas Supabase (sql/noticias_schema.sql):
    sent_agregado   freq D (sectores) / M (subcategorías): n, n_pos, n_neu, n_neg, suma_pol, suma_pol2
    sent_latente    ISEP: estado filtrado/suavizado del modelo de nivel latente (D/W/M)
    sent_latente_param  parámetros (mu, theta, varianzas, q señal/ruido, % ruido)
    sent_markov     P(régimen de estrés) sobre el ISEP suavizado (W/M)
    sent_noticias   últimas noticias (titular + medio + enlace + puntaje; SIN texto)
    sent_categorias / sent_modelos   metadatos

El ISEC (pesos editables) se calcula en el navegador a partir de sent_agregado.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import sys
import time
import warnings
from datetime import date, timedelta

import numpy as np
import pandas as pd

from .almacen import Almacen, ahora
from .config import Config

warnings.filterwarnings("ignore")
DIAS_NOTICIAS = 60


# ══════════════════════════════════════════════════════════════════════════════
# 1. ETIQUETADO (caché por día; se recalcula si cambian categorías o llega texto)
# ══════════════════════════════════════════════════════════════════════════════
def actualizar_etiquetas(alm: Almacen, cfg: Config) -> int:
    h = cfg.hash_etiquetado
    rehechos = 0
    for d in alm.dias("articulos"):
        meta = alm.leer_dia("articulos", d, columnas=["id", "texto_estado", "dominio"])
        con_txt = ",".join(sorted(meta.loc[meta["texto_estado"].eq("ok"), "id"])) + "|" +             ",".join(sorted(meta.loc[meta["dominio"].notna(), "id"]))
        firma = h + hashlib.sha1(con_txt.encode()).hexdigest()[:8]
        prev = alm.leer_dia("etiquetas", d)
        if len(prev) and prev["hash_config"].iloc[0] == firma and set(prev["id"]) == set(meta["id"]):
            continue
        art = alm.leer_dia("articulos", d, columnas=["id", "titulo", "texto", "texto_estado", "origenes", "dominio"])
        filas = []
        for r in art.itertuples(index=False):
            orig = list(r.origenes) if r.origenes is not None else []
            clave, rd = cfg.etiquetar(r.titulo, r.texto if r.texto_estado == "ok" else None, r.dominio)
            filas.append({
                "id": r.id, "fecha": d,
                "cats_query": sorted({o[2:] for o in orig if o.startswith("q:")}),
                "cats_clave": clave, "rd": rd, "hash_config": firma,
            })
        alm.escribir_dia("etiquetas", d, pd.DataFrame(filas))
        rehechos += 1
    return rehechos


# ══════════════════════════════════════════════════════════════════════════════
# 2. AGREGADOS
# ══════════════════════════════════════════════════════════════════════════════
def tabla_articulos(alm: Almacen, modelo: str) -> pd.DataFrame:
    et = alm.leer_rango("etiquetas")
    pu = alm.leer_rango("puntajes", modelo=modelo, columnas=["id", "polaridad", "etiqueta"])
    df = et.merge(pu, on="id", how="inner")
    df = df[df["rd"].fillna("?") != "no"]          # fuera lo claramente extranjero
    df["fecha"] = pd.to_datetime(df["fecha"])
    # una nota republicada otro día (mismo titular y medio) cuenta una sola vez: la primera
    return df.sort_values("fecha").drop_duplicates("id", keep="first").reset_index(drop=True)


def _miembros(df: pd.DataFrame, cfg: Config) -> pd.DataFrame:
    """Expande a filas (id, categoria, universo). Sector = prefijo antes del punto."""
    sect = {s.id for s in cfg.sectores()}
    filas = []
    for r in df.itertuples(index=False):
        q = set(r.cats_query) if r.cats_query is not None else set()
        k = set(r.cats_clave) if r.cats_clave is not None else set()
        amplio = q | k
        sq = {c.split(".")[0] for c in q} & sect
        sa = {c.split(".")[0] for c in amplio} & sect
        filas.append((r.id, "TODO", "query"))
        filas.append((r.id, "TODO", "amplio"))
        filas += [(r.id, s, "query") for s in sq] + [(r.id, s, "amplio") for s in sa]
        filas += [(r.id, c, "query") for c in q] + [(r.id, c, "amplio") for c in amplio]
    return pd.DataFrame(filas, columns=["id", "categoria_id", "universo"])


def agregados(df: pd.DataFrame, cfg: Config, modelo: str) -> pd.DataFrame:
    m = _miembros(df, cfg).merge(df[["id", "fecha", "polaridad", "etiqueta"]], on="id")
    nivel = {c.id: c.nivel for c in cfg.categorias.values()}
    m["nivel"] = m["categoria_id"].map(nivel).fillna(2).astype(int)
    m = m[m["categoria_id"].isin(cfg.categorias)]
    m["pol2"] = m["polaridad"] ** 2
    # TODO y sectores: D, W (lunes) y M ; subcategorías: solo M
    partes = []
    alto = m[m["nivel"] <= 1]
    partes.append(alto.assign(freq="D", fecha_p=alto["fecha"]))
    partes.append(alto.assign(freq="W", fecha_p=alto["fecha"] - pd.to_timedelta(alto["fecha"].dt.weekday, unit="D")))
    partes.append(m.assign(freq="M", fecha_p=m["fecha"].dt.to_period("M").dt.to_timestamp()))
    m = pd.concat(partes, ignore_index=True)
    for e in ("POS", "NEU", "NEG"):
        m[f"n_{e.lower()}"] = (m["etiqueta"] == e).astype(int)
    g = m.groupby(["freq", "fecha_p", "categoria_id", "universo"]).agg(
        n=("id", "size"), n_pos=("n_pos", "sum"), n_neu=("n_neu", "sum"), n_neg=("n_neg", "sum"),
        suma_pol=("polaridad", "sum"), suma_pol2=("pol2", "sum"),
    ).reset_index().rename(columns={"fecha_p": "fecha"})
    g["modelo_id"] = modelo
    g["fecha"] = pd.to_datetime(g["fecha"]).dt.strftime("%Y-%m-%d")
    g["suma_pol"] = g["suma_pol"].round(5)
    g["suma_pol2"] = g["suma_pol2"].round(5)
    return g


# ══════════════════════════════════════════════════════════════════════════════
# 3. ISEP: sentimiento latente (nivel AR(1) + ruido de medición ∝ 1/n)
#    Igual a la clase `Latente` de ISEC_RD_enfoque_1.ipynb
# ══════════════════════════════════════════════════════════════════════════════
def _latente_cls():
    from statsmodels.tsa.statespace.mlemodel import MLEModel

    class Latente(MLEModel):
        def __init__(self, y, n):
            super().__init__(np.asarray(y, float), k_states=1, k_posdef=1,
                             initialization="stationary")
            self.n_t = np.clip(np.asarray(n, float), 1e-6, None)
            self["design"] = np.ones((1, 1)); self["selection"] = np.ones((1, 1))
            self["obs_cov"] = np.zeros((1, 1, self.nobs))

        param_names = property(lambda s: ["mu", "theta", "s2_eta", "s2_eps"])
        start_params = property(lambda s: np.array([np.nanmean(s.endog), .85,
                                                    .1 * np.nanvar(s.endog), .5 * np.nanvar(s.endog)]))

        def transform_params(self, u):
            return np.array([u[0], 1 / (1 + np.exp(-u[1])), np.exp(u[2]), np.exp(u[3])])

        def untransform_params(self, p):
            th = np.clip(p[1], 1e-4, 1 - 1e-4)
            return np.array([p[0], np.log(th / (1 - th)), np.log(p[2]), np.log(p[3])])

        def update(self, params, **kw):
            params = super().update(params, **kw)
            mu, th, s2e, s2o = params
            self["transition", 0, 0] = th
            self["state_intercept", 0, 0] = (1 - th) * mu
            self["state_cov", 0, 0] = s2e
            self["obs_cov"] = (s2o / self.n_t).reshape(1, 1, -1)
            return params

    return Latente


def serie_periodo(ag: pd.DataFrame, freq: str) -> pd.DataFrame:
    """ag: filas diarias de UNA categoría/universo → y (SPS medio), n por período."""
    s = ag.copy()
    s["fecha"] = pd.to_datetime(s["fecha"])
    if freq == "W":
        s["p"] = s["fecha"] - pd.to_timedelta(s["fecha"].dt.weekday, unit="D")
        idx = pd.date_range(s["p"].min(), s["p"].max(), freq="W-MON")
    elif freq == "M":
        s["p"] = s["fecha"].dt.to_period("M").dt.to_timestamp()
        idx = pd.date_range(s["p"].min(), s["p"].max(), freq="MS")
    else:
        s["p"] = s["fecha"]
        idx = pd.date_range(s["p"].min(), s["p"].max(), freq="D")
    g = s.groupby("p").agg(n=("n", "sum"), sp=("suma_pol", "sum")).reindex(idx)
    g["n"] = g["n"].fillna(0)
    g["y"] = g["sp"] / g["n"].replace(0, np.nan)
    return g[["y", "n"]]


def isep(ag_d: pd.DataFrame, cfg: Config, modelo: str) -> tuple[pd.DataFrame, pd.DataFrame]:
    Latente = _latente_cls()
    filas, params = [], []
    cats = ["TODO"] + [s.id for s in cfg.sectores()]
    for (cat, uni), sub in ag_d[ag_d["categoria_id"].isin(cats)].groupby(["categoria_id", "universo"]):
        if cat == "TODO" and uni == "amplio":
            continue        # TODO es idéntico en ambos universos
        for freq in ("D", "W", "M"):
            t = serie_periodo(sub, freq)
            # arranque: desde el primer período con cobertura razonable
            minimo = {"D": 1, "W": 3, "M": 10}[freq]
            ok = t.index[t["n"] >= minimo]
            if len(ok) < 24:
                continue
            t = t.loc[ok[0]:]
            # períodos sin noticias = observación faltante (el filtro interpola)
            y = t["y"].where(t["n"] > 0)
            try:
                r = Latente(y.values, t["n"].replace(0, 1).values).fit(disp=False, maxiter=300)
            except Exception as e:
                print(f"  [isep] {cat}/{uni}/{freq} no convergió: {e}")
                continue
            mu, th, s2e, s2o = r.params
            nmed = float(t.loc[t["n"] > 0, "n"].median())
            var_obs = s2o / nmed                       # ruido típico de una observación
            var_lat = s2e / max(1 - th ** 2, 1e-6)     # varianza estacionaria de la señal
            params.append({
                "freq": freq, "categoria_id": cat, "modelo_id": modelo, "universo": uni,
                "mu": float(mu), "theta": float(th), "s2_eta": float(s2e), "s2_eps": float(s2o),
                "q": float(s2e / s2o), "pct_ruido": float(100 * var_obs / (var_obs + var_lat)),
                "n_obs": int(len(t)), "n_mediana": nmed, "estimado_en": ahora(),
            })
            fs, ss = r.filtered_state[0], r.smoothed_state[0]
            fv, sv = r.filtered_state_cov[0, 0], r.smoothed_state_cov[0, 0]
            for k, f in enumerate(t.index):
                filas.append({
                    "freq": freq, "fecha": f.strftime("%Y-%m-%d"), "categoria_id": cat,
                    "modelo_id": modelo, "universo": uni,
                    "observado": None if np.isnan(y.iloc[k]) else round(float(y.iloc[k]), 5),
                    "n": int(t["n"].iloc[k]),
                    "filtrado": round(float(fs[k]), 5), "filtrado_se": round(float(np.sqrt(fv[k])), 5),
                    "suavizado": round(float(ss[k]), 5), "suavizado_se": round(float(np.sqrt(sv[k])), 5),
                })
    return pd.DataFrame(filas), pd.DataFrame(params)


def markov(lat: pd.DataFrame, modelo: str) -> pd.DataFrame:
    """P(estrés) con Markov-switching de 2 regímenes (media y varianza conmutan)
    sobre el ISEP suavizado, como en la investigación. Solo TODO y GEN, W/M."""
    from statsmodels.tsa.regime_switching.markov_regression import MarkovRegression
    filas = []
    for (freq, cat, uni), sub in lat.groupby(["freq", "categoria_id", "universo"]):
        if freq == "D" or cat not in ("TODO", "GEN"):
            continue
        x = sub.set_index(pd.to_datetime(sub["fecha"]))["suavizado"].astype(float)
        x.index.freq = None
        try:
            ms = MarkovRegression(x.reset_index(drop=True), k_regimes=2, trend="c",
                                  switching_variance=True).fit(search_reps=10, disp=False)
            consts = [float(ms.params[f"const[{i}]"]) for i in range(2)]
            est = int(np.argmin(consts))          # régimen de estrés = media más baja
            P = np.asarray(ms.smoothed_marginal_probabilities)[:, est]
        except Exception as e:
            print(f"  [markov] {cat}/{uni}/{freq}: {e}")
            continue
        for f, p in zip(x.index, P):
            filas.append({"freq": freq, "fecha": f.strftime("%Y-%m-%d"), "categoria_id": cat,
                          "modelo_id": modelo, "universo": uni, "p_estres": round(float(p), 4)})
    return pd.DataFrame(filas)


# ══════════════════════════════════════════════════════════════════════════════
# 4. SUPABASE
# ══════════════════════════════════════════════════════════════════════════════
def _sb():
    from supabase import create_client
    return create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_KEY"])


def _upsert(sb, tabla: str, df: pd.DataFrame, conflicto: str, lote: int = 1000) -> int:
    if df is None or df.empty:
        return 0
    df = df.drop_duplicates(subset=[c.strip() for c in conflicto.split(",")], keep="last")
    enteras = {"n", "n_pos", "n_neu", "n_neg", "n_oro", "n_obs", "n_queries", "nivel"}
    recs = df.astype(object).where(df.notna(), None).to_dict("records")
    for r in recs:
        for k in enteras & r.keys():
            if r[k] is not None:
                r[k] = int(r[k])
    for i in range(0, len(recs), lote):
        for intento in range(4):
            try:
                sb.table(tabla).upsert(recs[i:i + lote], on_conflict=conflicto).execute()
                break
            except Exception as e:
                if intento == 3:
                    raise
                print(f"  reintento {tabla}: {str(e)[:120]}"); time.sleep(5 * (intento + 1))
    return len(recs)


def _solo_cambios(alm: Almacen, nombre: str, df: pd.DataFrame, claves: list[str],
                  completo: bool) -> pd.DataFrame:
    """Compara con lo último subido (estado/subido_<nombre>.parquet) y devuelve solo lo nuevo/cambiado."""
    p = alm.base / "estado" / f"subido_{nombre}.parquet"
    if completo or not p.exists() or df.empty:
        return df
    prev = pd.read_parquet(p)
    cols = list(df.columns)
    m = df.merge(prev[cols], on=cols, how="left", indicator=True)
    return m[m["_merge"] == "left_only"][cols]


def _guardar_subido(alm: Almacen, nombre: str, df: pd.DataFrame) -> None:
    p = alm.base / "estado" / f"subido_{nombre}.parquet"
    p.parent.mkdir(parents=True, exist_ok=True)
    df.to_parquet(p, index=False, compression="zstd")


def noticias_recientes(alm: Almacen, cfg: Config, modelo: str) -> pd.DataFrame:
    desde = date.today() - timedelta(days=DIAS_NOTICIAS)
    art = alm.leer_rango("articulos", desde, columnas=["id", "fecha", "titulo", "medio", "dominio", "url", "url_gn"])
    et = alm.leer_rango("etiquetas", desde)
    pu = alm.leer_rango("puntajes", desde, modelo=modelo, columnas=["id", "polaridad", "etiqueta", "base"])
    df = art.merge(et[["id", "cats_query", "cats_clave", "rd"]], on="id").merge(pu, on="id")
    df = df[df["rd"].fillna("?") != "no"]
    sect = {s.id for s in cfg.sectores()}

    def sectores(r):
        cs = set(r.cats_query if r.cats_query is not None else []) | set(r.cats_clave if r.cats_clave is not None else [])
        return sorted({c.split(".")[0] for c in cs} & sect)

    df = df.sort_values("fecha").drop_duplicates("id", keep="last")
    df["sectores"] = [sectores(r) for r in df.itertuples(index=False)]
    df = df[df["sectores"].map(len) > 0]
    return pd.DataFrame({
        "id": df["id"], "fecha": pd.to_datetime(df["fecha"]).dt.strftime("%Y-%m-%d"),
        "titulo": df["titulo"], "medio": df["medio"],
        "url": df["url"].fillna(df["url_gn"]), "sectores": df["sectores"],
        "modelo_id": modelo, "polaridad": df["polaridad"].astype(float).round(4),
        "etiqueta": df["etiqueta"], "base": df["base"],
    })


def metadatos(cfg: Config, alm: Almacen) -> tuple[pd.DataFrame, pd.DataFrame]:
    cats = pd.DataFrame([{
        "id": c.id, "nombre": c.nombre, "nivel": c.nivel, "padre": c.padre, "origen": c.origen,
        "congelada": c.congelada, "activa_desde": str(c.activa_desde),
        "n_queries": len(c.queries),
        "palabras_clave": [" | ".join(g) for g in c.palabras_clave],
    } for c in cfg.categorias.values()])
    val = alm.estado("validacion_modelos", {})
    mods = pd.DataFrame([{
        "id": m["id"], "nombre": m["nombre"], "tipo": m["tipo"],
        "idiomas": m.get("idiomas", ["es"]), "activo": bool(m.get("activo", True)),
        "principal": bool(m.get("principal", False)),
        "f1_oro": val.get(m["id"], {}).get("f1_macro"), "kappa_oro": val.get(m["id"], {}).get("kappa"),
        "n_oro": val.get(m["id"], {}).get("n"),
    } for m in cfg.modelos])
    return cats, mods


# ══════════════════════════════════════════════════════════════════════════════
def correr(alm: Almacen, cfg: Config, completo: bool = False, subir: bool = True) -> dict:
    t0 = time.time()
    res = {"etiquetas_dias": actualizar_etiquetas(alm, cfg)}
    print(f"[indices] etiquetas recalculadas en {res['etiquetas_dias']} días", flush=True)
    sb = _sb() if subir else None
    cats, mods = metadatos(cfg, alm)
    if sb:
        _upsert(sb, "sent_categorias", cats, "id")
        _upsert(sb, "sent_modelos", mods, "id")
        # categorías borradas del YAML
        vivas = set(cats["id"])
        ex = sb.table("sent_categorias").select("id").execute().data
        for r in ex:
            if r["id"] not in vivas:
                sb.table("sent_categorias").delete().eq("id", r["id"]).execute()

    for spec in cfg.modelos_activos():
        mid = spec["id"]
        df = tabla_articulos(alm, mid)
        if df.empty:
            continue
        ag = agregados(df, cfg, mid)
        ag_d = ag[ag["freq"] == "D"]
        lat, par = isep(ag_d, cfg, mid)
        mk = markov(lat, mid)
        print(f"[indices] {mid}: agregados={len(ag):,} latente={len(lat):,} markov={len(mk):,}", flush=True)
        if sb:
            for nombre, tabla, d, claves in [
                ("agregado", "sent_agregado", ag, "freq,fecha,categoria_id,modelo_id,universo"),
                ("latente", "sent_latente", lat, "freq,fecha,categoria_id,modelo_id,universo"),
                ("markov", "sent_markov", mk, "freq,fecha,categoria_id,modelo_id,universo"),
            ]:
                cambios = _solo_cambios(alm, f"{nombre}_{mid}", d, claves.split(","), completo)
                res[f"{tabla}_{mid}"] = _upsert(sb, tabla, cambios, claves)
                _guardar_subido(alm, f"{nombre}_{mid}", d)
            _upsert(sb, "sent_latente_param", par, "freq,categoria_id,modelo_id,universo")
            if spec.get("principal"):
                nr = noticias_recientes(alm, cfg, mid)
                res["noticias"] = _upsert(sb, "sent_noticias", nr, "id,modelo_id")
                lim = (date.today() - timedelta(days=DIAS_NOTICIAS)).isoformat()
                sb.table("sent_noticias").delete().lt("fecha", lim).execute()
    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "indices", **res})
    print(f"[indices] {res}")
    return res


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=None)
    ap.add_argument("--completo", action="store_true")
    ap.add_argument("--sin-subir", action="store_true")
    a = ap.parse_args(argv)
    correr(Almacen(a.dir), Config(), a.completo, not a.sin_subir)
    return 0


if __name__ == "__main__":
    sys.exit(main())
