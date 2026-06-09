"""Parsers específicos por archivo BCRD.

Layouts validados línea por línea contra `Data_dgapf 2.R` (DGAPF, abril 2026).

Patrón dominante (ej: IPC, IMAE, RIN, llegada_tur, base_mon, encaje, ...):

  - `read_excel(file, skip=N)` salta N filas de cabecera.
  - Una columna específica (típicamente la 1 o la 2) contiene el nombre del
    mes en español (`Enero, Febrero, …, Diciembre`).
  - Filtrar las filas donde esa columna esté en la lista de meses ES.
  - Una columna específica trae el valor.
  - El primer mes filtrado corresponde a `(start_year, start_month)` y los
    siguientes son meses consecutivos.

Otros patrones especiales:
  - **TPM** (event-driven): filas con [Fecha, TPM, …]. Se expande a diario.
  - **EMBI** (diario): col `Fecha`, col `REP DOM`.
  - **TCN diario**: cols Año/Mes/Día/Compra/Venta.
  - **TC entidades**: hoja `Mensual`, cols Compra/Venta.
  - **balanza_pagos / pii / pib_***: layouts transpuestos, multi-variable.
    Se dejan registrados como TODO por su complejidad multi-columna.
"""
from __future__ import annotations

import datetime as _dt
from datetime import date
from pathlib import Path
from typing import Callable

import pandas as pd

from core.logging_utils import get_logger

log = get_logger(__name__)


# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------
MESES_ES_FULL = (
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre",
)
# Abreviaturas 3-letras como las usa el BCRD en TPM y otras tablas.
MESES_ES_ABREV = (
    "ene", "feb", "mar", "abr", "may", "jun",
    "jul", "ago", "sep", "oct", "nov", "dic",
)
# Set unificado para validación rápida.
_MESES_VALIDOS = (
    {m.lower() for m in MESES_ES_FULL}
    | set(MESES_ES_ABREV)
    | {"sept"}  # variante septiembre
)


def _normalizar_mes(s) -> str:
    """Devuelve la primera palabra normalizada (sin '*', '2/', acentos, espacios)."""
    if not isinstance(s, str):
        return ""
    raw = s.strip()
    cleaned = raw.replace("*", "").replace("2/", "").strip().lower()
    return cleaned.split()[0] if cleaned else ""


def _es_mes_es(s) -> bool:
    """True si `s` es un nombre de mes en español (completo o abreviado)."""
    cleaned = _normalizar_mes(s)
    if cleaned in _MESES_VALIDOS:
        return True
    # Tolera abreviaturas con prefijo 3-letras: 'ener' -> 'ene', 'agos' -> 'ago'
    return cleaned[:3] in set(MESES_ES_ABREV) and len(cleaned) >= 3


def _mes_a_idx(s) -> int | None:
    """Devuelve 1..12 o None."""
    cleaned = _normalizar_mes(s)
    if not cleaned:
        return None
    # Primero match exacto en nombres completos
    for i, m in enumerate(MESES_ES_FULL):
        if cleaned == m.lower():
            return i + 1
    # Luego abreviaturas 3-letras
    pref = cleaned[:3]
    for i, m in enumerate(MESES_ES_ABREV):
        if pref == m:
            return i + 1
    if cleaned == "sept":
        return 9
    return None


def _parse_bcrd_date_str(s: str) -> date | None:
    """Parsea fechas-string del BCRD (formato preliminar con asterisco):
       - 'dic-25*'          → date(2025, 12, 1)
       - 'ene-2026*'        → date(2026, 1, 1)
       - '30-abr-26*'       → date(2026, 4, 1)  (snap al inicio del mes)
       - '11-may-26'        → date(2026, 5, 1)
       - 'enero 2025'       → date(2025, 1, 1)
    Snap a día 1 (convención de mensual) y descarta el asterisco preliminar."""
    if not isinstance(s, str):
        return None
    raw = s.strip().rstrip("*").strip()
    if not raw:
        return None
    parts = [p.strip() for p in raw.replace("/", "-").replace(" ", "-").split("-") if p.strip()]
    if not parts:
        return None
    # Buscar el mes (alguna parte debe ser nombre de mes en español)
    mes_idx = None
    mes_pos = None
    for i, p in enumerate(parts):
        m = _mes_a_idx(p)
        if m is not None:
            mes_idx = m
            mes_pos = i
            break
    if mes_idx is None or mes_pos is None:
        return None
    # El año es el ÚLTIMO número de la cadena (formato BCRD: 'dic-25*' o
    # '30-abr-26*'; siempre el año va al final, NO el día). Iteramos al revés.
    anio = None
    for i in range(len(parts) - 1, -1, -1):
        if i == mes_pos:
            continue
        try:
            n = int(parts[i])
            if 0 <= n <= 99:
                anio = 2000 + n if n < 50 else 1900 + n
                break
            if 1990 <= n <= 2100:
                anio = n
                break
        except ValueError:
            continue
    if anio is None:
        return None
    return date(anio, mes_idx, 1)


def _add_meses(start_year: int, start_month: int, n: int) -> list[date]:
    """Genera n meses consecutivos a partir de (year, month)."""
    out = []
    y, m = start_year, start_month
    for _ in range(n):
        out.append(date(y, m, 1))
        m += 1
        if m == 13:
            m = 1
            y += 1
    return out


# ---------------------------------------------------------------------------
# Parser genérico: filas-mes (layout BCRD estándar)
# ---------------------------------------------------------------------------
def parser_filas_mes(
    path: Path,
    variable_id: str,
    *,
    skip: int,
    sheet: str | int = 0,
    mes_col: int = 0,     # índice 0-based de la columna con el nombre del mes
    val_col: int,         # índice 0-based de la columna con el valor
    start_year: int,
    start_month: int = 1,
    multiplicador: float = 1.0,
    dropna_first: bool = False,
    filter_meses: bool = True,
) -> pd.DataFrame:
    """Layout dominante BCRD.

    Dos modos:

    1. ``filter_meses=True`` (default):
       - Cabecera ocupa ``skip`` filas.
       - La columna ``mes_col`` contiene el nombre del mes (Enero..Diciembre).
       - El primer mes filtrado es ``(start_year, start_month)``.

    2. ``filter_meses=False``:
       - Tras ``dropna``, las filas ya son una serie mensual implícita.
       - El primer registro no-NaN corresponde a ``(start_year, start_month)``.
       - Útil para ``base_mon, encaje, compra_dolar`` (R hace ``na.omit`` y
         toma columna directa).
    """
    try:
        raw = pd.read_excel(path, sheet_name=sheet, header=None,
                            skiprows=skip, dtype=object)
    except Exception as e:  # noqa: BLE001
        log.warning("%s: read_excel falló: %s", path.name, e)
        return pd.DataFrame()

    if raw.empty:
        log.warning("%s: archivo vacío", path.name)
        return pd.DataFrame()

    # Convierte índices negativos a positivos según ancho real
    ncol = raw.shape[1]
    if val_col < 0:
        val_col = ncol + val_col

    if dropna_first:
        raw = raw.dropna(how="any").reset_index(drop=True)

    if filter_meses:
        if mes_col < 0:
            mes_col = ncol + mes_col
        if mes_col >= raw.shape[1]:
            log.warning("%s: mes_col %d fuera de rango (%d cols)",
                        path.name, mes_col, raw.shape[1])
            return pd.DataFrame()
        mask = raw.iloc[:, mes_col].apply(_es_mes_es)
        sub = raw[mask].reset_index(drop=True)
        if sub.empty:
            log.warning("%s: ninguna fila con nombre de mes ES en col %d",
                        path.name, mes_col)
            return pd.DataFrame()
    else:
        # solo deja filas con valor numérico en val_col
        valores_raw = pd.to_numeric(raw.iloc[:, val_col], errors="coerce")
        sub = raw[valores_raw.notna()].reset_index(drop=True)
        if sub.empty:
            log.warning("%s: ninguna fila numérica en col %d",
                        path.name, val_col)
            return pd.DataFrame()

    if val_col >= sub.shape[1]:
        log.warning("%s: val_col %d fuera de rango (%d cols)",
                    path.name, val_col, sub.shape[1])
        return pd.DataFrame()

    fechas = _add_meses(start_year, start_month, len(sub))
    valores = pd.to_numeric(sub.iloc[:, val_col], errors="coerce")

    df = pd.DataFrame({
        "variable_id": variable_id,
        "fecha": fechas,
        "valor": valores.astype(float) * multiplicador,
    }).dropna(subset=["valor"])
    return df


