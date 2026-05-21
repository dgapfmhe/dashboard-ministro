"""EIA Short-Term Energy Outlook (STEO).

El script R descargaba `STEO_m.xlsx` y usaba las hojas `9atab` (precios WTI,
Brent, Henry Hub) y `2tab` (consumo mundial). Aquí replicamos ese flujo.
"""
from __future__ import annotations

from datetime import date
from pathlib import Path

import pandas as pd

from core.config import ensure_output_dir
from core.http_utils import download_to
from core.logging_utils import get_logger

log = get_logger(__name__)


STEO_URL = "https://www.eia.gov/outlooks/steo/xls/STEO_m.xlsx"


def descargar_steo() -> Path:
    dest = ensure_output_dir().parent / "raw" / "eia" / "STEO_m.xlsx"
    return download_to(STEO_URL, dest)


def _parse_fechas_eia(cabecera) -> list[date | None]:
    """Cabeceras EIA: fechas tipo Timestamp o strings 'Jan 2024'."""
    out: list[date | None] = []
    meses = {
        "jan": 1, "feb": 2, "mar": 3, "apr": 4, "may": 5, "jun": 6,
        "jul": 7, "aug": 8, "sep": 9, "oct": 10, "nov": 11, "dec": 12,
    }
    for c in cabecera:
        if isinstance(c, pd.Timestamp):
            out.append(c.date().replace(day=1))
            continue
        if isinstance(c, str):
            parts = c.strip().split()
            if len(parts) == 2 and parts[0][:3].lower() in meses and parts[1].isdigit():
                out.append(date(int(parts[1]), meses[parts[0][:3].lower()], 1))
                continue
        out.append(None)
    return out


def parsear_9atab(path: Path) -> pd.DataFrame:
    """Precios de combustibles proyectados (WTI, Brent, Henry Hub).
    Mapeo simplificado: buscamos filas cuyas etiquetas contengan palabras
    clave y publicamos como variable única.
    """
    try:
        raw = pd.read_excel(path, sheet_name="9atab", header=None, dtype=object)
    except Exception as e:  # noqa: BLE001
        log.warning("STEO 9atab no se pudo leer: %s", e)
        return pd.DataFrame()

    # Localiza fila cabecera buscando un Timestamp o string de mes+año
    header_row = None
    for i in range(20):
        fechas = _parse_fechas_eia(raw.iloc[i].tolist())
        if sum(1 for x in fechas if x) >= 6:
            header_row = i
            break
    if header_row is None:
        return pd.DataFrame()

    fechas = _parse_fechas_eia(raw.iloc[header_row].tolist())
    body = raw.iloc[header_row + 1 :].reset_index(drop=True)

    etiquetas = body.iloc[:, 0].astype(str).str.lower()
    mapeos = [
        ("wti",       "wti_proy"),
        ("brent",     "brent_proy"),
        ("henry hub", "gas_proy"),
    ]

    filas: list[dict] = []
    for kw, var_id in mapeos:
        hits = etiquetas[etiquetas.str.contains(kw, na=False)].index.tolist()
        if not hits:
            continue
        fila = body.iloc[hits[0]]
        for f, v in zip(fechas, fila.iloc[1:]):
            if f is None:
                continue
            val = pd.to_numeric(v, errors="coerce")
            if pd.isna(val):
                continue
            filas.append({"variable_id": var_id, "fecha": f, "valor": float(val),
                          "flag": "proyeccion"})
    return pd.DataFrame(filas)


def parsear_2tab(path: Path) -> pd.DataFrame:
    """Consumo mundial de petróleo proyectado (mb/d)."""
    try:
        raw = pd.read_excel(path, sheet_name="2tab", header=None, dtype=object)
    except Exception as e:  # noqa: BLE001
        log.warning("STEO 2tab no se pudo leer: %s", e)
        return pd.DataFrame()

    header_row = None
    for i in range(20):
        fechas = _parse_fechas_eia(raw.iloc[i].tolist())
        if sum(1 for x in fechas if x) >= 6:
            header_row = i
            break
    if header_row is None:
        return pd.DataFrame()

    fechas = _parse_fechas_eia(raw.iloc[header_row].tolist())
    body = raw.iloc[header_row + 1 :].reset_index(drop=True)

    etiquetas = body.iloc[:, 0].astype(str).str.lower()
    hits = etiquetas[etiquetas.str.contains("total world|world consumption",
                                            na=False, regex=True)].index.tolist()
    if not hits:
        return pd.DataFrame()

    fila = body.iloc[hits[0]]
    filas: list[dict] = []
    for f, v in zip(fechas, fila.iloc[1:]):
        if f is None:
            continue
        val = pd.to_numeric(v, errors="coerce")
        if pd.isna(val):
            continue
        filas.append({
            "variable_id": "consumo_pet_mundial_proy",
            "fecha": f, "valor": float(val), "flag": "proyeccion",
        })
    return pd.DataFrame(filas)


def run_eia() -> pd.DataFrame:
    try:
        path = descargar_steo()
    except Exception as e:  # noqa: BLE001
        log.warning("STEO no descargable: %s", e)
        return pd.DataFrame()

    frames = [parsear_9atab(path), parsear_2tab(path)]
    frames = [f for f in frames if not f.empty]
    if not frames:
        return pd.DataFrame()
    df = pd.concat(frames, ignore_index=True)
    df["fuente_raw"] = path.name
    return df
