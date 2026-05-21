"""Pipeline macro BCRD (equivalente a `gestion_datos22.R`).

Descarga los archivos BCRD registrados, los parsea al formato largo,
suma las series externas (Yahoo, FRED, World Bank), calcula variables
**derivadas** (ej: ``ipc_yoy``, ``balanza_com``) y escribe:

  - Excel consolidado ``variables_dashboard.xlsx`` con hojas
    ``variables_diarias``, ``variables_mensuales``, ``variables_anuales``.
  - Upserts a Supabase (``variables`` y ``series_datos``).

Ejecutar:
    python -m pipelines.macro_bcrd.run [--dry-run] [--solo-bcrd]
"""
from __future__ import annotations

import argparse
import time
from pathlib import Path

import pandas as pd

from core.bcrd import descargar_todos_bcrd
from core.catalog import filtrar_directas, filtrar_derivadas, todas_variables
from core.catalog_loader import cargar_catalogo_completo
from core.config import ensure_output_dir, get_settings
from core.dates import normalizar_fechas
from core.derived import calcular_derivadas, derivadas_a_largo, serie_larga_a_pivot
from core.excel_io import escribir_excel_por_frecuencia
from core.logging_utils import get_logger
from core.supabase_io import abrir_ingesta, cerrar_ingesta, upsert_variables, upsert_series

from .parsers_bcrd import PARSER_REGISTRY
from .scrapers_externos import descargar_fred, descargar_mercados, descargar_worldbank_cmo

log = get_logger(__name__)
PIPELINE = "macro_bcrd"

# Excel del equipo del que se enriquece el catálogo (opcional)
EXCEL_METADATA_DEFECTO = Path("data/dataDGAPF.xlsx")


# ---------------------------------------------------------------------------
# Etapas
# ---------------------------------------------------------------------------
def etapa_bcrd() -> pd.DataFrame:
    log.info("— Etapa BCRD —")
    paths = descargar_todos_bcrd()
    frames: list[pd.DataFrame] = []
    for slug, path in paths.items():
        parser = PARSER_REGISTRY.get(slug)
        if not parser:
            log.info("sin parser para %s (se descarga, no se inserta)", slug)
            continue
        try:
            df = parser(path)
            if df.empty:
                log.warning("Parser %s devolvió DataFrame vacío", slug)
                continue
            df["fuente_raw"] = path.name
            frames.append(df)
            log.info("%s → %d filas", slug, len(df))
        except Exception as e:  # noqa: BLE001
            log.warning("Parser %s falló: %s", slug, e)
    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


def etapa_externos() -> pd.DataFrame:
    log.info("— Etapa FRED/Yahoo/WB —")
    s = get_settings()
    frames = [
        descargar_mercados(),
        descargar_fred(s.fred_api_key),
        descargar_worldbank_cmo(),
    ]
    frames = [f for f in frames if not f.empty]
    return pd.concat(frames, ignore_index=True) if frames else pd.DataFrame()


def etapa_derivadas(df_directas: pd.DataFrame, derivadas: list[dict]) -> pd.DataFrame:
    """Calcula las variables derivadas a partir de las directas ya cargadas."""
    if df_directas.empty or not derivadas:
        return pd.DataFrame()
    log.info("— Etapa derivadas (%d fórmulas) —", len(derivadas))
    series = serie_larga_a_pivot(df_directas[["variable_id", "fecha", "valor"]])
    resultados = calcular_derivadas(derivadas, series, fail_silently=True)
    df_largo = derivadas_a_largo(resultados, flag="derivada")
    log.info("  → %d filas derivadas (%d series)", len(df_largo), len(resultados))
    return df_largo


