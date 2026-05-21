"""Descargas del Banco Central de la República Dominicana (BCRD).

URLs **verificadas contra `Data_dgapf 2.R`** del equipo DGAPF (abril 2026).

Cada función devuelve un Path al archivo crudo. El parseo a formato largo
(`variable_id, fecha, valor`) lo hacen los módulos en
`pipelines/macro_bcrd/parsers_bcrd.py`.

Estructura de URL real del BCRD:

    https://cdn.bancentral.gov.do/documents/<seccion>/<sub>/documents/<archivo>

donde `<seccion>` puede ser `estadisticas`, `entorno-internacional`,
`politica-monetaria`, etc. — por eso la base es solo `…/documents`, no
`…/documents/estadisticas`.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from .config import ensure_output_dir
from .http_utils import download_to
from .logging_utils import get_logger

log = get_logger(__name__)


# Raíz del CDN — todas las URLs cuelgan de aquí
BCRD_BASE = "https://cdn.bancentral.gov.do/documents"


@dataclass(frozen=True)
class BcrdFile:
    slug: str           # identificador interno
    remote_path: str    # ruta después de BCRD_BASE/, **incluye** la extensión
    categoria: str      # tag descriptivo: 'precios','sector-real',...

    @property
    def extension(self) -> str:
        return Path(self.remote_path).suffix  # '.xls' | '.xlsx'


# ============================================================================
# Catálogo de archivos BCRD descargables
# ----------------------------------------------------------------------------
# Confirmados línea por línea contra Data_dgapf 2.R. Si alguno cambia, el
# pipeline registra warning y sigue (no es fatal por archivo individual).
# ============================================================================
BCRD_FILES: dict[str, BcrdFile] = {
    # ------------------- Precios (4) -------------------
    "ipc":            BcrdFile("ipc",            "estadisticas/precios/documents/ipc_base_2019-2020.xls",                            "precios"),
    "ipc_sub":        BcrdFile("ipc_sub",        "estadisticas/precios/documents/ipc_subyacente_base_2019-2020.xlsx",                "precios"),
    "ipc_tnt":        BcrdFile("ipc_tnt",        "estadisticas/precios/documents/ipc_tnt_base_2019-2020.xls",                        "precios"),
    "ipc_articulos":  BcrdFile("ipc_articulos",  "estadisticas/precios/documents/ipc_articulos_base_2019-2020.xlsx",                 "precios"),
    "ipc_grupos":     BcrdFile("ipc_grupos",     "estadisticas/precios/documents/ipc_grupos_base_2019-2020.xls",                     "precios"),

    # ------------------- Sector real (3) -------------------
    "imae":           BcrdFile("imae",           "estadisticas/sector-real/documents/imae_2018.xlsx",                                "sector-real"),
    "pib_gasto":      BcrdFile("pib_gasto",      "estadisticas/sector-real/documents/pib_gasto_retro_2018.xlsx",                     "sector-real"),
    "pib_origen":     BcrdFile("pib_origen",     "estadisticas/sector-real/documents/pib_origen_retro_2018.xlsx",                    "sector-real"),
    "pib_deflactor":  BcrdFile("pib_deflactor",  "estadisticas/sector-real/documents/pib_deflactor_2018.xlsx",                       "sector-real"),

    # ------------------- Sector externo (5) -------------------
    "rin":            BcrdFile("rin",            "estadisticas/sector-externo/documents/reservas_internacionales.xlsx",              "sector-externo"),
    "rem_fam":        BcrdFile("rem_fam",        "estadisticas/sector-externo/documents/Remesas_6.xlsx",                             "sector-externo"),
    "imp_petroleo":   BcrdFile("imp_petroleo",   "estadisticas/sector-externo/documents/Importaciones_Crudo_6.xls",                  "sector-externo"),
    "balanza_pagos":  BcrdFile("balanza_pagos",  "estadisticas/sector-externo/documents/bpagos__trim_6.xls",                         "sector-externo"),
    "pii":            BcrdFile("pii",            "estadisticas/sector-externo/documents/piitrim_6.xlsx",                             "sector-externo"),

    # ------------------- Sector turismo (1) -------------------
    "llegada_tur":    BcrdFile("llegada_tur",    "estadisticas/sector-turismo/documents/lleg_total.xls",                             "sector-turismo"),

    # ------------------- Mercado de trabajo (1) -------------------
    "trabajo":        BcrdFile("trabajo",        "estadisticas/mercado-de-trabajo/documents/3_1_Deciles_Rama.xlsx",                  "mercado-trabajo"),

    # ------------------- Mercado cambiario (3) -------------------
    "tcn_dia":        BcrdFile("tcn_dia",        "estadisticas/mercado-cambiario/documents/TASA_DOLAR_REFERENCIA_MC.xlsx",           "mercado-cambiario"),
    "tc_ent_fin":     BcrdFile("tc_ent_fin",     "estadisticas/mercado-cambiario/documents/TASA_ENTIDADES_FINANCIERAS.xls",          "mercado-cambiario"),
    "compra_dolar":   BcrdFile("compra_dolar",   "estadisticas/mercado-cambiario/documents/Operaciones_us.xls",                      "mercado-cambiario"),

    # ------------------- Sector monetario y financiero (12) -------------------
    "tpm":            BcrdFile("tpm",            "estadisticas/sector-monetario-y-financiero/documents/Serie_TPM.xlsx",              "monetarias"),
    "op_mon":         BcrdFile("op_mon",         "estadisticas/sector-monetario-y-financiero/documents/operaciones_monetarias.xlsx", "monetarias"),
    "base_mon":       BcrdFile("base_mon",       "estadisticas/sector-monetario-y-financiero/documents/base_monetaria.xlsx",         "monetarias"),
    "agregados":      BcrdFile("agregados",      "estadisticas/sector-monetario-y-financiero/documents/agregados_monetarios.xlsx",   "monetarias"),
    "encaje":         BcrdFile("encaje",         "estadisticas/sector-monetario-y-financiero/documents/encaje_bancario.xlsx",        "monetarias"),
    "credito_sect":   BcrdFile("credito_sect",   "estadisticas/sector-monetario-y-financiero/documents/serie_prestamos_por_destino_armonizados.xlsx", "monetarias"),
    "credito_osd":    BcrdFile("credito_osd",    "estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_osd.xlsx",  "monetarias"),
    "ind_amo":        BcrdFile("ind_amo",        "estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_bcrd.xlsx", "monetarias"),
    "ti_activa":      BcrdFile("ti_activa",      "estadisticas/sector-monetario-y-financiero/documents/tbm_activad.xlsx",            "monetarias"),
    "ti_pasiva":      BcrdFile("ti_pasiva",      "estadisticas/sector-monetario-y-financiero/documents/tbm_pasivad.xlsx",            "monetarias"),
    "ti_intb":        BcrdFile("ti_intb",        "estadisticas/sector-monetario-y-financiero/documents/operaciones_interb.xls",      "monetarias"),
    "panorama_bc":    BcrdFile("panorama_bc",    "estadisticas/sector-monetario-y-financiero/documents/panorama_pbc.xlsx",           "monetarias"),
    "panorama_osd":   BcrdFile("panorama_osd",   "estadisticas/sector-monetario-y-financiero/documents/panorama_posd.xlsx",          "monetarias"),
    "credito_spnf":   BcrdFile("credito_spnf",   "estadisticas/sector-monetario-y-financiero/documents/credito_nofinanciero_bc.xlsx","monetarias"),

    # ------------------- Encuestas / Política monetaria (1) -------------------
    "expE":           BcrdFile("expE",           "politica-monetaria/expectativas-macroeconomicas/documents/Historico-EOE-(Mensual).xlsx", "encuestas"),

    # ------------------- Entorno internacional (1) -------------------
    "embi":           BcrdFile("embi",           "entorno-internacional/documents/Serie_Historica_Spread_del_EMBI.xlsx",             "entorno-internacional"),
}


# Slugs no descargados directamente del BCRD (conviven en el catálogo
# pero vienen del MH / DGA / FRED / etc.). Se ponen aquí solo para que
# el lector vea el universo completo.
NO_BCRD = {"eo_hacienda", "salario_sipen", "cot_sipen", "exp_dga", "imp_dga"}


def descargar_archivo_bcrd(slug: str, dest_dir: Path | None = None) -> Path:
    """Descarga un archivo específico del BCRD, preservando la extensión."""
    if slug not in BCRD_FILES:
        raise KeyError(f"Slug BCRD desconocido: {slug}")
    meta = BCRD_FILES[slug]
    dest_dir = dest_dir or ensure_output_dir().parent / "raw" / "bcrd"
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / f"{meta.slug}{meta.extension}"
    url = f"{BCRD_BASE}/{meta.remote_path}"
    return download_to(url, dest)


def descargar_todos_bcrd(dest_dir: Path | None = None) -> dict[str, Path]:
    """Descarga todos los archivos registrados. Retorna mapa slug -> Path.

    Cada falla se loguea como warning pero no aborta el resto.
    """
    out: dict[str, Path] = {}
    for slug in BCRD_FILES:
        try:
            out[slug] = descargar_archivo_bcrd(slug, dest_dir)
        except Exception as e:  # noqa: BLE001
            log.warning("Falló descarga BCRD %s: %s", slug, e)
    return out