# ---------------------------------------------------------------------------
# Parser: pivote (años en columnas, meses en filas) — usado por rem_fam
# ---------------------------------------------------------------------------
def parser_pivot_anio_x_mes(
    path: Path,
    variable_id: str,
    *,
    skip: int,
    sheet: str | int = 0,
    n_meses: int = 12,
    multiplicador: float = 1.0,
) -> pd.DataFrame:
    """Layout: col 0 = mes (Enero..Diciembre), cols 1+ = años con valores.

    Replica `gather(., key='anio', value='valor', -1)` del R.

    Estrategia robusta:
      1. Lee con ``header=None`` para no perder filas como cabecera.
      2. Busca dinámicamente la fila que contiene años (ej: 2010, 2011, …)
         dentro de las primeras ~10 filas del cuerpo.
      3. La fila de años marca cuáles columnas son válidas.
      4. Las siguientes filas, hasta ``n_meses``, son los meses.
    """
    try:
        raw = pd.read_excel(
            path, sheet_name=sheet, header=None, skiprows=skip, dtype=object
        )
    except Exception as e:  # noqa: BLE001
        log.warning("%s: read_excel falló: %s", path.name, e)
        return pd.DataFrame()

    if raw.empty or raw.shape[1] < 2:
        log.warning("%s: archivo vacío o con <2 cols", path.name)
        return pd.DataFrame()

    def _a_anio(v) -> int | None:
        if isinstance(v, pd.Timestamp):
            return v.year
        try:
            iv = int(float(v))
            return iv if 1990 <= iv <= 2100 else None
        except (TypeError, ValueError):
            pass
        # Acepta strings con sufijo preliminar como '2024*', '2024 (p)', '2024(p)'
        if isinstance(v, str):
            import re
            m = re.match(r"^\s*(\d{4})", v)
            if m:
                yr = int(m.group(1))
                if 1990 <= yr <= 2100:
                    return yr
        return None

    # 1. Localiza la fila de años: la primera con ≥ 2 celdas que sean años.
    header_row = None
    anios_por_col: dict[int, int] = {}
    for i in range(min(10, len(raw))):
        candidatos = {
            j: _a_anio(raw.iloc[i, j])
            for j in range(1, raw.shape[1])
            if _a_anio(raw.iloc[i, j]) is not None
        }
        if len(candidatos) >= 2:
            header_row = i
            anios_por_col = candidatos
            break

    if header_row is None:
        log.warning(
            "%s: sin fila de años en primeras 10 filas. Vista: %s",
            path.name,
            [raw.iloc[i].tolist()[:6] for i in range(min(5, len(raw)))],
        )
        return pd.DataFrame()

    # 2. Cuerpo: meses van en col 0, valores en las cols con año detectado.
    body = raw.iloc[header_row + 1 : header_row + 1 + n_meses + 4].reset_index(
        drop=True
    )

    filas: list[dict] = []
    for _, row in body.iterrows():
        mes_idx = _mes_a_idx(row.iloc[0])
        if mes_idx is None:
            continue
        for col_idx, anio in anios_por_col.items():
            valor = pd.to_numeric(row.iloc[col_idx], errors="coerce")
            if pd.isna(valor):
                continue
            filas.append({
                "variable_id": variable_id,
                "fecha": date(anio, mes_idx, 1),
                "valor": float(valor) * multiplicador,
            })

    df = pd.DataFrame(filas)
    if df.empty:
        log.warning(
            "%s: 0 filas tras pivot. header_row=%d, años detectados: %s",
            path.name, header_row, list(anios_por_col.values()),
        )
    else:
        df = df.sort_values("fecha").reset_index(drop=True)
    return df


# ---------------------------------------------------------------------------
# Parser TPM (decisiones del directorio - evento → diaria)
# ---------------------------------------------------------------------------
def parser_tpm(path: Path) -> pd.DataFrame:
    """Archivo TPM: cabecera con [Año, Mes, TPM, DEPOS, REPOS] (aprox).
    El Excel BCRD guarda las tasas como FRACCIONES (0.0525 = 5.25%). Aquí
    multiplicamos por 100 para que se almacenen como porcentaje canónico
    en Supabase (5.25 = 5.25%).
    """
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:  # noqa: BLE001
        log.warning("TPM no se pudo leer: %s", e)
        return pd.DataFrame()

    def _a_anio(v) -> int | None:
        if isinstance(v, pd.Timestamp):
            return v.year
        try:
            iv = int(float(v))
            return iv if 1990 <= iv <= 2100 else None
        except (TypeError, ValueError):
            pass
        # Acepta strings con sufijo preliminar como '2024*', '2024 (p)', '2024(p)'
        if isinstance(v, str):
            import re
            m = re.match(r"^\s*(\d{4})", v)
            if m:
                yr = int(m.group(1))
                if 1990 <= yr <= 2100:
                    return yr
        return None

    start_row = None
    for i in range(min(30, len(raw))):
        if _a_anio(raw.iloc[i, 0]) is not None:
            start_row = i
            break
    if start_row is None:
        log.warning("TPM: no encontré año en col 0")
        return pd.DataFrame()

    body = raw.iloc[start_row:].reset_index(drop=True)
    filas_tpm: list[dict] = []
    filas_depos: list[dict] = []
    filas_repos: list[dict] = []
    anio_actual = None
    for _, row in body.iterrows():
        a = _a_anio(row.iloc[0])
        if a is not None:
            anio_actual = a
        if anio_actual is None:
            continue
        mes_str = row.iloc[1] if len(row) > 1 else None
        mes_idx = _mes_a_idx(mes_str)
        if mes_idx is None:
            continue
        fecha = date(anio_actual, mes_idx, 1)
        # col 2 = TPM. Excel guarda como fracción → × 100 para tener %
        tpm_val = pd.to_numeric(row.iloc[2], errors="coerce") if len(row) > 2 else None
        if pd.notna(tpm_val):
            v = float(tpm_val)
            # Si viene ya en formato % (> 0.5), respetamos; si < 0.5 asumimos fracción
            if abs(v) < 1.0:
                v *= 100.0
            filas_tpm.append({"variable_id": "tpm", "fecha": fecha, "valor": v})
        # col 3 = DEPOS
        if len(row) > 3:
            dep_val = pd.to_numeric(row.iloc[3], errors="coerce")
            if pd.notna(dep_val):
                v = float(dep_val)
                if abs(v) < 1.0:
                    v *= 100.0
                filas_depos.append({"variable_id": "DEPOS", "fecha": fecha, "valor": v})
        # col 4 = REPOS
        if len(row) > 4:
            rep_val = pd.to_numeric(row.iloc[4], errors="coerce")
            if pd.notna(rep_val):
                v = float(rep_val)
                if abs(v) < 1.0:
                    v *= 100.0
                filas_repos.append({"variable_id": "REPOS", "fecha": fecha, "valor": v})

    if not filas_tpm:
        log.warning("TPM: 0 filas válidas")
        return pd.DataFrame()

    # tpm mensual + expansión diaria por ffill (la frecuencia en el catálogo
    # canónico es 'mensual' para esta variable, así que damos prioridad al mensual)
    df_tpm = pd.DataFrame(filas_tpm).sort_values("fecha")

    frames = [df_tpm]
    if filas_depos:
        frames.append(pd.DataFrame(filas_depos))
    if filas_repos:
        frames.append(pd.DataFrame(filas_repos))
    df = pd.concat(frames, ignore_index=True)
    log.info("TPM: %d tpm, %d DEPOS, %d REPOS", len(filas_tpm), len(filas_depos), len(filas_repos))
    return df


# ---------------------------------------------------------------------------
# EMBI diario (col Fecha, col 'REP DOM')
# ---------------------------------------------------------------------------
def parser_embi(path: Path) -> pd.DataFrame:
    """EMBI BCRD: extrae Global, LATAM y RD. Archivo cdn.bancentral con cols:
    Fecha, Global, LATINO, REP DOM, Argentina, Bolivia, ..., RD-LATINO.
    """
    try:
        df = pd.read_excel(path, skiprows=1)
    except Exception as e:  # noqa: BLE001
        log.warning("EMBI no se pudo leer: %s", e)
        return pd.DataFrame()
    cols = {str(c).strip().lower(): c for c in df.columns}
    col_fecha = cols.get("fecha")
    if col_fecha is None:
        log.warning("EMBI: columna Fecha no encontrada")
        return pd.DataFrame()
    fechas = pd.to_datetime(df[col_fecha], errors="coerce").dt.date

    # Mapeo: keyword (lowercase substring) → variable_id
    mapping = [
        # (keyword en nombre col, variable_id, exclude_kw — para evitar ambigüedad)
        ("global",        "embi_global", None),
        ("latino",        "embi_latam",  "rd"),   # 'LATINO' pero NO 'RD-LATINO'
        ("rep dom",       "embi_rd",     None),
    ]
    frames: list[pd.DataFrame] = []
    for kw, vid, excl in mapping:
        col_match = None
        for c in df.columns:
            s = str(c).strip().lower()
            if kw in s and (excl is None or excl not in s):
                col_match = c
                break
        if col_match is None:
            log.warning("EMBI: col '%s' no encontrada para %s", kw, vid)
            continue
        valores = pd.to_numeric(df[col_match], errors="coerce")
        sub = pd.DataFrame({
            "variable_id": vid, "fecha": fechas, "valor": valores,
        }).dropna()
        if not sub.empty:
            frames.append(sub)
            log.info("EMBI %s: %d filas (col='%s')", vid, len(sub), col_match)
    if not frames:
        return pd.DataFrame()
    return pd.concat(frames, ignore_index=True)


