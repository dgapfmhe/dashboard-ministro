"""SIPEN - Superintendencia de Pensiones.

El script R descargaba dos archivos: salarios cotizantes y número de
cotizantes. Aquí los tratamos como fuentes opcionales (si el URL cambia,
se loggea y se omite)."""
from __future__ import annotations

from pathlib import Path

import pandas as pd

from core.excel_io import leer_rango_detectado
from core.logging_utils import get_logger

log = get_logger(__name__)


def parsear_sipen_salarios(path: Path, variable_id: str = "sipen.salarios") -> pd.DataFrame:
    df = leer_rango_detectado(path)
    if df.empty:
        return pd.DataFrame()
    col_fecha = next((c for c in df.columns if "fecha" in str(c).lower()
                      or "mes" in str(c).lower() or "periodo" in str(c).lower()), df.columns[0])
    col_valor = next((c for c in df.columns if c != col_fecha), df.columns[-1])
    df[col_fecha] = pd.to_datetime(df[col_fecha], errors="coerce")
    df[col_valor] = pd.to_numeric(df[col_valor], errors="coerce")
    df = df.dropna(subset=[col_fecha, col_valor])
    return pd.DataFrame({
        "variable_id": variable_id,
        "fecha": df[col_fecha].dt.date,
        "valor": df[col_valor].astype(float).values,
    })