# ---------------------------------------------------------------------------
# Excel respaldo
# ---------------------------------------------------------------------------
def construir_hojas_excel(df_largo: pd.DataFrame) -> dict[str, pd.DataFrame]:
    """Genera 3 hojas respetando el layout del `variables_dashboard.xlsx` del
    equipo DGAPF. Usa el catálogo para saber la frecuencia de cada var_id."""
    freq_map = {v["id"]: v["frecuencia"] for v in todas_variables()}

    df = df_largo.copy()
    # Normaliza tipos: distintos parsers devuelven date / Timestamp / str.
    df["fecha"] = pd.to_datetime(df["fecha"], errors="coerce")
    df = df.dropna(subset=["fecha"])
    df["frecuencia"] = df["variable_id"].map(freq_map).fillna("mensual")

    hojas: dict[str, pd.DataFrame] = {}
    for freq_excel, freq_tag in [
        ("variables_diarias", "diaria"),
        ("variables_mensuales", "mensual"),
        ("variables_anuales", "anual"),
    ]:
        sub = df[df["frecuencia"] == freq_tag]
        if sub.empty:
            continue
        ancho = sub.pivot_table(index="fecha", columns="variable_id",
                                values="valor", aggfunc="last").sort_index()
        hojas[freq_excel] = ancho
    return hojas


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def run(
    dry_run: bool = False,
    solo_bcrd: bool = False,
    excel_metadata: Path | None = EXCEL_METADATA_DEFECTO,
) -> pd.DataFrame:
    t0 = time.time()
    out_dir = ensure_output_dir()

    # 0. Catálogo (estático Python ∪ extras del Excel del equipo)
    excel_arg = excel_metadata if (excel_metadata and excel_metadata.exists()) else None
    catalogo = cargar_catalogo_completo(excel_arg)
    log.info("Catálogo: %d variables (%d directas, %d derivadas)",
             len(catalogo), len(filtrar_directas(catalogo)),
             len(filtrar_derivadas(catalogo)))

    # 1. Datos directos
    frames = [etapa_bcrd()]
    if not solo_bcrd:
        frames.append(etapa_externos())
    df_directas = pd.concat([f for f in frames if not f.empty], ignore_index=True) \
        if any(not f.empty for f in frames) else pd.DataFrame()

    if df_directas.empty:
        log.warning("Pipeline macro_bcrd sin filas directas.")
        return df_directas

    # 2. Variables derivadas
    df_derivadas = etapa_derivadas(df_directas, filtrar_derivadas(catalogo))
    df_largo = pd.concat([df_directas, df_derivadas], ignore_index=True)

    # 2.5 Normaliza fechas: snap mensual a 1er día + descarta proyecciones futuras
    freq_map = {v["id"]: v["frecuencia"] for v in catalogo}
    df_largo = normalizar_fechas(df_largo, freq_map)

    # 3. Excel respaldo
    hojas = construir_hojas_excel(df_largo)
    if hojas:
        escribir_excel_por_frecuencia(out_dir / "variables_dashboard.xlsx", hojas)

    # 4. Supabase
    if not dry_run and get_settings().supabase_url:
        ingesta_id = abrir_ingesta(PIPELINE)
        try:
            upsert_variables(catalogo)
            upsert_series(df_largo, ingesta_id=ingesta_id)
            cerrar_ingesta(ingesta_id, int(time.time() - t0), len(df_largo), "ok")
        except Exception as e:  # noqa: BLE001
            cerrar_ingesta(ingesta_id, int(time.time() - t0), 0, "error", str(e))
            raise

    log.info("✓ macro_bcrd en %.1fs (%d filas, %d directas + %d derivadas)",
             time.time() - t0, len(df_largo), len(df_directas), len(df_derivadas))
    return df_largo


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--solo-bcrd", action="store_true",
                   help="Omite fuentes externas (FRED/Yahoo/WB)")
    p.add_argument("--excel-metadata", type=Path, default=EXCEL_METADATA_DEFECTO,
                   help="Excel del equipo con hojas metadata_data_*")
    args = p.parse_args()
    run(dry_run=args.dry_run, solo_bcrd=args.solo_bcrd,
        excel_metadata=args.excel_metadata)