# ---------------------------------------------------------------------------
# TCN referencia diario (cols: Año, Mes, Día, Compra, Venta, …)
# ---------------------------------------------------------------------------
def parser_tcn_dia(path: Path) -> pd.DataFrame:
    try:
        df = pd.read_excel(path, skiprows=2)
    except Exception as e:  # noqa: BLE001
        log.warning("TCN diaria no se pudo leer: %s", e)
        return pd.DataFrame()
    cols = {str(c).strip().lower(): c for c in df.columns}
    col_anio = cols.get("año") or cols.get("ano") or cols.get("anio")
    col_mes = cols.get("mes")
    col_dia = cols.get("día") or cols.get("dia")
    col_compra = cols.get("compra")
    col_venta = cols.get("venta")
    if not all([col_anio, col_mes, col_dia, col_compra, col_venta]):
        log.warning("TCN dia: cols Año/Mes/Día/Compra/Venta no encontradas")
        return pd.DataFrame()

    meses_abrev = {
        "ene": 1, "feb": 2, "mar": 3, "abr": 4, "may": 5, "jun": 6,
        "jul": 7, "ago": 8, "sep": 9, "sept": 9, "oct": 10, "nov": 11, "dic": 12,
    }

    def _to_fecha(row) -> date | None:
        try:
            y = int(row[col_anio])
            d = int(row[col_dia])
            m_raw = str(row[col_mes]).strip().lower()[:3]
            m = meses_abrev.get(m_raw)
            if not m:
                return None
            return date(y, m, d)
        except Exception:
            return None

    df["_fecha"] = df.apply(_to_fecha, axis=1)
    df = df.dropna(subset=["_fecha"])
    largo = []
    for var, col in [("tcn_compra", col_compra), ("tcn_venta", col_venta)]:
        sub = pd.DataFrame({
            "variable_id": var,
            "fecha": df["_fecha"].values,
            "valor": pd.to_numeric(df[col], errors="coerce").values,
        }).dropna()
        largo.append(sub)
    return pd.concat(largo, ignore_index=True) if largo else pd.DataFrame()


# ---------------------------------------------------------------------------
# Tipo de cambio entidades financieras (hoja 'Mensual': Año Mes Compra Venta)
# ---------------------------------------------------------------------------
def parser_tc_ent_fin(path: Path) -> pd.DataFrame:
    try:
        df = pd.read_excel(path, sheet_name="Mensual", skiprows=2)
    except Exception as e:  # noqa: BLE001
        log.warning("TC entidades no se pudo leer: %s", e)
        return pd.DataFrame()
    cols = {str(c).strip().lower(): c for c in df.columns}
    col_compra = cols.get("compra")
    col_venta = cols.get("venta")
    if not (col_compra and col_venta):
        return pd.DataFrame()

    # Si hay col 'Año' y 'Mes' explícitas las uso; si no, asumo orden cronológico
    # desde 1992-01 (start del R: pos_ene_92).
    fechas = _add_meses(1992, 1, len(df))
    largo = []
    for var, col in [("tcn_compra_m", col_compra), ("tcn_venta_m", col_venta)]:
        sub = pd.DataFrame({
            "variable_id": var,
            "fecha": fechas,
            "valor": pd.to_numeric(df[col], errors="coerce").values,
        }).dropna()
        largo.append(sub)
    return pd.concat(largo, ignore_index=True) if largo else pd.DataFrame()


# ---------------------------------------------------------------------------
# Parser: IPC Subyacente (year-propagates layout)
# Layout: annual Dec summaries first, then monthly from 2000-Enero
# Col 0 = year (numeric, propagates), col 1 = month name, col 2 = value
# ---------------------------------------------------------------------------
def parser_ipc_sub(path: Path) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("IPC Sub no se pudo leer: %s", e)
        return pd.DataFrame()

    filas: list[dict] = []
    anio_actual: int | None = None
    for _, row in raw.iterrows():
        # Col 0: numeric year or NaN
        a_raw = row.iloc[0]
        try:
            a = int(float(a_raw))
            if 1990 <= a <= 2100:
                anio_actual = a
        except (TypeError, ValueError):
            pass
        if anio_actual is None:
            continue
        mes_idx = _mes_a_idx(row.iloc[1] if len(row) > 1 else None)
        if mes_idx is None:
            continue
        valor = pd.to_numeric(row.iloc[2], errors="coerce") if len(row) > 2 else None
        if valor is None or pd.isna(valor):
            continue
        filas.append({"variable_id": "ipc_sub", "fecha": date(anio_actual, mes_idx, 1), "valor": float(valor)})

    df = pd.DataFrame(filas).sort_values("fecha").reset_index(drop=True)
    if df.empty:
        log.warning("IPC Sub: 0 filas parsadas")
    return df


# ---------------------------------------------------------------------------
# Parser: RIN (pivot años-columnas × meses-filas)
# Row 5: "Año" | 1985 | NaN | 1986 | NaN | ...  (years at cols 1,3,5,...)
# Row 7: NaN   | BRUTAS | NETAS | BRUTAS | NETAS | ...
# Row 8+: ENERO | brutas_1985 | netas_1985 | brutas_1986 | netas_1986 | ...
# ---------------------------------------------------------------------------
def parser_rin(path: Path) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("RIN no se pudo leer: %s", e)
        return pd.DataFrame()

    def _to_int(v) -> int | None:
        try:
            iv = int(float(v))
            return iv if 1900 <= iv <= 2100 else None
        except (TypeError, ValueError):
            return None

    # Find row with years (row 5 historically): ≥3 year-like ints
    year_row = None
    year_cols: dict[int, int] = {}  # col_idx -> year
    for i in range(min(15, len(raw))):
        row = raw.iloc[i]
        cands = {j: _to_int(row.iloc[j]) for j in range(1, len(row)) if _to_int(row.iloc[j]) is not None}
        if len(cands) >= 3:
            year_row = i
            year_cols = cands
            break

    if year_row is None:
        log.warning("RIN: no se encontró fila de años")
        return pd.DataFrame()

    # For each year at col j, NETAS is at col j+1 (alternating BRUTAS/NETAS)
    netas_map: dict[int, int] = {year: col + 1 for col, year in year_cols.items()}

    filas: list[dict] = []
    for i in range(year_row + 2, len(raw)):
        row = raw.iloc[i]
        mes_idx = _mes_a_idx(row.iloc[0])
        if mes_idx is None:
            continue
        for anio, netas_col in netas_map.items():
            if netas_col >= len(row):
                continue
            valor = pd.to_numeric(row.iloc[netas_col], errors="coerce")
            if pd.isna(valor):
                continue
            filas.append({"variable_id": "rin", "fecha": date(anio, mes_idx, 1), "valor": float(valor)})

    df = pd.DataFrame(filas).sort_values("fecha").reset_index(drop=True)
    if df.empty:
        log.warning("RIN: 0 filas parsadas")
    return df


# ---------------------------------------------------------------------------
# Parser: PIB por Gasto — trimestral
# Sheet 'PIB$_Trim': componentes en filas, fechas en columnas.
# Row 17: "Producto Interno Bruto" = pib_nom
# Row 10: "Consumo Privado", row 11: "Consumo Público", row 13: "FBCF",
#         row 15: "Exportaciones", row 16: "Importaciones"
# Dates: row 6 = years (propagate), row 7 = quarter labels (E-M, A-J, J-S, O-D)
# ---------------------------------------------------------------------------
_QUARTER_MONTH = {"e-m": 1, "a-j": 4, "j-s": 7, "o-d": 10}

# Mapeo de labels (lowercase, startswith) → variable_id para CADA sección.
# Estructura del archivo PIB$_Trim:
#   Fila 6:    Año-headers (1991, 1992, …, 2025 (p))
#   Fila 7:    Quarter labels (E-M, A-J, J-S, O-D)
#   Filas 9-17: VALORES en MM RD$ (Consumo Final, Privado, …, PIB)
#   Fila 20:   Subtítulo "PONDERACION POR COMPONENTE (%)"
#   Filas 23-31: Ponderaciones (%)
# Las mismas filas en PIBK_Trim son valores reales; en *_Acum son acumulados.
_LEVEL_MAP: dict[str, str] = {
    "consumo final":          "ct",
    "consumo privado":        "cpr",
    "consumo p":              "cpu",
    "formación bruta de capital fijo": "fbkf",
    "formación bruta de capital":      "fbkt",
    "variación de existencias":        "ve",
    "exportaciones":          "exp",
    "importaciones":          "imp",
    "producto interno bruto": "pib",
}
_POND_MAP: dict[str, str] = {
    "consumo privado":        "pond_cpr",
    "consumo p":              "pond_cpu",
    "formación bruta de capital fijo": "pond_fbkf",
    "exportaciones":          "pond_exp",
    "importaciones":          "pond_imp",
}


