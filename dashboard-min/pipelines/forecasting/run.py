"""Pipeline de Forecasting DGAPF (equivalente a `Data_dgapf 2.R`).

Suma al pipeline macro:
  - Proyecciones EIA STEO (M7)
  - Estado de Operaciones Hacienda (M6)
  - SIPEN (M6, opcional)
  - Consultas DGA SQL Server (opcional, solo runner interno)
  - Agregaciones trimestrales (para módulos BoP / PIB)

Ejecutar:
    python -m pipelines.forecasting.run [--dry-run]
"""
from __future__ import annotations

import argparse
import time

import pandas as pd

from core.catalog import PROYECCIONES, filtrar_modulo
from core.config import ensure_output_dir, get_settings
from core.excel_io import escribir_excel_por_frecuencia
from core.logging_utils import get_logger
from core.supabase_io import abrir_ingesta, cerrar_ingesta, upsert_variables, upsert_series

from .eia_steo import run_eia
from .aggregations import largo_a_trimestral

log = get_logger(__name__)
PIPELINE = "forecasting"


def run(dry_run: bool = False) -> pd.DataFrame:
    t0 = time.time()
    out_dir = ensure_output_dir()

    # 1. EIA STEO (proyecciones)
    df_eia = run_eia()

    # 2. Hacienda EO / SIPEN quedan para integración manual cuando tengamos
    #    los URLs exactos de publicación (depende de ruta interna M:/).
    #    Si hay archivos locales pre-descargados, se pueden pasar a
    #    `hacienda_eo.parsear_eo(path)` y concatenar aquí.

    df_largo = df_eia.copy()

    if df_largo.empty:
        log.warning("forecasting sin filas.")
        return df_largo

    # 3. Agregación trimestral derivada (para comparación con PIB)
    df_tri = largo_a_trimestral(df_largo[df_largo["fecha"].notna()])
    if not df_tri.empty:
        df_tri["flag"] = df_largo.get("flag", pd.Series()).reindex(df_tri.index)

    # 4. Excel respaldo (`dataDGAPF2.xlsx`)
    hojas = {}
    if not df_largo.empty:
        hojas["data_mensual"] = (
            df_largo.pivot_table(index="fecha", columns="variable_id",
                                 values="valor", aggfunc="last").sort_index()
        )
    if not df_tri.empty:
        hojas["data_trimestral"] = (
            df_tri.pivot_table(index="fecha", columns="variable_id",
                               values="valor", aggfunc="last").sort_index()
        )
    if hojas:
        escribir_excel_por_frecuencia(out_dir / "dataDGAPF2.xlsx", hojas)

    # 5. Supabase
    if not dry_run and get_settings().supabase_url:
        ingesta_id = abrir_ingesta(PIPELINE)
        try:
            # Sube proyecciones EIA + el subconjunto Fiscal del catálogo
            upsert_variables([*PROYECCIONES, *filtrar_modulo("Fiscal")])
            upsert_series(df_largo, ingesta_id=ingesta_id)
            cerrar_ingesta(ingesta_id, int(time.time() - t0), len(df_largo), "ok")
        except Exception as e:  # noqa: BLE001
            cerrar_ingesta(ingesta_id, int(time.time() - t0), 0, "error", str(e))
            raise

    log.info("✓ forecasting en %.1fs (%d filas)", time.time() - t0, len(df_largo))
    return df_largo


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()
    run(dry_run=args.dry_run)
