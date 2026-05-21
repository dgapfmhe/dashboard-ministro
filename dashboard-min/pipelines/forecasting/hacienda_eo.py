"""Estado de Operaciones (EO) del Ministerio de Hacienda.

Publicado mensualmente como xlsx en:
  https://www.hacienda.gob.do/...
El layout cambia ocasionalmente, así que este parser se apoya en
`leer_rango_detectado` y en keywords en español.
"""
from __future__ import annotations

from datetime import date
from pathlib import Path
from typing import Iterable

import pandas as pd

from core.excel_io import leer_rango_detectado
from core.logging_utils import get_logger

log = get_logger(__name__)


# Mapeo etiqueta -> variable_id
MAP_EO = [
    ("Ingresos totales",           "hac.eo.ingresos_totales"),
    ("Gastos totales",             "hac.eo.gastos_totales"),
    ("Resultado primario",         "hac.eo.resultado_primario"),
    ("Resultado global",           "hac.eo.resultado_global"),
]


def _contiene(texto: str, claves: Iterable[str]) -> bool:
    t = texto.lower()
    return all(k.lower() in t for k in claves)


def parsear_eo(path: Path) -> pd.DataFrame:
    """Intenta localizar cada etiqueta EO y extraer su serie mensual."""
    df = leer_rango_detectado(path, header_min_cols=3)
    if df.empty:
        return pd.DataFrame()

    etiquetas = df.iloc[:, 0].astype(str)
    columnas_fechas = []
    for c in df.columns[1:]:
        try:
            columnas_fechas.append(pd.to_datetime(c).date().replace(day=1))
        except Exception:  # noqa: BLE001
            columnas_fechas.append(None)

    filas: list[dict] = []
    for etiqueta, var_id in MAP_EO:
        hits = etiquetas[etiquetas.str.lower().str.contains(etiqueta.lower(),
                                                            na=False)].index.tolist()
        if not hits:
            log.warning("EO: etiqueta '%s' no encontrada", etiqueta)
            continue
        fila = df.iloc[hits[0], 1:]
        for f, v in zip(columnas_fechas, fila):
            if f is None:
                continue
            val = pd.to_numeric(v, errors="coerce")
            if pd.isna(val):
                continue
            filas.append({"variable_id": var_id, "fecha": f, "valor": float(val)})
    return pd.DataFrame(filas)