def _to_year_robust(v) -> int | None:
    """Acepta 2021, '2021', '2021 (p)', '2021(p)', 2021.0, etc."""
    if v is None:
        return None
    if isinstance(v, (int, float)):
        try:
            iv = int(v)
            return iv if 1985 <= iv <= 2100 else None
        except (TypeError, ValueError):
            return None
    s = str(v).strip()
    if not s or s.lower() == "nan":
        return None
    # Tomar la primera secuencia de 4 dígitos (ej: "2021 (p)" → "2021")
    import re
    m = re.match(r"^\s*(\d{4})", s)
    if m:
        try:
            iv = int(m.group(1))
            return iv if 1985 <= iv <= 2100 else None
        except ValueError:
            return None
    return None


def _detectar_year_row(raw: pd.DataFrame) -> int | None:
    """Primera fila con ≥ 3 celdas que parsean como año (1985..2100)."""
    for i in range(min(15, len(raw))):
        years_found = sum(
            1 for j in range(1, raw.shape[1])
            if _to_year_robust(raw.iloc[i, j]) is not None
        )
        if years_found >= 3:
            return i
    return None


def _build_col_dates(raw: pd.DataFrame, year_row: int) -> dict[int, date]:
    """col → date(year, quarter_month, 1), propagando el año hacia adelante."""
    col_dates: dict[int, date] = {}
    current_year: int | None = None
    quarter_row = year_row + 1
    for j in range(1, raw.shape[1]):
        yr = _to_year_robust(raw.iloc[year_row, j])
        if yr is not None:
            current_year = yr
        if current_year is None:
            continue
        q_raw = str(raw.iloc[quarter_row, j]).strip().lower() if raw.shape[0] > quarter_row else ""
        month = _QUARTER_MONTH.get(q_raw[:3])
        if month is not None:
            col_dates[j] = date(current_year, month, 1)
    return col_dates


def _match_label(label: str, mapping: dict[str, str]) -> str | None:
    """Match startswith por keyword en lowercase (sin acentos opcional)."""
    s = label.strip().lower()
    # Match keywords más largos primero para evitar 'consumo p' antes que 'consumo privado'
    for kw in sorted(mapping.keys(), key=len, reverse=True):
        if s.startswith(kw):
            return mapping[kw]
    return None


def _extraer_seccion(
    raw: pd.DataFrame, col_dates: dict[int, date],
    rango: tuple[int, int], mapping: dict[str, str], suffix: str = "",
) -> pd.DataFrame:
    """Lee las filas en `rango` (start, end] y mapea cada label a un variable_id."""
    filas: list[dict] = []
    for i in range(rango[0], min(rango[1], raw.shape[0])):
        label = str(raw.iloc[i, 0])
        base_id = _match_label(label, mapping)
        if base_id is None:
            continue
        var_id = f"{base_id}{suffix}"
        for j, dt in col_dates.items():
            val = pd.to_numeric(raw.iloc[i, j], errors="coerce")
            if not pd.isna(val):
                filas.append({"variable_id": var_id, "fecha": dt, "valor": float(val)})
    return pd.DataFrame(filas)


def _parser_pib_sheet(
    path: Path, sheet: str, level_suffix: str,
    include_pond: bool = False,
) -> pd.DataFrame:
    """Lee una hoja del archivo pib_gasto. `level_suffix` es '_nom', '_real',
    '_nom_acum', '_real_acum'. Las ponderaciones solo existen en PIB$_Trim."""
    try:
        raw = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    except Exception as e:
        log.warning("PIB %s no se pudo leer: %s", sheet, e)
        return pd.DataFrame()

    year_row = _detectar_year_row(raw)
    if year_row is None:
        log.warning("PIB %s: no se encontró fila de años", sheet)
        return pd.DataFrame()
    col_dates = _build_col_dates(raw, year_row)
    if not col_dates:
        log.warning("PIB %s: 0 fechas detectadas", sheet)
        return pd.DataFrame()

    # Sección de valores absolutos: filas year_row+2 hasta el siguiente
    # encabezado de sección. PIB$_Trim tiene "PONDERACION"; PIBK_Trim tiene
    # "TASAS DE CRECIMIENTO", "INCIDENCIA"; ambas en mayúsculas.
    barrera_keywords = (
        "ponderacion", "ponderación",
        "tasas de crecimiento",
        "incidencia",
    )
    barrera = raw.shape[0]
    for i in range(year_row + 2, raw.shape[0]):
        s = str(raw.iloc[i, 0]).lower()
        if any(k in s for k in barrera_keywords):
            barrera = i
            break

    df_levels = _extraer_seccion(
        raw, col_dates,
        rango=(year_row + 2, barrera),
        mapping=_LEVEL_MAP, suffix=level_suffix,
    )

    frames = [df_levels]
    if include_pond and barrera < raw.shape[0]:
        df_pond = _extraer_seccion(
            raw, col_dates,
            rango=(barrera + 1, raw.shape[0]),
            mapping=_POND_MAP, suffix="",
        )
        frames.append(df_pond)

    if not frames:
        return pd.DataFrame()
    return pd.concat([f for f in frames if not f.empty], ignore_index=True)


def parser_pib_gasto(path: Path) -> pd.DataFrame:
    """Lee las 4 hojas del archivo pib_gasto:
      - PIB$_Trim       → ct_nom, cpr_nom, ..., pib_nom + pond_*
      - PIB$_Trim_Acum  → *_nom_acum (acumulado a Q4 = anual)
      - PIBK_Trim       → *_real (constantes 2018)
      - PIBK_Trim_Acum  → *_real_acum
    """
    frames: list[pd.DataFrame] = []
    for sheet, suffix, include_pond in [
        ("PIB$_Trim",      "_nom",       True),
        ("PIB$_Trim_Acum", "_nom_acum",  False),
        ("PIBK_Trim",      "_real",      False),
        ("PIBK_Trim_Acum", "_real_acum", False),
    ]:
        df = _parser_pib_sheet(path, sheet, suffix, include_pond=include_pond)
        if not df.empty:
            log.info("PIB gasto [%s]: %d filas", sheet, len(df))
            frames.append(df)

    if not frames:
        log.warning("PIB gasto: 0 filas extraídas")
        return pd.DataFrame()
    out = pd.concat(frames, ignore_index=True).sort_values(
        ["variable_id", "fecha"]).reset_index(drop=True)
    # Alias legacy: pib_nom es el ID que el resto del frontend ya usa.
    # Reemplazamos `pib_nom` (de PIB$_Trim) por el mismo nombre. El alias
    # `pib_real` (de PIBK_Trim) también se mantiene como ID legacy.
    return out


# ---------------------------------------------------------------------------
# Parser: Tasa Interbancaria (operaciones_interb)
# Annual section first, then "Mensual" marker, then year+month rows.
# Col 1 = year or month name  |  col 3 = tasa prom. ponderada
# ---------------------------------------------------------------------------
def parser_ti_intb(path: Path) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("TI Interbancaria no se pudo leer: %s", e)
        return pd.DataFrame()

    # Find "Mensual" marker
    mensual_row = None
    for i in range(len(raw)):
        cell = str(raw.iloc[i, 1]).strip().lower()
        if cell == "mensual":
            mensual_row = i
            break
    if mensual_row is None:
        log.warning("TI Interbancaria: no se encontró sección 'Mensual'")
        return pd.DataFrame()

    def _to_year(v) -> int | None:
        try:
            iv = int(float(str(v).split()[0]))
            return iv if 1990 <= iv <= 2100 else None
        except (TypeError, ValueError):
            return None

    filas: list[dict] = []
    anio_actual: int | None = None
    for i in range(mensual_row + 1, len(raw)):
        cell = str(raw.iloc[i, 1]).strip()
        yr = _to_year(cell)
        if yr is not None:
            anio_actual = yr
            continue  # annual summary row, skip
        mes_idx = _mes_a_idx(cell)
        if mes_idx is None or anio_actual is None:
            continue
        valor = pd.to_numeric(raw.iloc[i, 3], errors="coerce")
        if pd.isna(valor):
            continue
        filas.append({"variable_id": "tib_rd", "fecha": date(anio_actual, mes_idx, 1), "valor": float(valor)})

    df = pd.DataFrame(filas).sort_values("fecha").reset_index(drop=True)
    if df.empty:
        log.warning("TI Interbancaria: 0 filas mensales parsadas")
    return df


