"""Pronósticos oficiales diarios + historial de aciertos (mismo motor del Laboratorio).

    python -m pipelines.noticias.pronosticos              # corre config/pronosticos.yaml → Supabase
    python -m pipelines.noticias.pronosticos --sin-subir  # solo imprime

Por cada spec:
  · pred_nowcast  : pronóstico vigente del próximo dato (se reescribe a diario)
  · pred_vintage  : se CONGELA el primero emitido tras cerrar el mes objetivo
                    (sentimiento completo) y antes del dato oficial; luego se llena `real`
  · pred_metricas : métricas del backtest (RMSE/AR, Diebold-Mariano, dirección)
"""
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd
import yaml

RAIZ = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(RAIZ / "dashboard-web" / "public" / "lab"))
import laboratorio as L  # noqa: E402

CONFIG = Path(__file__).parent / "config" / "pronosticos.yaml"


def _sb():
    from supabase import create_client
    return create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SERVICE_KEY"])


def _todo(sb, tabla, cols, filtros) -> list[dict]:
    out = []
    for off in range(0, 500_000, 1000):
        q = sb.table(tabla).select(cols)
        for c, v in filtros:
            q = q.eq(c, v)
        d = q.order("fecha").range(off, off + 999).execute().data
        out += d
        if len(d) < 1000:
            break
    return out


def serie_macro(sb, vid) -> dict:
    d = _todo(sb, "series_datos", "fecha,valor", [("variable_id", vid)])
    return {"fechas": [r["fecha"] for r in d], "valores": [r["valor"] for r in d]}


def serie_sent(sb, fuente, cat, uni, modelo) -> dict:
    if fuente == "isep":
        d = _todo(sb, "sent_latente", "fecha,filtrado",
                  [("freq", "M"), ("categoria_id", cat), ("universo", uni), ("modelo_id", modelo)])
        return {"fechas": [r["fecha"] for r in d], "valores": [r["filtrado"] for r in d]}
    d = _todo(sb, "sent_agregado", "fecha,n,n_pos,n_neg,suma_pol",
              [("freq", "M"), ("categoria_id", cat), ("universo", uni), ("modelo_id", modelo)])
    if not d:
        return {"fechas": [], "valores": []}
    isec = L.isec_desde_agregado(pd.DataFrame(d), "M")
    col = "isec" if fuente == "isec" else "sps"
    s = isec[col]
    return {"fechas": [f.strftime("%Y-%m-%d") for f in s.index], "valores": [L._f(v) for v in s.values]}


def modelo_principal(sb) -> str:
    d = sb.table("sent_modelos").select("id").eq("principal", True).execute().data
    return d[0]["id"] if d else "pysentimiento_es"


def valor_real(obj: dict, transf: str, fecha: str, interanual: bool) -> tuple[float | None, float | None]:
    nivel = L.a_frecuencia(L._serie(obj["fechas"], obj["valores"]), "M", "promedio")
    y = L.transformar(nivel, transf, "M")
    f = pd.Timestamp(fecha)
    real = L._f(y.get(f, np.nan))
    ria = None
    if interanual and f in nivel.index and (f - pd.DateOffset(months=12)) in nivel.index:
        ria = L._f((nivel[f] / nivel[f - pd.DateOffset(months=12)] - 1) * 100)
    return real, ria


