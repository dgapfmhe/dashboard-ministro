"""Parser del Anexo MEM → DataFrame largo listo para Supabase.

Soporta los DOS formatos del archivo MEM que hemos visto:
  - Histórico:    fila de fechas son seriales Excel (ej: 43831 = 2020-01-01).
  - Actual (2026): fila de fechas son `pd.Timestamp` reales.

Estructura de cada hoja:
  - "Variables Relevantes" / "EDE's": cabecera ~fila 6 (0-indexed),
    etiqueta en columna A/B, luego varios bloques de resumen (D, D%) y
    finalmente la serie temporal mensual desde 2009-01-01.
  - "Anexo Res Financieros": cabecera fila 13, año vigente en col 2,
    cada etiqueta aparece 4 veces (Consol + 3 EDEs).
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from pathlib import Path

import pandas as pd

from core.dates import excel_serial_to_date
from core.logging_utils import get_logger

log = get_logger(__name__)


FECHA_MIN = date(2020, 1, 1)  # corte: data1.R toma desde Jan 2020


@dataclass
class BloqueSerieTemporal:
    etiquetas: pd.Series
    fechas: list[date]
    valores: pd.DataFrame   # filas = variables, columnas = fechas


# ---------------------------------------------------------------------------
# Helpers de detección de fechas
# ---------------------------------------------------------------------------
def _a_fecha(v) -> date | None:
    """Intenta convertir un valor de celda a `date`. Soporta SOLO:
      - pd.Timestamp / datetime / date  → fecha real
      - Excel serial numérico en rango 20000..80000  → fecha real
      - String con separadores '-' o '/' o '.M' (parseable por pandas)
    Rechaza explícitamente enteros/strings que sean SOLO un año (ej: 2024),
    porque en los archivos MEM las cabeceras finales son labels de año, no
    fechas reales.
    """
    if v is None or (isinstance(v, float) and pd.isna(v)):
        return None
    if isinstance(v, pd.Timestamp):
        return v.date()
    if isinstance(v, datetime):
        return v.date()
    if isinstance(v, date):
        return v
    # Numérico: probablemente serial Excel
    try:
        f = float(v)
        if 20000 < f < 80000:
            return excel_serial_to_date(int(f))
    except (TypeError, ValueError):
        pass
    # String — solo si tiene separador de fecha
    s = str(v).strip()
    if not any(sep in s for sep in ("-", "/", ".")):
        return None
    try:
        return pd.to_datetime(s).date()
    except Exception:
        return None


def _detectar_fila_fechas(raw: pd.DataFrame, max_rows: int = 15) -> int:
    """Devuelve el índice de la fila con MÁS valores convertibles a fecha
    válida (>=1990, <2050)."""
    best_idx, best_count = 0, 0
    for i in range(min(max_rows, len(raw))):
        cnt = sum(1 for v in raw.iloc[i]
                  if (d := _a_fecha(v)) is not None and 1990 <= d.year <= 2050)
        if cnt > best_count:
            best_count, best_idx = cnt, i
    if best_count == 0:
        raise ValueError("No se encontró fila de fechas en la hoja")
    return best_idx


# ---------------------------------------------------------------------------
# Extractor genérico
# ---------------------------------------------------------------------------
def _extraer_bloque_temporal(raw: pd.DataFrame, col_etiqueta: int,
                              fecha_min: date = FECHA_MIN) -> BloqueSerieTemporal:
    """Localiza la fila de fechas, filtra columnas con fecha >= `fecha_min`,
    extrae etiquetas (de `col_etiqueta`) y matriz de valores alineada."""
    fila_fechas_idx = _detectar_fila_fechas(raw)
    fila_fechas = raw.iloc[fila_fechas_idx]

    # Columnas con fechas válidas y >= fecha_min, en orden cronológico
    col_fecha_pairs: list[tuple[int, date]] = []
    for j, v in enumerate(fila_fechas):
        d = _a_fecha(v)
        if d is None or d.year < fecha_min.year:
            continue
        if d < fecha_min:
            continue
        col_fecha_pairs.append((j, d))
    # ordenar por fecha (por si vienen desordenadas)
    col_fecha_pairs.sort(key=lambda p: p[1])

    if not col_fecha_pairs:
        raise ValueError(f"No se encontraron fechas >= {fecha_min} en la fila {fila_fechas_idx}")

    cols = [j for j, _ in col_fecha_pairs]
    fechas = [d for _, d in col_fecha_pairs]

    # Etiquetas: columna `col_etiqueta`, filas DESPUÉS de la fila de fechas
    etiquetas = raw.iloc[fila_fechas_idx + 1:, col_etiqueta].reset_index(drop=True)
    # Valores: mismas filas, columnas seleccionadas
    valores = raw.iloc[fila_fechas_idx + 1:, cols].reset_index(drop=True)
    valores.columns = fechas

    log.info("Bloque detectado: fila_fechas=%d, %d cols (%s … %s), %d filas",
             fila_fechas_idx, len(fechas), fechas[0], fechas[-1], len(etiquetas))
    return BloqueSerieTemporal(etiquetas=etiquetas, fechas=fechas, valores=valores)


def _fila_por_etiqueta(bloque: BloqueSerieTemporal, etiqueta: str,
                        offset: int = 0) -> pd.Series | None:
    """Encuentra la primera fila cuya etiqueta sea `etiqueta` (match exacto
    primero, luego sustring case-insensitive). Devuelve la fila + offset."""
    et = bloque.etiquetas.astype(str).str.strip()
    # Match exacto
    hits = et[et == etiqueta].index.tolist()
    if not hits:
        # Fallback: case-insensitive substring
        target_lc = etiqueta.lower()
        hits = [i for i, v in et.items() if target_lc in v.lower()]
    if not hits:
        log.warning("Etiqueta no encontrada: %s", etiqueta)
        return None
    idx = hits[0] + offset
    if idx < 0 or idx >= len(bloque.valores):
        return None
    s = bloque.valores.iloc[idx]
    s.name = etiqueta
    return pd.to_numeric(s, errors="coerce")


# ---------------------------------------------------------------------------
# Lectura de las 3 hojas
# ---------------------------------------------------------------------------
def leer_variables_relevantes(path: Path) -> BloqueSerieTemporal:
    """Hoja 'Variables Relevantes': etiqueta en col 1 (B)."""
    # Leemos toda la hoja sin cabecera; el detector encuentra la fila de fechas
    raw = pd.read_excel(path, sheet_name="Variables Relevantes",
                        header=None, dtype=object)
    return _extraer_bloque_temporal(raw, col_etiqueta=1)


def leer_ede(path: Path) -> BloqueSerieTemporal:
    """Hoja 'EDE's' (con apostrofe): etiqueta en col 1 (B)."""
    # Probar variantes del nombre de hoja
    xl = pd.ExcelFile(path)
    sheet = next((s for s in xl.sheet_names if s.startswith("EDE")), None)
    if not sheet:
        raise ValueError(f"No se encontró hoja EDE en {path.name}")
    raw = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    return _extraer_bloque_temporal(raw, col_etiqueta=1)


