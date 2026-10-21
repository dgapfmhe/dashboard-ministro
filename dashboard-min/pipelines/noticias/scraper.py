"""Scraper autónomo de noticias (Google News) → almacén Parquet.

    python -m pipelines.noticias.scraper diario                 # t-1 + re-barrido t-3 + barrido general
    python -m pipelines.noticias.scraper diario --dia 2026-10-20
    python -m pipelines.noticias.scraper categorias-nuevas      # backfill de categorías recién agregadas
    python -m pipelines.noticias.scraper textos --minutos 120   # URL original + texto completo (cola)
    python -m pipelines.noticias.scraper estado

Origen de cada noticia (columna `origenes`):
    q:<subcategoria>   la trajo la búsqueda de esa categoría
    b:<dominio>        barrido general del medio (capturar todo)
"""
from __future__ import annotations

import argparse
import sys
import time
from collections import defaultdict
from datetime import date, datetime, timedelta

import feedparser
import pandas as pd

from .almacen import Almacen, id_articulo, normalizar, rango_dias
from .config import Config
from .gnews import TZ_RD, UA, Bloqueado, GoogleNews, dominio
from . import texto as T

SATURA = 95          # ≥ este nº de resultados = la consulta se truncó en 100


def hoy_rd() -> date:
    return datetime.now(TZ_RD).date()


def _items_a_filas(items: list[dict], origen: str) -> list[dict]:
    filas = []
    for it in items:
        filas.append({
            "id": id_articulo(it["titulo"], it["medio"] or it["dominio"]),
            "fecha": it["fecha"], "publicado_utc": it["publicado_utc"],
            "titulo": it["titulo"], "medio": it["medio"], "dominio": it["dominio"],
            "url_gn": it["url_gn"], "origenes": [origen], "fuente": "gnews",
        })
    return filas


def _guardar(alm: Almacen, filas: list[dict]) -> tuple[int, int]:
    por_dia: dict[date, list[dict]] = defaultdict(list)
    for f in filas:
        por_dia[f["fecha"]].append(f)
    tn = tu = 0
    for d, fs in por_dia.items():
        n, u = alm.agregar_articulos(d, fs)
        tn += n; tu += u
    return tn, tu


# ══════════════════════════════════════════════════════════════════════════════
# DIARIO
# ══════════════════════════════════════════════════════════════════════════════
def diario(alm: Almacen, cfg: Config, gn: GoogleNews, dia: date | None = None,
           rebarrido: int = 3, barrido: bool = True) -> dict:
    t0 = time.time()
    dia = dia or (hoy_rd() - timedelta(days=1))
    res = {"dia": dia, "consultas": 0, "nuevos": 0, "actualizados": 0, "abortado": None}
    ventanas = [(dia, dia, "t-1")]
    if rebarrido:
        ventanas.append((dia - timedelta(days=rebarrido - 1), dia - timedelta(days=1), f"t-{rebarrido}"))

    try:
        # 1) categorías (queries de la investigación + de usuario)
        for a, b, etiqueta in ventanas:
            tareas = cfg.tareas_query(b)
            print(f"[diario] {etiqueta}: {len(tareas)} consultas {a}→{b}", flush=True)
            for i, (cat, q) in enumerate(tareas, 1):
                items = gn.buscar(q, a, b)
                res["consultas"] += 1
                n, u = _guardar(alm, _items_a_filas(items, f"q:{cat}"))
                res["nuevos"] += n; res["actualizados"] += u
                if i % 20 == 0:
                    print(f"  {i}/{len(tareas)}  nuevos={res['nuevos']}", flush=True)

        # 2) barrido general por medio (capturar todo)
        if barrido:
            for m in cfg.medios["medios"]:
                dom = m["dominio"]
                items = gn.buscar(f"site:{dom}", dia, dia)
                res["consultas"] += 1
                todos = list(items)
                if len(items) >= SATURA and m.get("secciones"):
                    for sec in m["secciones"]:
                        todos += gn.buscar(f"site:{dom}/{sec}", dia, dia)
                        res["consultas"] += 1
                n, u = _guardar(alm, _items_a_filas(todos, f"b:{dom}"))
                res["nuevos"] += n; res["actualizados"] += u
                print(f"  barrido {dom}: {len(todos)} items (+{n} nuevos)", flush=True)
    except Bloqueado as e:
        res["abortado"] = str(e)
        print(f"[diario] ABORTADO por bloqueo de Google: {e}. Lo pendiente queda para mañana.")

    res["minutos"] = round((time.time() - t0) / 60, 1)
    res["bloqueos"] = gn.rb.log
    alm.bitacora({"evento": "diario", **res})
    print(f"[diario] fin: {res}")
    return res


