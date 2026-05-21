"""Lectura/escritura Excel preservando el layout histórico del equipo DGAPF.

Reemplaza las llamadas `openxlsx::read.xlsx` y `openxlsx::writeData` del R.
"""
from __future__ import annotations

from pathlib import Path
from typing import Any

import pandas as pd
from openpyxl import Workbook, load_workbook


# ---------------------------------------------------------------------------
# Lectura tolerante a layouts irregulares (equivalente a `excels_importados` del R)
# ---------------------------------------------------------------------------
def leer_rango_detectado(
    path: Path,
    sheet: str | int = 0,
    header_min_cols: int = 2,
) -> pd.DataFrame:
    """Auto-detecta la primera fila densa como cabecera.

    Reproduce la función `excels_importados(file, sheet=1)` del script
    `gestion_datos22.R`: lee la hoja completa, encuentra la primera fila
    con ≥ `header_min_cols` celdas no vacías y la usa como cabecera.
    """
    raw = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    for idx, row in raw.iterrows():
        non_null = row.notna().sum()
        if non_null >= header_min_cols:
            header_row = idx
            break
    else:
        return raw
    df = raw.iloc[header_row + 1 :].copy()
    df.columns = raw.iloc[header_row].tolist()
    df = df.dropna(axis=1, how="all").dropna(axis=0, how="all").reset_index(drop=True)
    return df


def leer_hoja(path: Path, sheet: str | int, start_row: int = 0, **kw) -> pd.DataFrame:
    """Lectura directa (estilo `read.xlsx(..., startRow=K)`)."""
    return pd.read_excel(path, sheet_name=sheet, header=start_row, **kw)


# ---------------------------------------------------------------------------
# Escritura: una hoja por frecuencia, índice de fecha en la columna A
# ---------------------------------------------------------------------------
def escribir_excel_por_frecuencia(
    path: Path,
    hojas: dict[str, pd.DataFrame],
    overwrite: bool = True,
) -> Path:
    """Escribe varias hojas en un único xlsx. DataFrames deben tener
    `fecha` (o DatetimeIndex) como primera columna."""
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = "w" if overwrite or not path.exists() else "a"
    with pd.ExcelWriter(path, engine="openpyxl", mode=mode) as writer:
        for name, df in hojas.items():
            df2 = df.copy()
            if isinstance(df2.index, pd.DatetimeIndex):
                df2.insert(0, "fecha", df2.index.date)
                df2 = df2.reset_index(drop=True)
            df2.to_excel(writer, sheet_name=name[:31], index=False)
    return path


# ---------------------------------------------------------------------------
# Conversor formato ancho -> largo (para cargar a Supabase en un paso)
# ---------------------------------------------------------------------------
def ancho_a_largo(
    df: pd.DataFrame,
    col_fecha: str = "fecha",
    columnas_variable: list[str] | None = None,
    map_columna_a_id: dict[str, str] | None = None,
) -> pd.DataFrame:
    """Transforma un DataFrame ancho (fecha en filas, variables en columnas)
    a formato largo compatible con `series_datos`.

    Parameters
    ----------
    map_columna_a_id : dict
        Mapea nombre de columna -> `variable_id` canónico del catálogo.
        Si no existe, se deja el nombre de columna como ID (para debug).
    """
    if col_fecha not in df.columns:
        raise ValueError(f"Columna '{col_fecha}' no existe en df")
    value_cols = columnas_variable or [c for c in df.columns if c != col_fecha]
    long = df.melt(id_vars=[col_fecha], value_vars=value_cols,
                   var_name="columna", value_name="valor")
    long = long.rename(columns={col_fecha: "fecha"})
    if map_columna_a_id:
        long["variable_id"] = long["columna"].map(map_columna_a_id)
        long = long.dropna(subset=["variable_id"]).drop(columns=["columna"])
    else:
        long = long.rename(columns={"columna": "variable_id"})
    long = long[["variable_id", "fecha", "valor"]]
    return long
