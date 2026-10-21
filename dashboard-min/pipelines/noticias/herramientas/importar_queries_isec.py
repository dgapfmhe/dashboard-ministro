"""Importa las 130 queries de la investigación ISEC-RD (isec_queries.py) a
config/categorias.yaml. Se corre UNA vez; después el YAML es la fuente de verdad.

    python -m pipelines.noticias.herramientas.importar_queries_isec \
        --origen C:/Users/patri/codigos/appsenti/isec_queries.py
"""
from __future__ import annotations

import argparse
import importlib.util
import re
import unicodedata
from pathlib import Path

import yaml

# set de la investigación → código de sector usado en el paper
CODIGOS = {
    "General · Resumen Sectorial": ("GEN", "General"),
    "Actividad y Crecimiento": ("ACT", "Actividad y Crecimiento"),
    "Inflacion (drivers IPC)": ("INF", "Inflación"),
    "Politica Monetaria y BCRD": ("PM", "Política Monetaria y BCRD"),
    "Tipo de Cambio": ("TC", "Tipo de Cambio"),
    "Remesas": ("REM", "Remesas"),
    "Sector Externo y Comercio": ("EXT", "Sector Externo y Comercio"),
    "Finanzas Publicas y Fiscal": ("FISC", "Finanzas Públicas y Fiscal"),
    "Expectativas y Confianza": ("EXP", "Expectativas y Confianza"),
    "Turismo": ("TUR", "Turismo"),
    "Construccion": ("CONS", "Construcción"),
    "Agropecuario": ("AGRO", "Agropecuario"),
    "Industria/Manufactura": ("MANU", "Industria y Manufactura"),
    "Zonas Francas": ("ZF", "Zonas Francas"),
    "Comercio y MIPYMES": ("COM", "Comercio y MIPYMES"),
    "Energia y Electricidad": ("ENER", "Energía y Electricidad"),
    "Transporte": ("TRANS", "Transporte"),
    "Sector Financiero / Banca": ("FIN", "Sector Financiero y Banca"),
    "Inmobiliario y Vivienda": ("INMO", "Inmobiliario y Vivienda"),
}


def slug(s: str) -> str:
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


class _Str(str):
    """Fuerza comillas simples en el YAML (las queries llevan comillas dobles)."""


def _repr_str(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", str(data), style="'")


yaml.add_representer(_Str, _repr_str)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--origen", required=True)
    ap.add_argument("--salida", default=str(Path(__file__).resolve().parents[1] / "config" / "categorias.yaml"))
    a = ap.parse_args()

    spec = importlib.util.spec_from_file_location("isec_queries", a.origen)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    sectores = []
    for set_name, cats in mod.DEFAULT_QUERY_SETS.items():
        cod, nombre = CODIGOS[set_name]
        subs = []
        for cat, queries in cats.items():
            subs.append({
                "id": f"{cod}.{slug(cat)}",
                "nombre": cat,
                "queries": [_Str(q) for q in queries],
            })
        sectores.append({
            "id": cod,
            "nombre": nombre,
            "nombre_investigacion": set_name,
            "origen": "investigacion",
            "congelada": True,
            "activa_desde": "2016-01-01",
            "subcategorias": subs,
        })

    doc = {
        "version": 1,
        "notas": (
            "Fuente de verdad de las categorías. Las de origen 'investigacion' están "
            "congeladas (no editar sus queries: rompen la comparabilidad del ISEC). "
            "Para agregar una categoría nueva usa el formulario de issue "
            "'Nueva categoría de noticias' o agrega un bloque con origen: usuario."
        ),
        "sectores": sectores,
    }
    Path(a.salida).parent.mkdir(parents=True, exist_ok=True)
    with open(a.salida, "w", encoding="utf-8") as f:
        yaml.dump(doc, f, allow_unicode=True, sort_keys=False, width=4000)
    n = sum(len(s["subcategorias"]) for s in sectores)
    print(f"OK {len(sectores)} sectores, {n} subcategorías → {a.salida}")


if __name__ == "__main__":
    main()