# ══════════════════════════════════════════════════════════════════════════════
# BACKFILL DE CATEGORÍAS NUEVAS (seguimiento desde t + intento hacia atrás)
# ══════════════════════════════════════════════════════════════════════════════
def categorias_nuevas(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 45) -> dict:
    """Para cada subcategoría con backfill_dias > 0 avanza hacia atrás por semanas
    (lo más reciente primero) hasta cubrir backfill_dias. Reanudable."""
    t0 = time.time()
    prog = alm.estado("backfill_categorias", {})
    hechos = 0
    try:
        for c in cfg.hojas():
            if c.backfill_dias <= 0:
                continue
            limite = c.activa_desde - timedelta(days=c.backfill_dias)
            cursor = date.fromisoformat(prog.get(c.id, str(c.activa_desde)))
            while cursor > limite:
                if (time.time() - t0) / 60 > minutos:
                    raise TimeoutError
                a = max(limite, cursor - timedelta(days=7))
                for q in c.queries:
                    _guardar(alm, _items_a_filas(gn.buscar(q, a, cursor - timedelta(days=1)), f"q:{c.id}"))
                cursor = a
                prog[c.id] = str(cursor)
                alm.guardar_estado("backfill_categorias", prog)
                hechos += 1
    except (Bloqueado, TimeoutError) as e:
        print(f"[categorias-nuevas] pausa: {type(e).__name__}")
    alm.bitacora({"evento": "categorias_nuevas", "semanas": hechos})
    return {"semanas": hechos, "progreso": prog}


# ══════════════════════════════════════════════════════════════════════════════
# TEXTOS: URL original + texto completo
# ══════════════════════════════════════════════════════════════════════════════
def _rss_directos(cfg: Config) -> dict[str, str]:
    """titular normalizado → URL directa (feeds propios de los medios)."""
    out = {}
    for m in cfg.medios["medios"]:
        for f in m.get("rss") or []:
            try:
                d = feedparser.parse(f, agent=UA)
            except Exception:
                continue
            for e in d.entries:
                if getattr(e, "title", None) and getattr(e, "link", None):
                    out[normalizar(e.title)] = e.link
    return out


