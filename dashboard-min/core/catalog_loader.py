"""Carga el catálogo de variables desde Excel y lo fusiona con el catálogo estático.

Permite al equipo agregar variables editando las hojas
``metadata_data_mensual`` / ``metadata_data_trimestral`` (y opcionalmente
``metadata_data_diaria`` / ``metadata_data_anual``) del libro
``dataDGAPF.xlsx``, sin tocar Python.

Reglas de fusión
----------------
* El catálogo Python (``core.catalog``) es la fuente de verdad para variables
  **derivadas** (``tipo='derivada'`` con ``formula``) y para metadatos finos
  (frecuencia diaria, electricidad, etc.).
* El Excel agrega variables **directas** nuevas: cualquier ``indicador`` que
  no exista ya en el catálogo Python se inyecta tal cual.
* Para IDs ya existentes, Python gana (conserva ``tipo``/``formula``), pero
  ``descripcion`` se completa desde el Excel si Python la tenía vacía.

Uso
---
>>> from core.catalog_loader import cargar_catalogo_completo
>>> vars_ = cargar_catalogo_completo("data/dataDGAPF.xlsx")
>>> # ahora vars_ contiene Python + extras de Excel
"""
from __future__ import annotations

import logging
from pathlib import Path
from typing import Iterable

import pandas as pd

from core import catalog as _catalog_static

log = logging.getLogger(__name__)


# Identificadores que NO son variables (columnas de fecha en las hojas data_*)
NON_VARIABLE_IDS = {"periodo", "trimestre", "mes", "anio", "fecha", "year", "date"}

# Hojas de metadata reconocidas → frecuencia
HOJAS_METADATA = {
    "metadata_data_diaria": "diaria",
    "metadata_data_mensual": "mensual",
    "metadata_data_trimestral": "trimestral",
    "metadata_data_anual": "anual",
}

# Normalización de nombres de Sector (Excel) → modulo (catálogo Python)
SECTOR_ALIAS = {
    "cambiario": "Mercado Cambiario",
    "mercado cambiario": "Mercado Cambiario",
    "real": "Real",
    "precios": "Precios",
    "externo": "Externo",
    "fiscal": "Fiscal",
    "monetario": "Monetario",
    "financiero": "Financiero",
    "electrico": "Eléctrico",
    "eléctrico": "Eléctrico",
}


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def _strip(x):
    """Quita espacios y devuelve None si quedó vacío."""
    if x is None:
        return None
    s = str(x).strip()
    return s or None


def _normalizar_id(raw: str | None) -> str | None:
    """ID en minúsculas, sin espacios, lista para usar como `variable_id`."""
    if raw is None:
        return None
    s = str(raw).strip().lower()
    return s or None


def _normalizar_modulo(sector: str | None) -> str | None:
    if sector is None:
        return None
    key = sector.strip().lower()
    return SECTOR_ALIAS.get(key, sector.strip())


def _normalizar_escala(escala: str | None) -> str:
    """Pasa a forma canónica: Unidad / Miles / Millones."""
    if escala is None:
        return "Unidad"
    e = escala.strip().lower()
    if e in {"unidad", "unidades", ""}:
        return "Unidad"
    if e.startswith("mil"):
        # "Miles", "miles de RD$"
        return "Miles" if e == "miles" else escala.strip().title()
    if e.startswith("millon") or e.startswith("millón"):
        return "Millones" if e in {"millones", "millón"} else escala.strip().title()
    return escala.strip()


# ---------------------------------------------------------------------------
# lectura de hojas metadata_*
# ---------------------------------------------------------------------------