# ---------------------------------------------------------------------------
# Parser genérico: tasas activas/pasivas
# Col 0 = "Enero YYYY" (first of year) or just month name; col prom = weighted avg
# ---------------------------------------------------------------------------
def _parser_tasa_bm(
    path: Path, variable_id: str, prom_col: int, sheet: str | int = 0
) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    except Exception as e:
        log.warning("%s no se pudo leer: %s", variable_id, e)
        return pd.DataFrame()

    filas: list[dict] = []
    anio_actual: int | None = None
    for _, row in raw.iterrows():
        cell = str(row.iloc[0]).strip()
        parts = cell.split()
        mes_str = parts[0] if parts else ""
        mes_idx = _mes_a_idx(mes_str)
        if mes_idx is None:
            continue
        # Extract year if present (e.g., "Enero 2017")
        if len(parts) >= 2:
            try:
                yr = int(parts[-1])
                if 1990 <= yr <= 2100:
                    anio_actual = yr
            except ValueError:
                pass
        if anio_actual is None:
            continue
        valor = pd.to_numeric(row.iloc[prom_col], errors="coerce") if prom_col < len(row) else None
        if valor is None or pd.isna(valor):
            continue
        filas.append({"variable_id": variable_id, "fecha": date(anio_actual, mes_idx, 1), "valor": float(valor)})

    df = pd.DataFrame(filas).sort_values("fecha").reset_index(drop=True)
    if df.empty:
        log.warning("%s: 0 filas parsadas", variable_id)
    return df


def _parser_tasa_bm_multi(
    path: Path, mapping: list[tuple[str, int]], sheet: str | int = 0
) -> pd.DataFrame:
    """Como `_parser_tasa_bm` pero extrae varias columnas (var_id, col_idx)
    desde el mismo archivo en una sola pasada."""
    try:
        raw = pd.read_excel(path, sheet_name=sheet, header=None, dtype=object)
    except Exception as e:
        log.warning("tasa multi-col no se pudo leer: %s", e)
        return pd.DataFrame()

    filas: list[dict] = []
    anio_actual: int | None = None
    for _, row in raw.iterrows():
        cell = str(row.iloc[0]).strip()
        parts = cell.split()
        mes_str = parts[0] if parts else ""
        mes_idx = _mes_a_idx(mes_str)
        if mes_idx is None:
            continue
        if len(parts) >= 2:
            try:
                yr = int(parts[-1])
                if 1990 <= yr <= 2100:
                    anio_actual = yr
            except ValueError:
                pass
        if anio_actual is None:
            continue
        for var_id, col in mapping:
            if col >= len(row):
                continue
            v = pd.to_numeric(row.iloc[col], errors="coerce")
            if pd.notna(v):
                filas.append({"variable_id": var_id,
                              "fecha": date(anio_actual, mes_idx, 1),
                              "valor": float(v)})
    df = pd.DataFrame(filas).sort_values(["variable_id", "fecha"]).reset_index(drop=True)
    if df.empty:
        log.warning("tasa multi-col: 0 filas parsadas (mapping=%s)", mapping)
    else:
        from collections import Counter
        log.info("tasa multi-col: %s", dict(Counter(df["variable_id"])))
    return df


def parser_ti_activa(path: Path) -> pd.DataFrame:
    """tbm_activad.xlsx: tia_prom_pond_rd (col 7, prom ponderado),
    tia_90 ("0 a 90 días" ~ col 1), tia_5yr ("2 a 5 años" ~ col 5).

    El layout exacto puede variar; aquí asumimos las columnas del file
    "tbm_activad.xlsx" del BCRD (Activas hoja sheet="Activas")."""
    return _parser_tasa_bm_multi(
        path,
        mapping=[
            ("tia_prom_pond_rd", 7),
            ("tia_prom_pond",    7),  # alias legacy
            ("tia_90",           1),
            ("tia_5yr",          5),
        ],
        sheet="Activas",
    )


def parser_ti_pasiva(path: Path) -> pd.DataFrame:
    return _parser_tasa_bm(path, "tip_prom_pond", prom_col=9, sheet=0)


# ---------------------------------------------------------------------------
# Parser: Crédito por sector (formato transpuesto)
# Row 7: col 0 = "SECTOR 4,5,6,8", cols 1+ = Timestamps (fechas mensuales)
# Rows 10+: sector rows (sectors in rows, dates in columns)
# ---------------------------------------------------------------------------
_CREDITO_MAP: list[tuple[str, str]] = [
    ("sector privado m/n",                  "prest_tot"),
    ("agricultura, silvicultura y pesca",   "prest_agr"),
    ("industrias manufactureras",           "prest_ind"),
    ("construcci",                          "prest_con"),
    ("comercio al por mayor",               "prest_com"),
    ("adquisici",                           "prest_viv"),
    ("tarjetas de cr",                      "prest_tar"),
    ("otros pr",                            "prest_cons"),
]


def parser_credito_sect(path: Path) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, header=None)
    except Exception as e:
        log.warning("Crédito sector no se pudo leer: %s", e)
        return pd.DataFrame()

    def _is_date(v) -> bool:
        return isinstance(v, (pd.Timestamp, _dt.datetime, _dt.date))

    header_row = None
    for i in range(min(15, len(raw))):
        if _is_date(raw.iloc[i, 1]):
            header_row = i
            break
    if header_row is None:
        log.warning("Crédito sector: no se encontró fila de fechas")
        return pd.DataFrame()

    # Extract dates: Timestamp/datetime → date; string preliminar 'dic-25*' → date
    # Snap a inicio de mes (día 1) para alinear con otras series mensuales.
    date_cols: dict[int, date] = {}
    n_prelim = 0
    for j in range(1, raw.shape[1]):
        ts = raw.iloc[header_row, j]
        if _is_date(ts):
            d = ts.date() if isinstance(ts, _dt.datetime) else ts if isinstance(ts, _dt.date) else ts.date()
            date_cols[j] = date(d.year, d.month, 1)  # snap a día 1
        elif isinstance(ts, str):
            d = _parse_bcrd_date_str(ts)
            if d is not None:
                date_cols[j] = d
                n_prelim += 1

    if not date_cols:
        log.warning("Crédito sector: 0 fechas detectadas")
        return pd.DataFrame()
    if n_prelim > 0:
        log.info("Crédito sector: %d fechas preliminares (con *) procesadas", n_prelim)

    # Find sector rows by keyword
    frames: list[pd.DataFrame] = []
    for i in range(header_row + 1, len(raw)):
        label = str(raw.iloc[i, 0]).strip().lower()
        var_id: str | None = None
        for kw, vid in _CREDITO_MAP:
            if kw in label:
                var_id = vid
                break
        if var_id is None:
            continue
        filas = []
        for j, dt in date_cols.items():
            valor = pd.to_numeric(raw.iloc[i, j], errors="coerce")
            if not pd.isna(valor):
                filas.append({"variable_id": var_id, "fecha": dt, "valor": float(valor)})
        if filas:
            frames.append(pd.DataFrame(filas))

    if not frames:
        log.warning("Crédito sector: 0 filas extraídas")
        return pd.DataFrame()
    return pd.concat(frames, ignore_index=True).sort_values(["variable_id", "fecha"]).reset_index(drop=True)


# ---------------------------------------------------------------------------
# Parser: Agregados monetarios
# Row 12+: col 0 = year (propagates), col 1 = month abbrev (Ene, Feb, Dic...)
# Col 4 = M1 total (m1_rd)  |  Col 6 = Valores distintos de acciones MN (sm_bcrd_vc)
# ---------------------------------------------------------------------------
def parser_agregados(path: Path) -> pd.DataFrame:
    """Agregados monetarios BCRD: extrae M1 (col 4), M2 (col 7), M3 (col 11),
    siguiendo `Data_dgapf_gg1.R`. Adicional: `m1_rd` (alias legacy de M1) y
    `sm_bcrd_vc` (col 6, en versiones antiguas)."""
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("Agregados monetarios no se pudo leer: %s", e)
        return pd.DataFrame()

    def _to_year(v) -> int | None:
        try:
            iv = int(float(v))
            return iv if 1990 <= iv <= 2100 else None
        except (TypeError, ValueError):
            return None

    # variable_id → (col_idx_0based, descripción para log)
    # En el R original (1-indexed): col 5=M1, col 8=M2, col 12=M3
    # Aquí restamos 1 → cols 4, 7, 11.
    EXTRACT = [
        ("M1",         4),
        ("M2",         7),
        ("M3",        11),
        ("m1_rd",      4),  # alias legacy (mismo valor que M1)
        ("sm_bcrd_vc", 6),  # valores en circulación (col 6 0-indexed)
    ]
    buckets: dict[str, list[dict]] = {vid: [] for vid, _ in EXTRACT}

    anio_actual: int | None = None
    for _, row in raw.iterrows():
        yr = _to_year(row.iloc[0])
        if yr is not None:
            anio_actual = yr
        if anio_actual is None:
            continue
        mes_idx = _mes_a_idx(row.iloc[1] if len(row) > 1 else None)
        if mes_idx is None:
            continue
        dt = date(anio_actual, mes_idx, 1)
        for vid, col in EXTRACT:
            if len(row) <= col:
                continue
            v = pd.to_numeric(row.iloc[col], errors="coerce")
            if pd.notna(v):
                buckets[vid].append({"variable_id": vid, "fecha": dt, "valor": float(v)})

    frames = [pd.DataFrame(rows) for rows in buckets.values() if rows]
    if not frames:
        log.warning("Agregados monetarios: 0 filas parsadas")
        return pd.DataFrame()
    counts = {vid: len(rows) for vid, rows in buckets.items()}
    log.info("Agregados monetarios: %s", counts)
    return pd.concat(frames, ignore_index=True).sort_values(["variable_id", "fecha"]).reset_index(drop=True)