def textos(alm: Almacen, cfg: Config, gn: GoogleNews, minutos: float = 120,
           desde: date | None = None, hasta: date | None = None, max_intentos: int = 3,
           prioridad_query: bool = True) -> dict:
    """Procesa la cola de textos pendientes, del día más reciente hacia atrás.
    Cada archivo diario se reescribe UNA vez por corrida (historial git liviano)."""
    t0 = time.time()
    directos = _rss_directos(cfg)
    res = {"dias": 0, "decodificadas": 0, "textos_ok": 0, "sin_url": 0, "abortado": None}
    decodificar = True
    dias = [d for d in reversed(alm.dias("articulos"))
            if (desde is None or d >= desde) and (hasta is None or d <= hasta)]

    for d in dias:
        if (time.time() - t0) / 60 > minutos:
            res["abortado"] = "presupuesto de tiempo"
            break
        df = alm.leer_dia("articulos", d)
        pend = df["texto_estado"].isin(["pendiente", "error"]) & (df["texto_intentos"].fillna(0) < max_intentos)
        if not pend.any():
            continue
        idx = df.index[pend]
        if prioridad_query:   # primero lo que trajeron las categorías
            es_q = df.loc[idx, "origenes"].map(lambda o: any(str(x).startswith("q:") for x in (o if o is not None else [])))
            idx = list(df.loc[idx][es_q].index) + list(df.loc[idx][~es_q].index)

        # 1) resolver URL
        for i in idx:
            if (time.time() - t0) / 60 > minutos:
                break
            if df.at[i, "url"]:
                continue
            u = directos.get(normalizar(df.at[i, "titulo"]))
            if not u and decodificar:
                try:
                    u = gn.decodificar(df.at[i, "url_gn"])
                    res["decodificadas"] += int(bool(u))
                except Bloqueado as e:
                    decodificar = False
                    res["abortado"] = f"decodificación bloqueada: {e}"
            if u:
                df.at[i, "url"] = u
                df.at[i, "dominio"] = dominio(u)
            elif decodificar:
                df.at[i, "texto_estado"] = "sin_url"
                df.at[i, "texto_intentos"] = int(df.at[i, "texto_intentos"] or 0) + 1
                res["sin_url"] += 1

        # 2) extraer texto de las que ya tienen URL
        con_url = [i for i in idx if df.at[i, "url"] and df.at[i, "texto_estado"] in ("pendiente", "error")]
        if con_url:
            r = T.extraer_lote([df.at[i, "url"] for i in con_url])
            for i in con_url:
                est, txt = r[df.at[i, "url"]]
                df.at[i, "texto_estado"] = est
                df.at[i, "texto_intentos"] = int(df.at[i, "texto_intentos"] or 0) + 1
                if txt:
                    df.at[i, "texto"] = txt
                    df.at[i, "idioma"] = T.idioma(txt)
                    res["textos_ok"] += int(est == "ok")
        df["idioma"] = df["idioma"].fillna(df["titulo"].map(T.idioma))
        alm.escribir_dia("articulos", d, df)
        res["dias"] += 1
        if not decodificar and not any(df.at[i, "url"] for i in idx):
            # sin decodificador ya no podemos avanzar en días sin URL
            break

    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "textos", **res})
    print(f"[textos] {res}")
    return res


# ══════════════════════════════════════════════════════════════════════════════
def estado(alm: Almacen) -> None:
    df = alm.leer_rango("articulos", columnas=["fecha", "texto_estado", "origenes", "fuente"])
    if df.empty:
        print("almacén vacío"); return
    df["anio"] = pd.to_datetime(df["fecha"]).dt.year
    print(f"noticias: {len(df):,}   días: {df['fecha'].nunique():,}   {df['fecha'].min()} → {df['fecha'].max()}")
    print(pd.crosstab(df["anio"], df["texto_estado"]).to_string())


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["diario", "categorias-nuevas", "textos", "estado"])
    ap.add_argument("--dir", default=None, help="carpeta del repo de datos (NOTICIAS_DIR)")
    ap.add_argument("--dia", default=None)
    ap.add_argument("--rebarrido", type=int, default=3)
    ap.add_argument("--sin-barrido", action="store_true")
    ap.add_argument("--minutos", type=float, default=120)
    ap.add_argument("--desde", default=None)
    ap.add_argument("--hasta", default=None)
    a = ap.parse_args(argv)

    alm, cfg = Almacen(a.dir), Config()
    gn = GoogleNews()
    if a.cmd == "diario":
        r = diario(alm, cfg, gn, date.fromisoformat(a.dia) if a.dia else None,
                   a.rebarrido, not a.sin_barrido)
        return 0 if r["consultas"] else 1
    if a.cmd == "categorias-nuevas":
        categorias_nuevas(alm, cfg, gn, a.minutos)
    elif a.cmd == "textos":
        textos(alm, cfg, gn, a.minutos,
               date.fromisoformat(a.desde) if a.desde else None,
               date.fromisoformat(a.hasta) if a.hasta else None)
    else:
        estado(alm)
    return 0


if __name__ == "__main__":
    sys.exit(main())
