"""Relleno profundo, auditoría de cobertura y profundización del histórico.

Objetivo: que TODOS los días tengan la misma densidad de muestreo que el scraper
diario actual (ventanas de 1 día + barrido general), para que el volumen de noticias
(ATM del ISEC) no tenga saltos artificiales por cómo se recolectó.

Tres colas, todas reanudables (estado/*.json) y procesadas de lo reciente a lo viejo:

  relleno      ventanas con barrido general: huecos sin noticias + días débiles de la
               auditoría. Categorías con búsqueda ADAPTATIVA (semana → días si Google
               satura en 100) + barrido site:medio día por día (→ secciones si satura).
  auditoría    días con cobertura < 35% de la mediana de sus 8 mismos días de semana previos (o 0) en el
               último año → se reencolan en `relleno` (máx. 2 reintentos por día).
  profundizar  histórico 2016→jul-2026 (recolectado con ventanas semanales/mensuales):
               se re-recorre por semanas con búsqueda adaptativa (sin barrido).

    python -m pipelines.noticias.relleno plan --desde 2026-07-09 --hasta 2026-10-17
    python -m pipelines.noticias.relleno relleno --minutos 60
    python -m pipelines.noticias.relleno auditar
    python -m pipelines.noticias.relleno profundizar --minutos 60
    python -m pipelines.noticias.relleno estado
"""
from __future__ import annotations

import argparse
import sys
import time
from datetime import date, timedelta

import pandas as pd

from .almacen import Almacen, rango_dias
from .config import Config
from .gnews import Bloqueado, GoogleNews
from .scraper import SATURA, _guardar, _items_a_filas, hoy_rd

INICIO_HISTORICO = date(2016, 1, 1)
FIN_LEGADO = date(2026, 7, 8)          # último día del scraper viejo (isec_news.db)


# ══════════════════════════════════════════════════════════════════════════════
# Búsquedas
# ══════════════════════════════════════════════════════════════════════════════
def buscar_adaptativo(gn: GoogleNews, q: str, a: date, b: date) -> tuple[list[dict], list[date], int]:
    """Busca en [a, b]; si Google devuelve ≥ SATURA (truncado en 100) parte en días.
    → (items, días que siguen saturados, nº de consultas)"""
    items = gn.buscar(q, a, b)
    n = 1
    saturados: list[date] = []
    if len(items) >= SATURA and b > a:
        for d in rango_dias(a, b):
            it = gn.buscar(q, d, d)
            n += 1
            items += it
            if len(it) >= SATURA:
                saturados.append(d)
    elif len(items) >= SATURA:
        saturados.append(a)
    return items, saturados, n


def barrido_dia(gn: GoogleNews, cfg: Config, d: date, medios: list[dict] | None = None) -> tuple[list[dict], int]:
    """site:medio del día d; si satura, por secciones. → (filas, nº consultas)"""
    filas, n = [], 0
    for m in medios or cfg.medios["medios"]:
        dom = m["dominio"]
        items = gn.buscar(f"site:{dom}", d, d)
        n += 1
        todos = list(items)
        if len(items) >= SATURA and m.get("secciones"):
            for sec in m["secciones"]:
                todos += gn.buscar(f"site:{dom}/{sec}", d, d)
                n += 1
        filas += _items_a_filas(todos, f"b:{dom}")
    return filas, n


# ══════════════════════════════════════════════════════════════════════════════
# Cola de relleno (ventanas con barrido)
# ══════════════════════════════════════════════════════════════════════════════
def _semanas(a: date, b: date) -> list[dict]:
    """Ventanas de ≤ 7 días, de la más reciente a la más vieja."""
    out, fin = [], b
    while fin >= a:
        ini = max(a, fin - timedelta(days=6))
        out.append({"a": str(ini), "b": str(fin), "barrido": True, "i": 0, "dia": 0, "medio": 0, "cat_hecho": False})
        fin = ini - timedelta(days=1)
    return out


def plan_relleno(alm: Almacen, desde: date, hasta: date, motivo: str = "manual") -> dict:
    plan = alm.estado("relleno_profundo", {"ventanas": []})
    existentes = {(v["a"], v["b"]) for v in plan["ventanas"]}
    nuevas = [v for v in _semanas(desde, hasta) if (v["a"], v["b"]) not in existentes]
    for v in nuevas:
        v["motivo"] = motivo
    plan["ventanas"] = sorted(plan["ventanas"] + nuevas, key=lambda v: v["b"], reverse=True)
    alm.guardar_estado("relleno_profundo", plan)
    print(f"[relleno] plan: {len(plan['ventanas'])} ventanas pendientes (+{len(nuevas)} {motivo})")
    return plan


