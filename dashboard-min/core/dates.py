"""Helpers de fechas: conversiones frecuencia, agregaciones, seriales Excel."""
from __future__ import annotations

from datetime import date, datetime, timedelta
from typing import Literal

import pandas as pd


EXCEL_EPOCH = datetime(1899, 12, 30)  # anclaje usado por openpyxl/Excel 1900 sys


def excel_serial_to_date(serial: int | float) -> date:
    """Convierte un número de serie de Excel a `date`. Ej: 43831 -> 2020-01-01."""
    return (EXCEL_EPOCH + timedelta(days=float(serial))).date()


def date_to_excel_serial(d: date | datetime) -> int:
    if isinstance(d, datetime):
        d = d.date()
    return (datetime(d.year, d.month, d.day) - EXCEL_EPOCH).days


# ---------------------------------------------------------------------------
# Agregaciones mensual -> trimestral (replica `mens_a_trim` del R)
# ---------------------------------------------------------------------------
AggFun = Literal["mean", "sum", "last", "first"]


def monthly_to_quarterly(s: pd.Series, fun: AggFun = "mean") -> pd.Series:
    """Agrega una serie mensual (index DatetimeIndex) a trimestres.

    Reglas equivalentes a `aggregate.ts(..., FUN=...)` de R:
      - mean : promedio del trimestre (niveles, tasas)
      - sum  : suma (flujos acumulables)
      - last : último valor del trimestre (stocks)
      - first: primer valor del trimestre
    """
    if not isinstance(s.index, pd.DatetimeIndex):
        raise ValueError("La serie debe tener DatetimeIndex")
    rule = "QE"  # fin de trimestre (Q1=Mar 31, etc.)
    if fun == "mean":
        return s.resample(rule).mean()
    if fun == "sum":
        return s.resample(rule).sum(min_count=1)
    if fun == "last":
        return s.resample(rule).last()
    if fun == "first":
        return s.resample(rule).first()
    raise ValueError(f"FUN no soportada: {fun}")


def daily_to_monthly(s: pd.Series, fun: AggFun = "mean") -> pd.Series:
    if fun == "mean":
        return s.resample("ME").mean()
    if fun == "sum":
        return s.resample("ME").sum(min_count=1)
    if fun == "last":
        return s.resample("ME").last()
    if fun == "first":
        return s.resample("ME").first()
    raise ValueError(f"FUN no soportada: {fun}")


def quarter_label(d: date) -> str:
    """Ej: 2025-06-30 -> '2025-Q2'."""
    return f"{d.year}-Q{(d.month - 1) // 3 + 1}"


# ---------------------------------------------------------------------------
# Normalización de fechas para series mensuales / anuales
# ---------------------------------------------------------------------------
def normalizar_fechas(
    df: pd.DataFrame,
    freq_map: dict[str, str],
    drop_future_meses: int = 1,
) -> pd.DataFrame:
    """Snap fechas a inicio de período según frecuencia + descarta fechas futuras.

    Resuelve dos bugs recurrentes del Excel del equipo DGAPF:

    1. Series mensuales con fechas mid-mes (ej: ``prest_*`` venía a
       ``2025-11-14`` por la fecha de corte de la encuesta BCRD), creando
       filas separadas en el pivot final → NaN gaps.

    2. Parsers que leen filas de proyecciones del archivo BCRD como si
       fueran observadas (ej: ``se_cc_numtur`` extendiéndose hasta 2032).

    Parameters
    ----------
    freq_map
        ``{variable_id: 'diaria'|'semanal'|'mensual'|'trimestral'|'anual'}``
    drop_future_meses
        Cota superior: hoy + N meses. Las filas con fecha posterior se
        descartan (se asumen proyecciones contaminadas).
    """
    if df.empty or "fecha" not in df.columns:
        return df
    out = df.copy()
    out["fecha"] = pd.to_datetime(out["fecha"], errors="coerce")
    out = out.dropna(subset=["fecha"])

    # Variables NO mapeadas → "diaria" (NO snapear). Antes era "mensual", lo que
    # colapsaba silenciosamente las fechas diarias de variables ausentes del
    # catálogo (deprem_cp, eur_usd) al día 1 del mes. Default seguro: no tocar.
    freqs = out["variable_id"].map(freq_map).fillna("diaria")
    is_month = freqs.isin(["mensual", "trimestral"])
    is_year = freqs.eq("anual")
    out.loc[is_month, "fecha"] = (
        out.loc[is_month, "fecha"].dt.to_period("M").dt.to_timestamp()
    )
    out.loc[is_year, "fecha"] = (
        out.loc[is_year, "fecha"].dt.to_period("Y").dt.to_timestamp()
    )

    cutoff = (pd.Timestamp.today().normalize()
              + pd.DateOffset(months=drop_future_meses))
    out = out[out["fecha"] <= cutoff]

    out = (out.sort_values(["variable_id", "fecha"])
              .drop_duplicates(subset=["variable_id", "fecha"], keep="last")
              .reset_index(drop=True))
    return out
