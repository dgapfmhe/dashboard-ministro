"""Relleno de días, auditoría de cobertura y profundización del histórico.

PRINCIPIO (simetría de procesos): aunque los datos se presenten por semana o mes,
TODO se recolecta DÍA POR DÍA exactamente como el scraper diario —las búsquedas de
las categorías con ventana de 1 día + el barrido site:medio del día (por secciones si
Google satura en 100)—. Así cada día tiene la misma densidad de muestreo y el volumen
de noticias (ATM del ISEC) no tiene saltos artificiales por cómo se recolectó.

Colas reanudables (estado/*.json del repo de datos):

  relleno      cola de DÍAS: huecos sin noticias, rangos pedidos y días débiles de la
               auditoría. Cada día = categorías (1 día) + barrido general.
  auditoría    días con cobertura < 35% de la mediana de sus 8 mismos días de semana
               previos (o 0) en el último año → se agregan a la cola (máx. 2 reintentos).
  profundizar  histórico 2016→jul-2026 (recolectado antes con ventanas semanales/
               mensuales): se re-recorre DÍA POR DÍA con las categorías (sin barrido).

    python -m pipelines.noticias.relleno plan --desde 2026-07-13 --hasta 2026-08-23 [--al-frente] [--orden asc]
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
from .gnews import Bloqueado, GoogleNews, SinRed
from .scraper import SATURA, _guardar, _items_a_filas, hoy_rd

INICIO_HISTORICO = date(2016, 1, 1)
FIN_LEGADO = date(2026, 7, 8)          # último día del scraper viejo (isec_news.db)
PLAN = "relleno_dias"


# ══════════════════════════════════════════════════════════════════════════════
# Recolección de UN día (idéntica al scraper diario)
# ══════════════════════════════════════════════════════════════════════════════
def barrido_medio(gn: GoogleNews, m: dict, d: date) -> tuple[list[dict], int]:
    """site:medio del día d; si satura, por secciones. → (filas, nº consultas)"""
    dom = m["dominio"]
    items = gn.buscar(f"site:{dom}", d, d)
    n = 1
    todos = list(items)
    if len(items) >= SATURA and m.get("secciones"):
        for sec in m["secciones"]:
            todos += gn.buscar(f"site:{dom}/{sec}", d, d)
            n += 1
    return _items_a_filas(todos, f"b:{dom}"), n


# ══════════════════════════════════════════════════════════════════════════════
# Cola de días
# ══════════════════════════════════════════════════════════════════════════════
def _cargar_plan(alm: Almacen) -> dict:
    return alm.estado(PLAN, {"dias": []})


def plan_relleno(alm: Almacen, desde: date, hasta: date, motivo: str = "manual",
                 al_frente: bool = False, orden: str = "desc", barrido: bool = True) -> dict:
    """Agrega los días [desde, hasta] a la cola (sin duplicar). `al_frente` = prioridad."""
    plan = _cargar_plan(alm)
    ya = {u["d"] for u in plan["dias"]}
    dias = list(rango_dias(desde, hasta))
    if orden == "desc":
        dias.reverse()
    nuevos = [{"d": str(d), "motivo": motivo, "barrido": barrido, "i": 0, "medio": 0, "cat_hecho": False}
              for d in dias if str(d) not in ya]
    if al_frente:
        # si alguno ya estaba en la cola, se mueve al frente en el orden pedido
        pedidos = [str(d) for d in dias]
        existentes = {u["d"]: u for u in plan["dias"] if u["d"] in pedidos}
        frente = [existentes.get(k) or next(u for u in nuevos if u["d"] == k) for k in pedidos]
        plan["dias"] = frente + [u for u in plan["dias"] if u["d"] not in pedidos]
    else:
        plan["dias"] += nuevos
    alm.guardar_estado(PLAN, plan)
    print(f"[relleno] cola: {len(plan['dias'])} días (+{len(nuevos)} · {motivo})")
    return plan


def relleno(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 60,
            hasta_vaciar: set[str] | None = None) -> dict:
    """Procesa la cola de días. `hasta_vaciar`: parar cuando no quede ninguno de esos días."""
    t0 = time.time()
    plan = _cargar_plan(alm)
    res = {"consultas": 0, "nuevos": 0, "dias_completos": [], "abortado": None}
    medios = cfg.medios["medios"]

    def tiempo():
        if (time.time() - t0) / 60 > minutos:
            raise TimeoutError

    try:
        while plan["dias"]:
            if hasta_vaciar is not None and not any(u["d"] in hasta_vaciar for u in plan["dias"]):
                break
            u = plan["dias"][0]
            d = date.fromisoformat(u["d"])
            nuevos_dia = 0
            # 1) categorías con ventana de 1 día (igual que el diario)
            if not u.get("cat_hecho"):
                tareas = cfg.tareas_query(d)
                while u["i"] < len(tareas):
                    tiempo()
                    cat, q = tareas[u["i"]]
                    n, _ = _guardar(alm, _items_a_filas(gn.buscar(q, d, d), f"q:{cat}"))
                    res["consultas"] += 1; res["nuevos"] += n; nuevos_dia += n
                    u["i"] += 1
                    if u["i"] % 25 == 0:
                        alm.guardar_estado(PLAN, plan)
                u["cat_hecho"] = True
                alm.guardar_estado(PLAN, plan)
            # 2) barrido general del día
            if u.get("barrido", True):
                while u["medio"] < len(medios):
                    tiempo()
                    filas, nq = barrido_medio(gn, medios[u["medio"]], d)
                    n, _ = _guardar(alm, filas)
                    res["consultas"] += nq; res["nuevos"] += n; nuevos_dia += n
                    u["medio"] += 1
            plan["dias"].pop(0)
            res["dias_completos"].append(u["d"])
            alm.guardar_estado(PLAN, plan)
            print(f"  [relleno] {u['d']} completo (+{nuevos_dia}) · quedan {len(plan['dias'])} días", flush=True)
    except (Bloqueado, TimeoutError, SinRed) as e:
        res["abortado"] = type(e).__name__
        alm.guardar_estado(PLAN, plan)
    res["pendientes"] = len(plan["dias"])
    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "relleno_dias", **res})
    print(f"[relleno] {res['consultas']} consultas · +{res['nuevos']} · {len(res['dias_completos'])} días · "
          f"quedan {res['pendientes']} · {res['abortado'] or 'ok'}")
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
    """Agrega a la cola los días con cobertura de categorías anormalmente baja."""
    hoy = hoy_rd()
    hasta = hoy - timedelta(days=2)
    desde = max(INICIO_HISTORICO, hoy - timedelta(days=dias_atras))
    cob = cobertura_diaria(alm, desde - timedelta(days=70), hasta)
    # referencia = mediana de los 8 mismos días de la semana anteriores
    nq = cob["n_q"].astype(float).where(cob["n_q"] > 0)
    ref = nq.groupby(cob.index.weekday).transform(lambda s: s.rolling(8, min_periods=3).median().shift(1))
    debil = cob[(cob.index >= pd.Timestamp(desde)) & ((cob["n_q"] == 0) | (cob["n_q"] < umbral * ref.fillna(0)))]
    hist = alm.estado("auditoria", {"reintentos": {}})
    plan = _cargar_plan(alm)
    en_cola = {u["d"] for u in plan["dias"]}
    nuevos = []
    for f in debil.index:
        k = str(f.date())
        if k in en_cola or hist["reintentos"].get(k, 0) >= max_reintentos:
            continue
        hist["reintentos"][k] = hist["reintentos"].get(k, 0) + 1
        nuevos.append(k)
    plan["dias"] += [{"d": k, "motivo": "auditoria", "barrido": True, "i": 0, "medio": 0, "cat_hecho": False}
                     for k in sorted(nuevos, reverse=True)]
    alm.guardar_estado(PLAN, plan)
    hist["ultima"] = str(hoy); hist["dias_debiles"] = len(debil)
    alm.guardar_estado("auditoria", hist)
    res = {"dias_revisados": int((cob.index >= pd.Timestamp(desde)).sum()), "debiles": len(debil),
           "reencolados": len(nuevos), "agotados": sum(1 for v in hist["reintentos"].values() if v >= max_reintentos)}
    alm.bitacora({"evento": "auditoria", **res, "dias": nuevos[:40]})
    print(f"[auditoria] {res}")
    return res


# ══════════════════════════════════════════════════════════════════════════════
# Profundización del histórico: día por día con las categorías (sin barrido)
# ══════════════════════════════════════════════════════════════════════════════
def profundizar(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 60) -> dict:
    t0 = time.time()
    est = alm.estado("profundizar_dias", {"cursor": str(FIN_LEGADO), "i": 0, "hecho": False})
    res = {"consultas": 0, "nuevos": 0, "dias": 0, "abortado": None}
    if est.get("hecho"):
        print("[profundizar] histórico completo"); return {**res, "hecho": True}
    try:
        d = date.fromisoformat(est["cursor"])
        while d >= INICIO_HISTORICO:
            tareas = cfg.tareas_query(d)
            while est["i"] < len(tareas):
                if (time.time() - t0) / 60 > minutos:
                    raise TimeoutError
                cat, q = tareas[est["i"]]
                n, _ = _guardar(alm, _items_a_filas(gn.buscar(q, d, d), f"q:{cat}"))
                res["consultas"] += 1; res["nuevos"] += n
                est["i"] += 1
                if est["i"] % 25 == 0:
                    alm.guardar_estado("profundizar_dias", est)
            res["dias"] += 1
            d -= timedelta(days=1)
            est["cursor"], est["i"] = str(d), 0
            alm.guardar_estado("profundizar_dias", est)
        est["hecho"] = True
    except (Bloqueado, TimeoutError) as e:
        res["abortado"] = type(e).__name__
    alm.guardar_estado("profundizar_dias", est)
    res["cursor"] = est["cursor"]
    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "profundizar", **res})
    print(f"[profundizar] {res}")
    return res


def estado(alm: Almacen) -> dict:
    plan = _cargar_plan(alm)
    pro = alm.estado("profundizar_dias", {"cursor": str(FIN_LEGADO), "hecho": False})
    aud = alm.estado("auditoria", {})
    dias = [u["d"] for u in plan["dias"]]
    total = (FIN_LEGADO - INICIO_HISTORICO).days
    hecho = (FIN_LEGADO - date.fromisoformat(pro.get("cursor", str(FIN_LEGADO)))).days
    out = {"cola_dias": len(dias), "proximo": dias[0] if dias else None,
           "rango_cola": [min(dias), max(dias)] if dias else None,
           "profundizar_cursor": pro.get("cursor"), "profundizar_avance_pct": round(100 * hecho / total, 2),
           "auditoria_debiles": aud.get("dias_debiles")}
    print(out)
    return out


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["plan", "relleno", "auditar", "profundizar", "estado"])
    ap.add_argument("--dir", default=None)
    ap.add_argument("--desde"); ap.add_argument("--hasta")
    ap.add_argument("--motivo", default="manual")
    ap.add_argument("--al-frente", action="store_true")
    ap.add_argument("--orden", default="desc", choices=["asc", "desc"])
    ap.add_argument("--minutos", type=float, default=60)
    a = ap.parse_args(argv)
    alm, cfg = Almacen(a.dir), Config()
    if a.cmd == "plan":
        plan_relleno(alm, date.fromisoformat(a.desde), date.fromisoformat(a.hasta), a.motivo, a.al_frente, a.orden)
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