def leer_anexo_res_financieros(path: Path) -> tuple[pd.Series, pd.DataFrame, str]:
    """Hoja 'Anexo Res Financieros' cols B:N rows 14:305.

    Retorna (etiquetas, matriz, año_vigente). La cabecera identifica el año
    vigente vía la segunda columna de cabecera (el R hace `colnames[2]` y
    toma los últimos 4 chars como año).
    """
    raw = pd.read_excel(
        path, sheet_name="Anexo Res Financieros", header=13,
        usecols="B:N", dtype=object, nrows=305 - 14,
    )
    anio_vigente = str(raw.columns[1])[-4:]
    etiquetas = raw.iloc[:, 0].reset_index(drop=True)
    matriz = raw.iloc[:, 1:].reset_index(drop=True)
    return etiquetas, matriz, anio_vigente


def _fila_resfin(etiquetas: pd.Series, matriz: pd.DataFrame, etiqueta: str,
                 n_ocurrencia: int = 0) -> pd.Series | None:
    et = etiquetas.astype(str).str.strip()
    hits = et[et == etiqueta].index.tolist()
    if len(hits) <= n_ocurrencia:
        # Fallback: substring
        target_lc = etiqueta.lower()
        hits = [i for i, v in et.items() if target_lc in v.lower()]
    if len(hits) <= n_ocurrencia:
        log.warning("Fila financiera '%s' ocurrencia %d no encontrada",
                    etiqueta, n_ocurrencia)
        return None
    return pd.to_numeric(matriz.iloc[hits[n_ocurrencia]], errors="coerce")
