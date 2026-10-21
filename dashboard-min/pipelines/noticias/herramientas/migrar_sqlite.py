"""Migra isec_news.db (appsenti, 2016→jul-2026, solo titulares) al almacén Parquet.

    python -m pipelines.noticias.herramientas.migrar_sqlite \
        --db C:/Users/patri/codigos/appsenti/isec_news.db --dir C:/Users/patri/Desktop/dashboard-noticias

Una fila por noticia (id = titular+medio). Las filas repetidas en varios sets se
funden en `origenes` (q:<SECTOR>.<subcategoria>). El texto queda 'pendiente':
lo completa poco a poco `scraper textos` (decodifica el enlace de Google News).
"""
from __future__ import annotations

import argparse
import sqlite3
from collections import defaultdict
from datetime import date

import pandas as pd

from ..almacen import Almacen, id_articulo
from ..gnews import dominio
from .importar_queries_isec import CODIGOS, slug


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--dir", required=True)
    a = ap.parse_args()

    con = sqlite3.connect(a.db)
    df = pd.read_sql_query(
        "SELECT set_name, categoria, fecha, titular, medio, url, scraped_at FROM articulos "
        "WHERE titular IS NOT NULL AND fecha IS NOT NULL", con)
    print(f"filas origen: {len(df):,}")
    df["sector"] = df["set_name"].map(lambda s: CODIGOS.get(s, ("OTRO", ""))[0])
    df["origen"] = "q:" + df["sector"] + "." + df["categoria"].fillna("").map(slug)
    df["id"] = [id_articulo(t, m or "") for t, m in zip(df["titular"], df["medio"])]

    g = df.groupby("id").agg(
        fecha=("fecha", "min"), titulo=("titular", "first"), medio=("medio", "first"),
        url_gn=("url", "first"), primera_vista=("scraped_at", "min"),
        origenes=("origen", lambda s: sorted(set(s))),
    ).reset_index()
    g["fecha"] = pd.to_datetime(g["fecha"]).dt.date
    g["dominio"] = None
    g["url"] = None
    g["publicado_utc"] = None
    g["fuente"] = "legacy_sqlite"
    print(f"noticias únicas: {len(g):,}  ({g['fecha'].min()} → {g['fecha'].max()})")

    alm = Almacen(a.dir)
    n_tot = 0
    for d, parte in g.groupby("fecha"):
        filas = parte.to_dict("records")
        n, _ = alm.agregar_articulos(d, filas)
        n_tot += n
    alm.bitacora({"evento": "migracion_sqlite", "origen": a.db, "noticias": n_tot})
    print(f"OK {n_tot:,} noticias migradas en {g['fecha'].nunique():,} archivos diarios")


if __name__ == "__main__":
    main()