# ---------------------------------------------------------------------------
# Parser: IPC transables / no transables (ipc_tnt_base_2019-2020.xls)
# Layout: skip=4, col 1 (mes en español), col 'General' = transables,
# col 'No Transables' = no transables. Inicio: 1999-02.
# ---------------------------------------------------------------------------
def parser_ipc_tnt(path: Path) -> pd.DataFrame:
    """ipc_tnt_base_2019-2020.xls. Layout (skip=4, header=0):
        col 0: año (esporádico),  col 1: mes ES o "Dic. YYYY",
        col 2: General  (=inf_trans),  col 8: No Transables (=inf_no_trans).
    Filtramos filas con mes ES en col 1, e inicio 1999-02."""
    try:
        raw = pd.read_excel(path, skiprows=4, header=0, dtype=object)
    except Exception as e:
        log.warning("ipc_tnt no se pudo leer: %s", e)
        return pd.DataFrame()

    if raw.shape[1] < 9:
        log.warning("ipc_tnt: archivo con solo %d cols, esperaba >=9", raw.shape[1])
        return pd.DataFrame()

    mask = raw.iloc[:, 1].apply(_es_mes_es)
    sub = raw[mask].reset_index(drop=True)
    if sub.empty:
        log.warning("ipc_tnt: 0 filas con mes ES en col 1")
        return pd.DataFrame()

    fechas = _add_meses(1999, 2, len(sub))
    valores_trans = pd.to_numeric(sub.iloc[:, 2], errors="coerce")
    valores_no_trans = pd.to_numeric(sub.iloc[:, 8], errors="coerce")

    filas: list[dict] = []
    for fecha, vt, vn in zip(fechas, valores_trans, valores_no_trans):
        if pd.notna(vt):
            filas.append({"variable_id": "inf_trans", "fecha": fecha, "valor": float(vt)})
        if pd.notna(vn):
            filas.append({"variable_id": "inf_no_trans", "fecha": fecha, "valor": float(vn)})
    log.info("ipc_tnt: %d filas (inf_trans + inf_no_trans)", len(filas))
    return pd.DataFrame(filas)


# ---------------------------------------------------------------------------
# Parser: IPC por grupos (ipc_grupos_base_2019-2020.xls) — 12 variables
# ---------------------------------------------------------------------------
def parser_ipc_grupos(path: Path) -> pd.DataFrame:
    """Extrae las 12 inflaciones interanuales por grupo de bienes y servicios.
    Mapeo R → IDs catálogo, vía índices de columna (0-based) de la hoja:
        col 1 (R ...2)  → inf_AyBNA  (Alimentos y Bebidas No Alcohólicas)
        cols 'y Tabaco' → inf_BAyT
        cols 'y Calzado'→ inf_vestir
        col 7  (R ...8) → inf_viv
        col 9  (R ...10)→ inf_mue
        col 11 (R ...12)→ inf_sal
        col 13 (R ...14)→ inf_transport
        col 15 (R ...16)→ inf_com
        col 17 (R ...18)→ inf_Ryc
        col 19 (R ...20)→ inf_edu
        col 21 (R ...22)→ inf_RyH
        col 23 (R ...24)→ inf_BySD
    """
    try:
        raw = pd.read_excel(path, skiprows=4, header=None, dtype=object)
    except Exception as e:
        log.warning("ipc_grupos no se pudo leer: %s", e)
        return pd.DataFrame()

    # En R `...1` es la col 0; filtra filas con mes ES en col 0
    mask = raw.iloc[:, 0].apply(_es_mes_es)
    sub = raw[mask].reset_index(drop=True)
    if sub.empty:
        log.warning("ipc_grupos: 0 filas con mes en col 0")
        return pd.DataFrame()
    fechas = _add_meses(1999, 1, len(sub))

    # Mapeo (var_id, col_idx_0based)
    mapping = [
        ("inf_AyBNA",    1),
        ("inf_BAyT",     3),
        ("inf_vestir",   5),
        ("inf_viv",      7),
        ("inf_mue",      9),
        ("inf_sal",     11),
        ("inf_transport",13),
        ("inf_com",     15),
        ("inf_Ryc",     17),
        ("inf_edu",     19),
        ("inf_RyH",     21),
        ("inf_BySD",    23),
    ]
    filas: list[dict] = []
    for var_id, col in mapping:
        if col >= sub.shape[1]:
            log.warning("ipc_grupos: col %d fuera de rango para %s", col, var_id)
            continue
        valores = pd.to_numeric(sub.iloc[:, col], errors="coerce")
        for f, v in zip(fechas, valores):
            if pd.notna(v):
                filas.append({"variable_id": var_id, "fecha": f, "valor": float(v)})
    log.info("ipc_grupos: %d filas (12 grupos)", len(filas))
    return pd.DataFrame(filas)


# ---------------------------------------------------------------------------
# Parser: Expectativas Económicas → ICI (Historico-EOE-(Mensual).xlsx)
# Inicio: 2006-07 (= pos_ene_07 - 6 en el R)
# ---------------------------------------------------------------------------
def parser_expE(path: Path) -> pd.DataFrame:
    try:
        raw = pd.read_excel(path, skiprows=5, header=None, dtype=object)
    except Exception as e:
        log.warning("expE no se pudo leer: %s", e)
        return pd.DataFrame()

    # En R: indicadores$ICI[(pos_ene_07-6):...] <- unlist(expE[,12])
    # → col 11 (0-based), inicio 2006-07.
    if raw.shape[1] < 12:
        log.warning("expE: tiene solo %d cols, esperaba >=12", raw.shape[1])
        return pd.DataFrame()
    valores = pd.to_numeric(raw.iloc[:, 11], errors="coerce").dropna()
    if valores.empty:
        log.warning("expE: 0 filas numéricas en col 11")
        return pd.DataFrame()
    fechas = _add_meses(2006, 7, len(valores))
    df = pd.DataFrame({
        "variable_id": "ICI",
        "fecha": fechas,
        "valor": valores.astype(float).values,
    })
    log.info("expE: %d filas ICI", len(df))
    return df


# ---------------------------------------------------------------------------
# Parser: Balanza de Pagos (bpagos_trim_6.xls) — trimestral
# Fila 6 = año (repetido 4 veces); Fila 9 = trimestre (E-M, A-J, J-S, O-D)
# Filas 11+ = conceptos (Viajes, IED, Ingreso Primario, etc.)
# ---------------------------------------------------------------------------
# (fila_excel_0idx, variable_id, signo)
# signo = -1 → invertir (convención MBP6: negativo en Cuenta Financiera = ENTRADA
#               de US$ al país; lo presentamos como positivo para que sea intuitivo)
# signo = +1 → dejar tal cual (Cuenta Corriente: crédito ya viene positivo)
_BOP_MAP: list[tuple[int, str, int]] = [
    # ─── Cuenta Corriente — totales y componentes ───────────────────────────
    (11, "saldo_cc_bp",     +1),  # 1. Cuenta Corriente (saldo)
    (12, "bal_bys_bp",      +1),  # 1.1 Balanza de Bienes y Servicios (saldo)
    (13, "bal_bienes_bp",   +1),  # 1.1.1 Balanza de Bienes (X-M)
    (14, "x_bp",            +1),  # Exportaciones bienes
    (17, "m_bp",            +1),  # Importaciones bienes
    (21, "bal_serv_bp",     +1),  # 1.1.2 Balanza de Servicios (saldo)
    (22, "serv_cred_bp",    +1),  # Servicios crédito (turismo + manuf + otros)
    (23, "viajes_bp",       +1),  # Viajes (turismo)
    (26, "serv_deb_bp",     +1),  # Servicios débito (fletes + otros)
    (30, "ingr_prim_bp",    +1),  # 1.2 Ingreso Primario neto
    (34, "renta_inv_bp",    +1),  # Renta de la Inversión neta
    (35, "ied_renta_bp",    +1),  # Renta IED neta
    (48, "ingr_sec_bp",     +1),  # 1.3 Ingreso Secundario neto
    (49, "ingr_sec_cred_bp",+1),  # Ingreso Sec. crédito (remesas + transf)
    (50, "rem_fam_bp_cred", +1),  # Remesas Familiares crédito
    (52, "ingr_sec_deb_bp", +1),  # Ingreso Sec. débito
    (53, "rem_fam_bp_deb",  +1),  # Remesas Familiares débito
    # ─── Cuenta Capital ────────────────────────────────────────────────────
    (56, "cta_cap_bp",      +1),  # 2. Cuenta de Capital
    # ─── Cuenta Financiera (flip: + = ENTRADA neta de capital) ─────────────
    (60, "cta_fin_bp",      -1),
    (61, "ied_bp",          -1),  # Inversión Directa
    (62, "inv_cart_bp",     -1),  # Inversión de Cartera
    # ─── Errores y Omisiones + Financiamiento ──────────────────────────────
    (70, "eyo_bp",          +1),  # 6. Errores y Omisiones
    (73, "act_res_bp",      +1),  # 7. Activos de Reservas (acumulación)
]


