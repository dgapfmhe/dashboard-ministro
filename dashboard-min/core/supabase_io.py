"""Cliente Supabase + helpers para upsert masivo en formato largo.

Uso típico:

    from core.supabase_io import upsert_series, upsert_variables

    upsert_variables([
        {"id": "ipc_rd", "nombre": "IPC General", "modulo": "Precios",
         "frecuencia": "mensual", "unidad": "Índice", "fuente": "BCRD",
         "escala": "Unidad", "tipo": "directa"}
    ])

    upsert_series(df_largo)  # columnas: variable_id, fecha, valor, flag, fuente_raw
"""
from __future__ import annotations

from typing import Iterable, Sequence

import pandas as pd
from supabase import Client, create_client

from .config import get_settings
from .logging_utils import get_logger

log = get_logger(__name__)

_BATCH = 500


def _client() -> Client:
    s = get_settings()
    if not s.supabase_url or not s.supabase_service_key:
        raise RuntimeError(
            "Faltan SUPABASE_URL / SUPABASE_SERVICE_KEY. "
            "Configura .env o GitHub Secrets."
        )
    return create_client(s.supabase_url, s.supabase_service_key)


# ---------------------------------------------------------------------------
# Catálogo
# ---------------------------------------------------------------------------
def upsert_variables(rows: Sequence[dict]) -> int:
    """Upsert idempotente al catálogo `variables`."""
    if not rows:
        return 0
    client = _client()
    inserted = 0
    for i in range(0, len(rows), _BATCH):
        chunk = rows[i : i + _BATCH]
        client.table("variables").upsert(list(chunk), on_conflict="id").execute()
        inserted += len(chunk)
    log.info("variables upsert: %d filas", inserted)
    return inserted


# ---------------------------------------------------------------------------
# Series (hechos)
# ---------------------------------------------------------------------------
REQUIRED_COLS = ("variable_id", "fecha", "valor")


def upsert_series(df: pd.DataFrame, ingesta_id: int | None = None) -> int:
    """Upsert de `series_datos`. Espera DataFrame largo con columnas mínimas
    `variable_id`, `fecha`, `valor`. Opcional: `flag`, `fuente_raw`.
    """
    if df.empty:
        return 0
    missing = [c for c in REQUIRED_COLS if c not in df.columns]
    if missing:
        raise ValueError(f"Faltan columnas obligatorias en df: {missing}")

    import math
    df = df.copy()
    df["fecha"] = pd.to_datetime(df["fecha"]).dt.strftime("%Y-%m-%d")
    # Convert NaN/inf/-inf to None — JSON doesn't support these float sentinels
    def _clean_float(v):
        try:
            f = float(v)
            return None if (math.isnan(f) or math.isinf(f)) else f
        except (TypeError, ValueError):
            return None
    df["valor"] = df["valor"].apply(_clean_float)
    for c in ("flag", "fuente_raw"):
        if c not in df.columns:
            df[c] = None
        else:
            # Replace pandas NaN in string columns with None
            df[c] = df[c].where(df[c].notna(), None)
    if ingesta_id is not None:
        df["ingesta_id"] = ingesta_id

    # Deduplicate: keep last value per (variable_id, fecha) to avoid PK conflicts in same batch
    df = df.sort_values(["variable_id", "fecha"]).drop_duplicates(
        subset=["variable_id", "fecha"], keep="last"
    )

    client = _client()
    # Use JSON round-trip to eliminate NaN/inf — pandas to_json replaces them with null
    import json
    records = json.loads(df.to_json(orient="records", date_format="iso", default_handler=str))
    inserted = 0
    for i in range(0, len(records), _BATCH):
        chunk = records[i : i + _BATCH]
        client.table("series_datos").upsert(
            chunk, on_conflict="variable_id,fecha"
        ).execute()
        inserted += len(chunk)
    log.info("series_datos upsert: %d filas", inserted)
    return inserted


# ---------------------------------------------------------------------------
# Bitácora de ingestas
# ---------------------------------------------------------------------------
def abrir_ingesta(pipeline: str) -> int:
    client = _client()
    res = client.table("ingestas").insert(
        {"pipeline": pipeline, "estado": "ok"}
    ).execute()
    if not res.data:
        raise RuntimeError(
            f"No se pudo crear fila en `ingestas` para pipeline={pipeline}. "
            "Verifica grants/RLS y que SUPABASE_SERVICE_KEY tenga permiso INSERT."
        )
    return res.data[0]["id"]


def cerrar_ingesta(
    ingesta_id: int,
    duracion_seg: int,
    filas_insertadas: int,
    estado: str = "ok",
    mensaje: str | None = None,
    run_url: str | None = None,
) -> None:
    client = _client()
    client.table("ingestas").update(
        {
            "duracion_seg": duracion_seg,
            "filas_insertadas": filas_insertadas,
            "estado": estado,
            "mensaje": mensaje,
            "run_url": run_url,
        }
    ).eq("id", ingesta_id).execute()