def correr(subir: bool = True) -> int:
    cfg = yaml.safe_load(CONFIG.read_text("utf-8"))
    sb = _sb()
    modelo_sent = modelo_principal(sb)
    hoy = pd.Timestamp(datetime.now(timezone.utc).date())
    ahora = datetime.now(timezone.utc).isoformat(timespec="seconds")
    cache: dict = {}
    fallas = 0
    for spec in cfg["specs"]:
        ob, se = spec["objetivo"], spec["sentimiento"]
        try:
            if ob["id"] not in cache:
                cache[ob["id"]] = serie_macro(sb, ob["id"])
            obj = cache[ob["id"]]
            clave = (se["fuente"], se["categoria"], se["universo"])
            if clave not in cache:
                cache[clave] = serie_sent(sb, *clave, modelo_sent)
            nombre_s = {"isec": "ISEC", "isep": "ISEP", "sps": "SPS"}[se["fuente"]] + f" {se['categoria']}"
            payload = {
                "objetivo": {"id": ob["id"], **obj, "agregacion": "promedio"},
                "frecuencia": spec.get("frecuencia", "M"),
                "transformacion": ob["transformacion"],
                "desde": spec.get("desde", "2017-01-01"),
                "escala_interanual": bool(ob.get("escala_interanual")),
                "exogenas": [{"id": nombre_s, "nombre": nombre_s, **cache[clave],
                              "rezago": int(se.get("rezago", 0)), "transformacion": "nivel", "agregacion": "promedio"}],
                "modelos": spec["modelos"],
                "backtest": spec.get("backtest", {}),
            }
            r = L.correr(payload)
        except Exception as e:
            fallas += 1
            print(f"[pronosticos] {spec['id']}: omitido — {type(e).__name__}: {str(e)[:300]}")
            continue

        fobj = r["fecha_pronostico"]
        congelar = hoy >= pd.Timestamp(fobj) + pd.DateOffset(months=1)
        filas_now, filas_met = [], []
        for m in r["modelos"]:
            if m["error"] or not m.get("pronostico"):
                print(f"  {spec['id']}/{m['id']}: {m['error']}")
                continue
            p = m["pronostico"]
            base = {"spec_id": spec["id"], "modelo_id": m["id"], "modelo_nombre": m["nombre"],
                    "objetivo": ob["id"], "descripcion": spec["descripcion"], "fecha_objetivo": fobj,
                    "emitido": ahora, "media": p["media"], "li95": p["li95"], "ls95": p["ls95"],
                    "interanual": p.get("interanual")}
            filas_now.append(base)
            mt = m.get("metricas", {})
            filas_met.append({"spec_id": spec["id"], "modelo_id": m["id"], "modelo_nombre": m["nombre"],
                              "descripcion": spec["descripcion"], "n": mt.get("n"), "rmse": mt.get("rmse"),
                              "rrmse_ar": mt.get("rrmse_ar"), "p_dm_ar": mt.get("p_dm_ar"),
                              "acierto_dir": mt.get("acierto_dir"), "actualizado": ahora})
            print(f"  {spec['id']:10s} {m['nombre']:28s} {fobj[:7]}: {p['media']}  RMSE/AR={mt.get('rrmse_ar')} DMp={mt.get('p_dm_ar')}")
        if not subir:
            continue
        if filas_now:
            sb.table("pred_nowcast").upsert(filas_now, on_conflict="spec_id,modelo_id").execute()
            sb.table("pred_metricas").upsert(filas_met, on_conflict="spec_id,modelo_id").execute()
            if congelar:   # insertar SOLO si no existe (nunca se reescribe)
                sb.table("pred_vintage").upsert(filas_now, on_conflict="spec_id,modelo_id,fecha_objetivo",
                                                ignore_duplicates=True).execute()
        # completar `real` de los congelados cuyo dato ya salió
        pend = sb.table("pred_vintage").select("modelo_id,fecha_objetivo").eq("spec_id", spec["id"]) \
            .is_("real", "null").execute().data
        for v in pend:
            real, ria = valor_real(obj, ob["transformacion"], v["fecha_objetivo"], bool(ob.get("escala_interanual")))
            if real is not None:
                sb.table("pred_vintage").update({"real": real, "real_interanual": ria}) \
                    .eq("spec_id", spec["id"]).eq("modelo_id", v["modelo_id"]) \
                    .eq("fecha_objetivo", v["fecha_objetivo"]).execute()
    print(f"[pronosticos] listo ({fallas} specs omitidos)")
    return 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sin-subir", action="store_true")
    a = ap.parse_args(argv)
    return correr(not a.sin_subir)


if __name__ == "__main__":
    sys.exit(main())
