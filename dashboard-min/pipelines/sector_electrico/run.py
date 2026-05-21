"""Pipeline Módulo 8 - Sector Eléctrico.

Equivalente a `data1.R`. Pasos:
  1. Scrapea mem.gob.do y descarga el Anexo vigente a `data/raw/sector_electrico/`.
  2. Lee 3 hojas clave: "Variables Relevantes", "EDE's", "Anexo Res Financieros".
  3. Mapea cada fila a un `variable_id` corto del catálogo (`el_*` de
     `core/catalog_r.py`, alineado con las hojas del informe MEM).
  4. Escribe Excel consolidado en `data/excel_output/indicadores_energeticos.xlsx`.
  5. Upsert al catálogo `variables` y a `series_datos` de Supabase.

Ejecutar:
    python -m pipelines.sector_electrico.run [--dry-run]
"""
from __future__ import annotations

import time

import pandas as pd

from core.catalog_r import ELECTRICO
from core.config import ensure_output_dir, get_settings
from core.dates import normalizar_fechas
from core.excel_io import escribir_excel_por_frecuencia
from core.logging_utils import get_logger
from core.supabase_io import abrir_ingesta, cerrar_ingesta, upsert_variables, upsert_series

from .parse_anexo import (
    BloqueSerieTemporal,
    _fila_por_etiqueta,
    _fila_resfin,
    leer_anexo_res_financieros,
    leer_ede,
    leer_variables_relevantes,
)
from .scrape_mem import descargar_anexo

log = get_logger(__name__)


PIPELINE = "sector_electrico"


# ---------------------------------------------------------------------------
# Mapeos fila Excel -> variable_id corto del catálogo (alineados con catalog_r)
# ---------------------------------------------------------------------------
# (etiqueta_en_excel, offset_respecto_a_la_etiqueta, variable_id)

# Hoja "Variables Relevantes" (data1.R l. 130-153)
MAP_VARIABLES_RELEVANTES: list[tuple[str, int, str]] = [
    # Generación por combustible (10 vars)
    ("Total Generación",                          0, "el_gen_total"),
    ("Total Generación",                          1, "el_gen_carbon"),
    ("Total Generación",                          2, "el_gen_gas_nat"),
    ("Total Generación",                          3, "el_gen_fo2"),
    ("Total Generación",                          4, "el_gen_fo6"),
    ("Total Generación",                          5, "el_gen_fo26"),
    ("Total Generación",                          6, "el_gen_hidro"),
    ("Total Generación",                          7, "el_gen_eolica"),
    ("Total Generación",                          8, "el_gen_solar"),
    ("Total Generación",                          9, "el_gen_biomasa"),
    # Costos
    ("Costos Marginal de Energía (cUSD$/KWh)",    0, "el_cmg_energia"),
    ("Costos Marginal de Potencia  (cUSD/kW-Mes)",0, "el_cmg_potencia"),
    ("Peaje de Transmisión (cUSD/KWh)",           0, "el_peaje_trans"),
    ("Derecho de Conexión Unitario (USD/kW-mes)", 0, "el_der_conex"),
    # Precios combustibles
    ("Fuel Oil # 2 (US$/MMBTU)",                  0, "el_pcomb_fo2"),
    ("Fuel Oil # 6 (US$/MMBTU)",                  0, "el_pcomb_fo6"),
    ("Gas Natural (US$/MMBTU)",                   0, "el_pcomb_gas"),
    ("Gas Natural Conversion (US$/MMBTU)",        0, "el_pcomb_gas_conv"),
    ("Carbón Mineral (US$/MMBTU)",                0, "el_pcomb_carbon"),
    ("Tasa de Cambio  (DOP/USD)",                 0, "el_tc"),
]

# Hoja "EDE's": cada métrica aparece 4 veces (consolidado + 3 EDEs)
# Sufijos del catálogo_r: _tot (consolidado), _edn (EDENORTE), _eds (EDESUR), _ede (EDEESTE)
_EDES = [("tot", 0), ("edn", 1), ("eds", 2), ("ede", 3)]

# (etiqueta_excel, prefijo_var_id)
MAP_EDE_BASE: list[tuple[str, str]] = [
    ("Precio Medio de Venta de Energía (cUSD/kWh)",            "el_pventa"),
    ("Precio Medio de Compra de Energía SPOT (cUSD/kWh)",      "el_pcomp_spot"),
    ("Precio Medio de Compra de Energía CONTRATOS (cUSD/kWh)", "el_pcomp_cont"),
    ("CRI (%)",                                                "el_cri"),
    ("Energía Facturada (GWh)",                                "el_efact"),
    ("Pérdidas (%)",                                           "el_perd"),
    ("Cobranzas (%)",                                          "el_cobr"),
]


def _mapa_ede() -> list[tuple[str, int, str]]:
    """Expande las 7 métricas × 4 ocurrencias (consol + 3 EDEs)."""
    out: list[tuple[str, int, str]] = []
    for etiqueta, prefijo in MAP_EDE_BASE:
        for sufijo, offset in _EDES:
            out.append((etiqueta, offset, f"{prefijo}_{sufijo}"))
    return out


MAP_EDE = _mapa_ede()