def parser_balanza_pagos(path: Path) -> pd.DataFrame:
    """Balanza de Pagos BCRD (trimestral, MM US$). Extrae conceptos clave para
    el dashboard externo: ingresos por turismo (Viajes), IED, rentas,
    transferencias corrientes, etc."""
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("balanza_pagos no se pudo leer: %s", e)
        return pd.DataFrame()

    # Find year row (row with multiple years 1990-2100)
    import re
    year_row = None
    for i in range(min(15, raw.shape[0])):
        c = sum(1 for j in range(1, raw.shape[1])
                if pd.notna(raw.iloc[i, j])
                and re.match(r'^\d{4}', str(raw.iloc[i, j]).strip())
                and 1990 <= int(re.match(r'^\d{4}', str(raw.iloc[i, j]).strip()).group(0)) <= 2100)
        if c > 5:
            year_row = i
            break
    if year_row is None:
        log.warning("balanza_pagos: fila de años no encontrada")
        return pd.DataFrame()

    # Quarter row: tolera sufijos preliminares (*, (p)) — ej "E-M*" → "E-M"
    def _clean_q(s: str) -> str:
        return str(s).strip().rstrip("*").rstrip().rstrip("()p").strip().upper()
    quarter_row = None
    for i in range(year_row + 1, min(year_row + 6, raw.shape[0])):
        c = sum(1 for j in range(1, raw.shape[1])
                if _clean_q(raw.iloc[i, j]) in ("E-M", "A-J", "J-S", "O-D"))
        if c > 5:
            quarter_row = i
            break
    if quarter_row is None:
        log.warning("balanza_pagos: fila de trimestres no encontrada")
        return pd.DataFrame()

    # Build col → date map (acepta '2025', '2025*', '2025 (p)' en year row)
    col_dates: dict[int, date] = {}
    current_year: int | None = None
    Q_MAP = {"E-M": 1, "A-J": 4, "J-S": 7, "O-D": 10}
    for j in range(1, raw.shape[1]):
        v_year = raw.iloc[year_row, j]
        if pd.notna(v_year):
            m = re.match(r'^\s*(\d{4})', str(v_year).strip())
            if m:
                yr = int(m.group(1))
                if 1990 <= yr <= 2100:
                    current_year = yr
        if current_year is None:
            continue
        q_str = _clean_q(raw.iloc[quarter_row, j])
        month = Q_MAP.get(q_str)
        if month is not None:
            col_dates[j] = date(current_year, month, 1)

    filas: list[dict] = []
    for row_idx, vid, signo in _BOP_MAP:
        if row_idx >= raw.shape[0]:
            continue
        for j, dt in col_dates.items():
            val = pd.to_numeric(raw.iloc[row_idx, j], errors="coerce")
            if not pd.isna(val):
                filas.append({"variable_id": vid, "fecha": dt,
                              "valor": signo * float(val)})
    df = pd.DataFrame(filas)
    log.info("balanza_pagos: %d filas (%d vars)", len(df), df["variable_id"].nunique() if not df.empty else 0)
    return df


# ---------------------------------------------------------------------------
# Parser: Indicadores OSD (credito_osd.xlsx) — Otras Sociedades de Depósitos
# Fila 4: fechas mensuales (Timestamps). Snap a inicio de mes.
# Mapeo de filas clave de la hoja.
# ---------------------------------------------------------------------------
_OSD_MAP: list[tuple[int, str, str]] = [
    # (fila_excel_0idx, variable_id, unidad/comentario)
    (7,  "aen_osd_act",         "MM US$ — activos externos OSD"),
    (10, "aen_osd_pas",         "MM US$ — pasivos externos OSD"),
    (18, "prest_tot_osd",       "MM RD$ — total préstamos OSD"),
    (19, "prest_mn_osd",        "MM RD$ — préstamos en MN"),
    (22, "prest_me_usd_osd",    "MM US$ — préstamos en ME"),
    (25, "prest_sp_tot_osd",    "MM RD$ — préstamos sector público"),
    (32, "prest_spr_tot_osd",   "MM RD$ — préstamos sector privado"),
    (46, "dep_tot_osd",         "MM RD$ — depósitos totales OSD"),
    (53, "dep_sp_osd",          "MM RD$ — depósitos sector público"),
    (60, "dep_spr_osd",         "MM RD$ — depósitos sector privado"),
    (79, "tc_fin_mes_osd",      "RD$/US$ — TC fin de mes"),
]


def parser_credito_osd(path: Path) -> pd.DataFrame:
    """Indicadores OSD (Otras Sociedades de Depósitos): activos/pasivos externos,
    préstamos por moneda, depósitos por sector. Frecuencia mensual."""
    try:
        raw = pd.read_excel(path, header=None, dtype=object)
    except Exception as e:
        log.warning("credito_osd no se pudo leer: %s", e)
        return pd.DataFrame()

    # Row 4: fechas. Snap a inicio de mes. Acepta tanto Timestamp como
    # string preliminar tipo 'dic-25*', '30-abr-26*' (cifras provisionales).
    col_dates: dict[int, date] = {}
    n_prelim = 0
    for j in range(1, raw.shape[1]):
        v = raw.iloc[4, j] if raw.shape[0] > 4 else None
        if isinstance(v, pd.Timestamp):
            col_dates[j] = date(v.year, v.month, 1)
        elif isinstance(v, _dt.datetime):
            col_dates[j] = date(v.year, v.month, 1)
        elif isinstance(v, str):
            d = _parse_bcrd_date_str(v)
            if d is not None:
                col_dates[j] = d
                n_prelim += 1
    if not col_dates:
        log.warning("credito_osd: 0 fechas en fila 4")
        return pd.DataFrame()
    if n_prelim > 0:
        log.info("credito_osd: %d fechas preliminares (con *) procesadas", n_prelim)

    filas: list[dict] = []
    for row_idx, vid, _ in _OSD_MAP:
        if row_idx >= raw.shape[0]:
            continue
        for j, dt in col_dates.items():
            val = pd.to_numeric(raw.iloc[row_idx, j], errors="coerce")
            if not pd.isna(val):
                filas.append({"variable_id": vid, "fecha": dt, "valor": float(val)})

    df = pd.DataFrame(filas)
    if not df.empty:
        df = df.drop_duplicates(subset=["variable_id", "fecha"], keep="last")
    log.info("credito_osd: %d filas (%d vars)", len(df), df["variable_id"].nunique() if not df.empty else 0)
    return df


# ---------------------------------------------------------------------------
# Parser: Operaciones monetarias → deprem_cp (depósitos remunerados CP)
# Archivo: operaciones_monetarias.xlsx
# Columna 0: Fecha (mezcla Date/Timestamp y strings tipo "1-ene-25")
# Columna "Ventanilla Directa de Depósitos Remunerados de Corto Plazo"
# ---------------------------------------------------------------------------
_MESES_ES_NUM: dict[str, int] = {
    "ene": 1, "enero": 1, "feb": 2, "febrero": 2,
    "mar": 3, "marzo": 3, "abr": 4, "abril": 4,
    "may": 5, "mayo": 5, "jun": 6, "junio": 6,
    "jul": 7, "julio": 7, "ago": 8, "agosto": 8,
    "sep": 9, "sept": 9, "septiembre": 9,
    "oct": 10, "octubre": 10, "nov": 11, "noviembre": 11,
    "dic": 12, "diciembre": 12,
}


def _parse_fecha_es(v) -> _dt.date | None:
    """Parsea celda de fecha: Timestamp, datetime, date, o string '1-ene-25'."""
    import re
    if v is None or (isinstance(v, float) and pd.isna(v)):
        return None
    if isinstance(v, pd.Timestamp):
        return v.date()
    if isinstance(v, _dt.datetime):
        return v.date()
    if isinstance(v, _dt.date):
        return v
    s = str(v).strip().rstrip("*").strip()
    m = re.match(r"^(\d{1,2})[-/](\w+)[-/](\d{2,4})$", s)
    if not m:
        return None
    try:
        dia = int(m.group(1))
        mes_txt = m.group(2).lower()
        anio = m.group(3)
        if mes_txt not in _MESES_ES_NUM:
            return None
        mes = _MESES_ES_NUM[mes_txt]
        if len(anio) == 2:
            n = int(anio)
            anio = 2000 + n if n <= 30 else 1900 + n
        else:
            anio = int(anio)
        return _dt.date(anio, mes, dia)
    except (ValueError, TypeError):
        return None