def _leer_hoja_metadata(path: Path, hoja: str, frecuencia: str) -> list[dict]:
    """Lee una hoja `metadata_data_*` y devuelve una lista de dicts en el formato del catálogo."""
    try:
        df = pd.read_excel(path, sheet_name=hoja)
    except (ValueError, KeyError):
        log.debug("Hoja %s no encontrada en %s", hoja, path)
        return []

    columnas_req = {"Sector", "Nombre", "Fuente", "Unidad.de.Cuenta", "Escala", "indicador"}
    faltan = columnas_req - set(df.columns)
    if faltan:
        log.warning("Hoja %s sin columnas %s — se ignora", hoja, faltan)
        return []

    salida: list[dict] = []
    for _, row in df.iterrows():
        ind = _normalizar_id(row.get("indicador"))
        if not ind or ind in NON_VARIABLE_IDS:
            continue

        nombre = _strip(row.get("Nombre")) or ind
        salida.append(
            {
                "id": ind,
                "nombre": nombre,
                "modulo": _normalizar_modulo(_strip(row.get("Sector"))) or "Otros",
                "submodulo": None,
                "frecuencia": frecuencia,
                "unidad": _strip(row.get("Unidad.de.Cuenta")) or "índice",
                "fuente": _strip(row.get("Fuente")) or "n/d",
                "escala": _normalizar_escala(_strip(row.get("Escala"))),
                "tipo": "directa",
                "formula": None,
                "descripcion": _strip(row.get("Descripción")) if "Descripción" in df.columns else None,
                "activo": True,
            }
        )
    return salida


def cargar_metadata_excel(path: str | Path) -> list[dict]:
    """Lee TODAS las hojas ``metadata_data_*`` que existan en el libro."""
    p = Path(path)
    if not p.exists():
        log.warning("Excel %s no existe — no se cargará metadata", p)
        return []

    todas: list[dict] = []
    for hoja, freq in HOJAS_METADATA.items():
        todas.extend(_leer_hoja_metadata(p, hoja, freq))
    log.info("Catálogo Excel (%s): %d variables", p.name, len(todas))
    return todas


# ---------------------------------------------------------------------------
# fusión Python + Excel
# ---------------------------------------------------------------------------

def fusionar(estaticas: Iterable[dict], excel: Iterable[dict]) -> list[dict]:
    """Devuelve una sola lista de variables.

    * Para IDs en común: gana Python pero copia ``descripcion`` desde Excel
      si Python la tenía vacía.
    * Para IDs que solo están en Excel: se inyectan tal cual.
    """
    estaticas = list(estaticas)
    excel = list(excel)

    por_id: dict[str, dict] = {v["id"]: dict(v) for v in estaticas}
    nuevos = 0
    enriquecidos = 0

    for v in excel:
        vid = v["id"]
        if vid in por_id:
            actual = por_id[vid]
            if not actual.get("descripcion") and v.get("descripcion"):
                actual["descripcion"] = v["descripcion"]
                enriquecidos += 1
            # también completa unidad/fuente si Python las dejó por defecto
            if actual.get("unidad") in (None, "índice", "n/d") and v.get("unidad"):
                actual["unidad"] = v["unidad"]
            if actual.get("fuente") in (None, "n/d") and v.get("fuente"):
                actual["fuente"] = v["fuente"]
        else:
            por_id[vid] = dict(v)
            nuevos += 1

    log.info("Fusión catálogo: %d en Python · +%d nuevas de Excel · %d enriquecidas",
             len(estaticas), nuevos, enriquecidos)
    return list(por_id.values())


def cargar_catalogo_completo(excel_path: str | Path | None = None) -> list[dict]:
    """Catálogo final = catálogo Python ∪ extras de Excel.

    Si ``excel_path`` es None o el archivo no existe, devuelve solo el
    catálogo Python. Esto hace que el sistema sea válido sin Excel.
    """
    estaticas = _catalog_static.todas_variables()
    if excel_path is None:
        return estaticas
    extras = cargar_metadata_excel(excel_path)
    return fusionar(estaticas, extras)


# ---------------------------------------------------------------------------
# helpers de filtrado (proxy para no tener que importar también catalog)
# ---------------------------------------------------------------------------

def filtrar_directas(vars_: list[dict]) -> list[dict]:
    return [v for v in vars_ if v.get("tipo", "directa") == "directa"]


def filtrar_derivadas(vars_: list[dict]) -> list[dict]:
    return [v for v in vars_ if v.get("tipo") == "derivada"]


def filtrar_modulo(vars_: list[dict], modulo: str) -> list[dict]:
    return [v for v in vars_ if v.get("modulo") == modulo]


def por_id(vars_: list[dict], id_: str) -> dict | None:
    for v in vars_:
        if v["id"] == id_:
            return v
    return None