def relleno(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 60) -> dict:
    t0 = time.time()
    plan = alm.estado("relleno_profundo", {"ventanas": []})
    res = {"consultas": 0, "nuevos": 0, "ventanas_completas": 0, "dias_saturados": [], "abortado": None}

    def tiempo():
        if (time.time() - t0) / 60 > minutos:
            raise TimeoutError

    try:
        while plan["ventanas"]:
            v = plan["ventanas"][0]
            a, b = date.fromisoformat(v["a"]), date.fromisoformat(v["b"])
            # 1) categorías con búsqueda adaptativa
            if not v.get("cat_hecho"):
                tareas = cfg.tareas_query(b)
                while v["i"] < len(tareas):
                    tiempo()
                    cat, q = tareas[v["i"]]
                    items, sat, nq = buscar_adaptativo(gn, q, a, b)
                    n, _ = _guardar(alm, _items_a_filas(items, f"q:{cat}"))
                    res["consultas"] += nq; res["nuevos"] += n
                    res["dias_saturados"] += [f"{d}:{cat}" for d in sat]
                    v["i"] += 1
                    if v["i"] % 20 == 0:
                        alm.guardar_estado("relleno_profundo", plan)
                v["cat_hecho"] = True
                alm.guardar_estado("relleno_profundo", plan)
            # 2) barrido general día por día
            if v.get("barrido"):
                dias = list(rango_dias(a, b))
                medios = cfg.medios["medios"]
                while v["dia"] < len(dias):
                    d = dias[v["dia"]]
                    while v["medio"] < len(medios):
                        tiempo()
                        filas, nq = barrido_dia(gn, cfg, d, [medios[v["medio"]]])
                        n, _ = _guardar(alm, filas)
                        res["consultas"] += nq; res["nuevos"] += n
                        v["medio"] += 1
                    v["dia"] += 1; v["medio"] = 0
                    alm.guardar_estado("relleno_profundo", plan)
            print(f"  [relleno] ventana {a}→{b} completa · total nuevos {res['nuevos']}", flush=True)
            plan["ventanas"].pop(0)
            res["ventanas_completas"] += 1
            alm.guardar_estado("relleno_profundo", plan)
    except (Bloqueado, TimeoutError) as e:
        res["abortado"] = type(e).__name__
        alm.guardar_estado("relleno_profundo", plan)
    res["pendientes"] = len(plan["ventanas"])
    res["minutos"] = round((time.time() - t0) / 60, 1)
    res["dias_saturados"] = res["dias_saturados"][:50]
    alm.bitacora({"evento": "relleno_profundo", **res})
    print(f"[relleno] {res}")
    return res


# ══════════════════════════════════════════════════════════════════════════════
# Auditoría de cobertura
# ══════════════════════════════════════════════════════════════════════════════
def cobertura_diaria(alm: Almacen, desde: date, hasta: date) -> pd.DataFrame:
    """Por día: n total, n de categorías (q:) y n del barrido (b:)."""
    art = alm.leer_rango("articulos", desde, hasta, columnas=["fecha", "origenes"])
    idx = pd.date_range(desde, hasta, freq="D")
    if art.empty:
        return pd.DataFrame({"n": 0, "n_q": 0, "n_b": 0}, index=idx)
    art["fecha"] = pd.to_datetime(art["fecha"])
    o = art["origenes"].map(lambda x: list(x) if x is not None else [])
    art["q"] = o.map(lambda x: any(str(s).startswith("q:") for s in x))
    art["b"] = o.map(lambda x: any(str(s).startswith("b:") for s in x))
    g = art.groupby("fecha").agg(n=("q", "size"), n_q=("q", "sum"), n_b=("b", "sum"))
    return g.reindex(idx, fill_value=0)


def auditar(alm: Almacen, dias_atras: int = 365, umbral: float = 0.35, max_reintentos: int = 2) -> dict:
    """Encola en `relleno` los días con cobertura de categorías anormalmente baja."""
    hoy = hoy_rd()
    hasta = hoy - timedelta(days=2)
    desde = max(INICIO_HISTORICO, hoy - timedelta(days=dias_atras))
    cob = cobertura_diaria(alm, desde - timedelta(days=70), hasta)
    # referencia = mediana de los 8 mismos días de la semana anteriores (un sábado
    # se compara con sábados: los fines de semana tienen menos noticias por naturaleza)
    nq = cob["n_q"].astype(float).where(cob["n_q"] > 0)
    ref = nq.groupby(cob.index.weekday).transform(lambda s: s.rolling(8, min_periods=3).median().shift(1))
    debil = cob[(cob.index >= pd.Timestamp(desde)) & ((cob["n_q"] == 0) | (cob["n_q"] < umbral * ref.fillna(0)))]
    hist = alm.estado("auditoria", {"reintentos": {}})
    plan = alm.estado("relleno_profundo", {"ventanas": []})
    en_plan = set()
    for v in plan["ventanas"]:
        for d in rango_dias(date.fromisoformat(v["a"]), date.fromisoformat(v["b"])):
            en_plan.add(str(d))
    nuevos = []
    for f in debil.index:
        k = str(f.date())
        if k in en_plan or hist["reintentos"].get(k, 0) >= max_reintentos:
            continue
        hist["reintentos"][k] = hist["reintentos"].get(k, 0) + 1
        nuevos.append(k)
    for k in nuevos:
        plan["ventanas"].append({"a": k, "b": k, "barrido": True, "i": 0, "dia": 0, "medio": 0,
                                 "cat_hecho": False, "motivo": "auditoria"})
    plan["ventanas"].sort(key=lambda v: v["b"], reverse=True)
    alm.guardar_estado("relleno_profundo", plan)
    hist["ultima"] = str(hoy)
    hist["dias_debiles"] = len(debil)
    alm.guardar_estado("auditoria", hist)
    res = {"dias_revisados": int((cob.index >= pd.Timestamp(desde)).sum()), "debiles": len(debil),
           "reencolados": len(nuevos), "agotados": sum(1 for v in hist["reintentos"].values() if v >= max_reintentos)}
    alm.bitacora({"evento": "auditoria", **res, "dias": nuevos[:40]})
    print(f"[auditoria] {res}")
    return res


