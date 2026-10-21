"""Almacén de noticias en Parquet, particionado por DÍA de publicación (hora RD).

Vive en un repositorio PRIVADO aparte (dgapfmhe/dashboard-noticias) porque
contiene el texto íntegro de las notas (no se publica; ver derechos de autor).

    articulos/AAAA/MM/AAAA-MM-DD.parquet           1 fila por noticia (texto incl.)
    puntajes/<modelo>/AAAA/MM/AAAA-MM-DD.parquet   sentimiento por modelo
    etiquetas/AAAA/MM/AAAA-MM-DD.parquet           categorías asignadas (caché)
    estado/*.json                                  cursores y bitácoras

Partición diaria = cada archivo se reescribe pocas veces (el día t-1, el
re-barrido de t-3 y cuando llega su texto) → el historial de git crece lineal.

Para USAR los datos (notebooks, otro modelo):
    from pipelines.noticias.almacen import Almacen
    a = Almacen("C:/Users/patri/Desktop/dashboard-noticias")
    df = a.leer_rango("articulos", "2025-01-01", "2025-12-31")
o directo con pandas/duckdb:  pd.read_parquet(".../articulos/2025")
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import unicodedata
from datetime import date, datetime, timedelta
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

COLS_ARTICULOS = {
    "id": pa.string(), "fecha": pa.date32(), "publicado_utc": pa.string(),
    "titulo": pa.string(), "medio": pa.string(), "dominio": pa.string(),
    "url_gn": pa.string(), "url": pa.string(), "texto": pa.string(),
    "texto_estado": pa.string(), "texto_intentos": pa.int16(), "idioma": pa.string(),
    "origenes": pa.list_(pa.string()), "fuente": pa.string(), "primera_vista": pa.string(),
}
COLS_PUNTAJES = {
    "id": pa.string(), "fecha": pa.date32(), "pos": pa.float32(), "neu": pa.float32(),
    "neg": pa.float32(), "polaridad": pa.float32(), "etiqueta": pa.string(),
    "n_bloques": pa.int16(), "base": pa.string(), "puntuado_en": pa.string(),
}
COLS_ETIQUETAS = {
    "id": pa.string(), "fecha": pa.date32(), "cats_query": pa.list_(pa.string()),
    "cats_clave": pa.list_(pa.string()), "rd": pa.string(), "hash_config": pa.string(),
}
ESQUEMAS = {"articulos": COLS_ARTICULOS, "puntajes": COLS_PUNTAJES, "etiquetas": COLS_ETIQUETAS}


def normalizar(s: str) -> str:
    s = unicodedata.normalize("NFKD", s or "").encode("ascii", "ignore").decode()
    return re.sub(r"\s+", " ", s.lower()).strip()


def id_articulo(titulo: str, medio: str) -> str:
    return hashlib.sha1(f"{normalizar(titulo)}|{normalizar(medio)}".encode()).hexdigest()[:16]


def hay(v) -> bool:
    """True si v es un texto no vacío. Robusto a None y a NaN (pandas 3 lee los
    textos faltantes como NaN, que en Python es 'verdadero')."""
    return isinstance(v, str) and v.strip() != ""


def ahora() -> str:
    return datetime.utcnow().isoformat(timespec="seconds") + "Z"


class Almacen:
    def __init__(self, base: str | os.PathLike | None = None):
        self.base = Path(base or os.environ.get("NOTICIAS_DIR", "../dashboard-noticias")).resolve()

    # ── rutas ────────────────────────────────────────────────────────────────
    def _dir(self, tipo: str, modelo: str | None = None) -> Path:
        return self.base / tipo / modelo if modelo else self.base / tipo

    def ruta(self, tipo: str, d: date, modelo: str | None = None) -> Path:
        return self._dir(tipo, modelo) / f"{d:%Y}" / f"{d:%m}" / f"{d:%Y-%m-%d}.parquet"

    def dias(self, tipo: str, modelo: str | None = None) -> list[date]:
        raiz = self._dir(tipo, modelo)
        if not raiz.exists():
            return []
        return sorted(date.fromisoformat(p.stem) for p in raiz.glob("*/*/*.parquet"))

    # ── lectura / escritura ──────────────────────────────────────────────────
    def leer_dia(self, tipo: str, d: date, modelo: str | None = None,
                 columnas: list[str] | None = None) -> pd.DataFrame:
        p = self.ruta(tipo, d, modelo)
        if not p.exists():
            esquema = ESQUEMAS[tipo]
            return pd.DataFrame({c: pd.Series(dtype="object") for c in (columnas or esquema)})
        return pq.read_table(p, columns=columnas).to_pandas()

    def escribir_dia(self, tipo: str, d: date, df: pd.DataFrame, modelo: str | None = None) -> None:
        esquema = ESQUEMAS[tipo]
        df = df.copy()
        for c in esquema:
            if c not in df.columns:
                df[c] = None
        df = df[list(esquema)].sort_values("id").reset_index(drop=True)
        df["fecha"] = pd.to_datetime(df["fecha"]).dt.date
        tabla = pa.Table.from_pandas(df, schema=pa.schema(esquema), preserve_index=False)
        p = self.ruta(tipo, d, modelo)
        p.parent.mkdir(parents=True, exist_ok=True)
        tmp = p.with_suffix(".tmp")
        pq.write_table(tabla, tmp, compression="zstd", compression_level=9)
        tmp.replace(p)

    def leer_rango(self, tipo: str, desde=None, hasta=None, modelo: str | None = None,
                   columnas: list[str] | None = None) -> pd.DataFrame:
        desde = pd.Timestamp(desde).date() if desde else date(1900, 1, 1)
        hasta = pd.Timestamp(hasta).date() if hasta else date(2999, 1, 1)
        partes = [self.leer_dia(tipo, d, modelo, columnas)
                  for d in self.dias(tipo, modelo) if desde <= d <= hasta]
        partes = [p for p in partes if len(p)]
        if not partes:
            return self.leer_dia(tipo, date(1900, 1, 1), modelo, columnas)
        return pd.concat(partes, ignore_index=True)

    # ── fusión de artículos nuevos con el día existente ─────────────────────
    def agregar_articulos(self, d: date, nuevos: list[dict]) -> tuple[int, int]:
        """Inserta/actualiza noticias del día d. Une 'origenes' sin perder texto.
        → (n_nuevos, n_actualizados)"""
        if not nuevos:
            return 0, 0
        df = self.leer_dia("articulos", d)
        idx = {r: i for i, r in enumerate(df["id"].tolist())} if len(df) else {}
        filas = df.to_dict("records") if len(df) else []
        n_new = n_upd = 0
        for it in nuevos:
            i = idx.get(it["id"])
            if i is None:
                base = {c: None for c in COLS_ARTICULOS}
                base.update(texto_estado="pendiente", texto_intentos=0, primera_vista=ahora())
                base.update({k: v for k, v in it.items() if k in COLS_ARTICULOS})
                base["origenes"] = sorted(set(it.get("origenes") or []))
                idx[it["id"]] = len(filas)
                filas.append(base)
                n_new += 1
            else:
                f = filas[i]
                orig = set(f.get("origenes") if f.get("origenes") is not None else [])
                nuevos_or = orig | set(it.get("origenes") or [])
                cambio = nuevos_or != orig
                f["origenes"] = sorted(nuevos_or)
                for k in ("url", "dominio"):
                    if not hay(f.get(k)) and hay(it.get(k)):
                        f[k] = it[k]; cambio = True
                n_upd += int(cambio)
        if n_new or n_upd:
            self.escribir_dia("articulos", d, pd.DataFrame(filas))
        return n_new, n_upd

    # ── estado (cursores, bitácora) ─────────────────────────────────────────
    def estado(self, nombre: str, defecto=None):
        p = self.base / "estado" / f"{nombre}.json"
        return json.loads(p.read_text("utf-8")) if p.exists() else defecto

    def guardar_estado(self, nombre: str, valor) -> None:
        p = self.base / "estado" / f"{nombre}.json"
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(valor, ensure_ascii=False, indent=1, default=str), "utf-8")

    def bitacora(self, evento: dict) -> None:
        p = self.base / "estado" / "bitacora.jsonl"
        p.parent.mkdir(parents=True, exist_ok=True)
        with open(p, "a", encoding="utf-8") as f:
            f.write(json.dumps({"ts": ahora(), **evento}, ensure_ascii=False, default=str) + "\n")


def rango_dias(desde: date, hasta: date):
    d = desde
    while d <= hasta:
        yield d
        d += timedelta(days=1)