# Resultados financieros (anual): (etiqueta, ocurrencia, variable_id)
# 0 = consolidado, 1 = Edenorte, 2 = Edesur, 3 = Edeeste
MAP_RES_FIN: list[tuple[str, int, str]] = [
    ("4. Balance Operacional (1-2)",              0, "el_def_op_tot"),
    ("4. Balance Operacional (1-2)",              1, "el_def_op_edn"),
    ("4. Balance Operacional (1-2)",              2, "el_def_op_eds"),
    ("4. Balance Operacional (1-2)",              3, "el_def_op_ede"),
    ("6. Balance con Inversiones (4-5)",          0, "el_def_capex_tot"),
    ("6. Balance con Inversiones (4-5)",          1, "el_def_capex_edn"),
    ("6. Balance con Inversiones (4-5)",          2, "el_def_capex_eds"),
    ("6. Balance con Inversiones (4-5)",          3, "el_def_capex_ede"),
    ("8.  Balance luego de Financiamiento (7+8)", 0, "el_def_fin_tot"),
    ("8.  Balance luego de Financiamiento (7+8)", 1, "el_def_fin_edn"),
    ("8.  Balance luego de Financiamiento (7+8)", 2, "el_def_fin_eds"),
    ("8.  Balance luego de Financiamiento (7+8)", 3, "el_def_fin_ede"),
]


# ---------------------------------------------------------------------------
# Conversión bloque -> long dataframe
# ---------------------------------------------------------------------------
def _bloque_a_largo(bloque: BloqueSerieTemporal,
                    mapa: list[tuple[str, int, str]]) -> pd.DataFrame:
    filas: list[dict] = []
    for etiqueta, offset, var_id in mapa:
        serie = _fila_por_etiqueta(bloque, etiqueta, offset)
        if serie is None:
            continue
        for fecha, valor in zip(bloque.fechas, serie.values):
            if pd.isna(valor):
                continue
            filas.append({"variable_id": var_id, "fecha": fecha, "valor": float(valor)})
    return pd.DataFrame(filas)


def _resfin_a_largo(etiquetas: pd.Series, matriz: pd.DataFrame,
                    anio_vigente: str) -> pd.DataFrame:
    """El Excel financiero tiene un valor por año por columna (consolidado +
    3 EDEs). Aquí lo representamos como fecha = 1 de enero del año (frecuencia
    'anual' en el catálogo)."""
    filas: list[dict] = []
    try:
        anio_int = int(anio_vigente)
    except ValueError:
        log.error("Año vigente ilegible: %s", anio_vigente)
        return pd.DataFrame()
    fecha_rep = pd.Timestamp(year=anio_int, month=1, day=1).date()

    for etiqueta, ocurrencia, var_id in MAP_RES_FIN:
        serie = _fila_resfin(etiquetas, matriz, etiqueta, ocurrencia)
        if serie is None or serie.empty:
            continue
        valores = serie.dropna()
        if valores.empty:
            continue
        valor = float(valores.iloc[0])
        filas.append({"variable_id": var_id, "fecha": fecha_rep, "valor": valor})
    return pd.DataFrame(filas)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def run(dry_run: bool = False) -> pd.DataFrame:
    """Pipeline completo. Si `dry_run=True` no hace upsert a Supabase."""
    t0 = time.time()
    out_dir = ensure_output_dir()
    # Carpeta local de descarga (reemplaza el path interno de la M: del R)
    raw_dir = out_dir.parent / "raw" / "sector_electrico"
    raw_dir.mkdir(parents=True, exist_ok=True)
    anexo_path = raw_dir / "sector_elec.xlsx"

    # 1. Descargar Anexo desde mem.gob.do a carpeta local
    log.info("Descargando Anexo MEM → %s", anexo_path)
    descargar_anexo(anexo_path)

    # 2. Parseo
    vr = leer_variables_relevantes(anexo_path)
    ede = leer_ede(anexo_path)
    et_fin, mat_fin, anio_vigente = leer_anexo_res_financieros(anexo_path)

    # 3. Mapeo a largo
    df_vr = _bloque_a_largo(vr, MAP_VARIABLES_RELEVANTES)
    df_ede = _bloque_a_largo(ede, MAP_EDE)
    df_fin = _resfin_a_largo(et_fin, mat_fin, anio_vigente)
    df_largo = pd.concat([df_vr, df_ede, df_fin], ignore_index=True)
    df_largo["fuente_raw"] = str(anexo_path.name)

    log.info("Filas largo generadas: %d (VR=%d, EDE=%d, ResFin=%d)",
             len(df_largo), len(df_vr), len(df_ede), len(df_fin))

    # 3.5 Normaliza fechas a inicio de período según frecuencia
    freq_map = {v["id"]: v["frecuencia"] for v in ELECTRICO}
    df_largo = normalizar_fechas(df_largo, freq_map)

    # 4. Excel respaldo (pivot ancho por var_id)
    df_ancho = (
        df_largo.pivot_table(index="fecha", columns="variable_id", values="valor",
                             aggfunc="last")
        .sort_index()
    )
    escribir_excel_por_frecuencia(
        out_dir / "indicadores_energeticos.xlsx",
        {"mensual": df_ancho},
    )

    # 5. Supabase
    if not dry_run and get_settings().supabase_url:
        ingesta_id = abrir_ingesta(PIPELINE)
        try:
            upsert_variables(ELECTRICO)
            upsert_series(df_largo, ingesta_id=ingesta_id)
            cerrar_ingesta(
                ingesta_id,
                duracion_seg=int(time.time() - t0),
                filas_insertadas=len(df_largo),
                estado="ok",
            )
        except Exception as e:  # noqa: BLE001
            cerrar_ingesta(ingesta_id, int(time.time() - t0), 0, "error", str(e))
            raise

    log.info("✓ sector_electrico en %.1fs", time.time() - t0)
    return df_largo


if __name__ == "__main__":
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()
    run(dry_run=args.dry_run)