def parser_dep_cp(path: Path) -> pd.DataFrame:
    """Operaciones monetarias BCRD → variable diaria `deprem_cp`.

    Equivalente al R:
        dep_cp <- read_excel("op_mon.xlsx", skip=7, col_types="list")
        dep_cp$deprem_cp <- as.numeric(dep_cp$"Ventanilla Directa de Depósitos
                                              Remunerados de Corto Plazo")
    """
    try:
        raw = pd.read_excel(path, skiprows=7)
    except Exception as e:
        log.warning("operaciones_monetarias no se pudo leer: %s", e)
        return pd.DataFrame()

    # Buscar columna de Ventanilla Directa
    col_dep = None
    for c in raw.columns:
        s = str(c).lower()
        if "ventanilla" in s and "directa" in s and "corto" in s:
            col_dep = c
            break
    if col_dep is None:
        # fallback: buscar 'remunerados de corto'
        for c in raw.columns:
            s = str(c).lower()
            if "remunerad" in s and "corto" in s:
                col_dep = c
                break
    if col_dep is None:
        log.warning("operaciones_monetarias: col 'Ventanilla Directa' no hallada. Cols: %s", list(raw.columns)[:10])
        return pd.DataFrame()

    col_fecha = raw.columns[0]
    fechas = raw[col_fecha].apply(_parse_fecha_es)
    valores = pd.to_numeric(raw[col_dep], errors="coerce")

    df = pd.DataFrame({
        "variable_id": "deprem_cp",
        "fecha": fechas,
        "valor": valores,
    }).dropna(subset=["fecha", "valor"]).reset_index(drop=True)
    log.info("deprem_cp: %d filas (%s..%s)",
             len(df), df["fecha"].min() if len(df) else "?",
             df["fecha"].max() if len(df) else "?")
    return df


# ---------------------------------------------------------------------------
# Parser: Encaje (encaje_bancario.xlsx) — encajemn + encajeme
# ---------------------------------------------------------------------------
def parser_encaje(path: Path) -> pd.DataFrame:
    """Extrae encajemn_d_q (col ncol-9) y encajeme_d_q (col ncol-2)
    + alias legacy encaje_mn = encajemn_d_q. Inicio: 2001-12."""
    try:
        raw = pd.read_excel(path, skiprows=11, header=None, dtype=object)
    except Exception as e:
        log.warning("encaje no se pudo leer: %s", e)
        return pd.DataFrame()

    # dropna en filas: solo filas completas (R hace na.omit)
    raw = raw.dropna(how="any").reset_index(drop=True)
    if raw.empty:
        return pd.DataFrame()
    ncol = raw.shape[1]
    # R usa ncol-8 (mn) y ncol-1 (me) en 1-indexed, equivalente a ncol-9 y ncol-2 en 0-indexed
    col_mn = ncol - 9
    col_me = ncol - 2
    if col_mn < 0 or col_me < 0:
        log.warning("encaje: cols (ncol=%d) fuera de rango", ncol)
        return pd.DataFrame()

    fechas = _add_meses(2001, 12, len(raw))
    valores_mn = pd.to_numeric(raw.iloc[:, col_mn], errors="coerce")
    valores_me = pd.to_numeric(raw.iloc[:, col_me], errors="coerce")

    filas: list[dict] = []
    for fecha, v_mn, v_me in zip(fechas, valores_mn, valores_me):
        if pd.notna(v_mn):
            filas.append({"variable_id": "encajemn_d_q", "fecha": fecha, "valor": float(v_mn)})
            filas.append({"variable_id": "encaje_mn",    "fecha": fecha, "valor": float(v_mn)})  # alias legacy
        if pd.notna(v_me):
            filas.append({"variable_id": "encajeme_d_q", "fecha": fecha, "valor": float(v_me)})
    log.info("encaje: %d filas", len(filas))
    return pd.DataFrame(filas)


# ---------------------------------------------------------------------------
# Wrapper para llegada_tur: filtra observaciones espurias y proyecciones
# futuras que el Excel BCRD incluye después del último mes real.
# ---------------------------------------------------------------------------
def _llegada_tur_wrapper(path: Path) -> pd.DataFrame:
    df = parser_filas_mes(
        path, "se_cc_numtur", skip=7, mes_col=0, val_col=1,
        start_year=1984, start_month=1,
    )
    if df.empty:
        return df
    df["fecha"] = pd.to_datetime(df["fecha"])
    today_p1m = pd.Timestamp.today().normalize() + pd.DateOffset(months=1)
    # Drop fechas futuras (BCRD a veces incluye proyecciones)
    df = df[df["fecha"] <= today_p1m]
    # Drop valores espurios en fechas recientes:
    #   - post-2010 con < 100k es claramente erróneo (mínimo histórico ≈ 200k)
    #   - pre-2010 con < 50k es plausible (data antigua, RD tenía menos turistas)
    mask_post2010_bajo = (df["fecha"] >= "2010-01-01") & (df["valor"] < 100_000)
    df = df[~mask_post2010_bajo]
    log.info("llegada_tur: %d filas (post-filtro espurios + futuros)", len(df))
    df["fecha"] = df["fecha"].dt.date
    return df.reset_index(drop=True)


# ---------------------------------------------------------------------------
# Registro slug → parser
# ---------------------------------------------------------------------------
# Mapeos calibrados contra Data_dgapf 2.R. mes_col/val_col son índices 0-based
# tras `skiprows=skip`, ANTES de filtrar.
PARSER_REGISTRY: dict[str, Callable[[Path], pd.DataFrame]] = {
    # ---------- Precios ----------
    "ipc":           lambda p: parser_filas_mes(
        p, "ipc_rd", skip=5, mes_col=1, val_col=2,
        start_year=1984, start_month=1,
    ),
    # ---------- Sector real ----------
    "imae":          lambda p: parser_filas_mes(
        p, "imae", skip=7, mes_col=1, val_col=2,
        start_year=2007, start_month=1,
    ),
    # ---------- Sector externo ----------
    "imp_petroleo":  lambda p: parser_filas_mes(
        p, "imp_pd_va", skip=5, mes_col=0, val_col=-1,
        start_year=2010, start_month=1, dropna_first=True,
    ),
    "rem_fam":       lambda p: parser_pivot_anio_x_mes(
        p, "rem_fam", skip=5, multiplicador=1 / 1_000_000,
    ),
    # ---------- Sector turismo ----------
    "llegada_tur":   lambda p: _llegada_tur_wrapper(p),
    # ---------- Mercado cambiario ----------
    "tcn_dia":       parser_tcn_dia,
    "tc_ent_fin":    parser_tc_ent_fin,
    "compra_dolar":  lambda p: parser_filas_mes(
        p, "compra_fx_tot", skip=12, val_col=-4,
        start_year=2004, start_month=1, dropna_first=True,
        filter_meses=False,
    ),
    # ---------- Sector monetario y financiero ----------
    "base_mon":      lambda p: parser_filas_mes(
        p, "bmr_rd", skip=11, val_col=5,
        start_year=2001, start_month=12, dropna_first=True,
        filter_meses=False,
    ),
    "encaje":        parser_encaje,
    "tpm":           parser_tpm,
    # ---------- Inflación por componentes ----------
    "ipc_tnt":       parser_ipc_tnt,
    "ipc_grupos":    parser_ipc_grupos,
    # ---------- Expectativas ----------
    "expE":          parser_expE,
    # ---------- Operaciones monetarias (depósitos remunerados CP) ----------
    "op_mon":        parser_dep_cp,
    # ---------- Sector externo: Balanza de Pagos ----------
    "balanza_pagos": parser_balanza_pagos,
    # ---------- Sector monetario: Indicadores OSD ----------
    "credito_osd":   parser_credito_osd,
    # ---------- Entorno internacional ----------
    "embi":          parser_embi,
    # ---------- Precios ----------
    "ipc_sub":       parser_ipc_sub,
    # ---------- Sector externo ----------
    "rin":           parser_rin,
    # ---------- Sector real (trimestral) ----------
    "pib_gasto":     parser_pib_gasto,
    # ---------- Tasas de interés ----------
    "ti_intb":       parser_ti_intb,
    "ti_activa":     parser_ti_activa,
    "ti_pasiva":     parser_ti_pasiva,
    # ---------- Crédito por destino ----------
    "credito_sect":  parser_credito_sect,
    # ---------- Agregados monetarios ----------
    "agregados":     parser_agregados,
}


# Slugs registrados en BCRD_FILES pero **sin parser activo** todavía
# (por layout multi-variable o transpuesto, requieren mapeo dedicado).
TODO_PARSERS = {
    "ipc_articulos",
    "pib_origen", "pib_deflactor",
    "pii",
    "trabajo",
    "ind_amo",
    "panorama_bc", "panorama_osd", "credito_spnf",
}