# ══════════════════════════════════════════════════════════════════════════════
# Profundización del histórico (categorías, búsqueda adaptativa, sin barrido)
# ══════════════════════════════════════════════════════════════════════════════
def profundizar(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 60) -> dict:
    t0 = time.time()
    est = alm.estado("profundizar", {"cursor": str(FIN_LEGADO), "i": 0, "hecho": False})
    res = {"consultas": 0, "nuevos": 0, "semanas": 0, "abortado": None}
    if est.get("hecho"):
        print("[profundizar] histórico completo"); return {**res, "hecho": True}
    try:
        cursor = date.fromisoformat(est["cursor"])
        while cursor >= INICIO_HISTORICO:
            a = max(INICIO_HISTORICO, cursor - timedelta(days=6))
            tareas = cfg.tareas_query(cursor)
            while est["i"] < len(tareas):
                if (time.time() - t0) / 60 > minutos:
                    raise TimeoutError
                cat, q = tareas[est["i"]]
                items, _, nq = buscar_adaptativo(gn, q, a, cursor)
                n, _ = _guardar(alm, _items_a_filas(items, f"q:{cat}"))
                res["consultas"] += nq; res["nuevos"] += n
                est["i"] += 1
                if est["i"] % 20 == 0:
                    alm.guardar_estado("profundizar", est)
            res["semanas"] += 1
            cursor = a - timedelta(days=1)
            est["cursor"], est["i"] = str(cursor), 0
            alm.guardar_estado("profundizar", est)
        est["hecho"] = True
    except (Bloqueado, TimeoutError) as e:
        res["abortado"] = type(e).__name__
    alm.guardar_estado("profundizar", est)
    res["cursor"] = est["cursor"]
    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "profundizar", **res})
    print(f"[profundizar] {res}")
    return res


def estado(alm: Almacen) -> dict:
    rel = alm.estado("relleno_profundo", {"ventanas": []})
    pro = alm.estado("profundizar", {"cursor": str(FIN_LEGADO), "hecho": False})
    aud = alm.estado("auditoria", {})
    out = {
        "relleno_ventanas": len(rel["ventanas"]),
        "relleno_rango": [rel["ventanas"][-1]["a"], rel["ventanas"][0]["b"]] if rel["ventanas"] else None,
        "profundizar_cursor": pro.get("cursor"), "profundizar_hecho": pro.get("hecho"),
        "auditoria_debiles": aud.get("dias_debiles"),
    }
    total = (FIN_LEGADO - INICIO_HISTORICO).days
    hecho = (FIN_LEGADO - date.fromisoformat(pro.get("cursor", str(FIN_LEGADO)))).days
    out["profundizar_avance_pct"] = round(100 * hecho / total, 1)
    print(out)
    return out


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["plan", "relleno", "auditar", "profundizar", "estado"])
    ap.add_argument("--dir", default=None)
    ap.add_argument("--desde"); ap.add_argument("--hasta")
    ap.add_argument("--minutos", type=float, default=60)
    a = ap.parse_args(argv)
    alm, cfg = Almacen(a.dir), Config()
    if a.cmd == "plan":
        plan_relleno(alm, date.fromisoformat(a.desde), date.fromisoformat(a.hasta))
    elif a.cmd == "relleno":
        relleno(alm, cfg, GoogleNews(), a.minutos)
    elif a.cmd == "auditar":
        auditar(alm)
    elif a.cmd == "profundizar":
        profundizar(alm, cfg, GoogleNews(), a.minutos)
    else:
        estado(alm)
    return 0


if __name__ == "__main__":
    sys.exit(main())
