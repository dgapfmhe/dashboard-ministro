"""Agrega una categoría a config/categorias.yaml desde el cuerpo de un issue-form.

    ISSUE_BODY="..." python -m pipelines.noticias.herramientas.agregar_categoria
Escribe en $GITHUB_OUTPUT: id=<id>  (o falla con mensaje legible).
"""
from __future__ import annotations

import os
import re
import sys
from datetime import date
from pathlib import Path

import yaml

from ..config import DIR_CONFIG, Config
from .importar_queries_isec import _Str, slug  # noqa: F401  (registra el representer)


def campos(body: str) -> dict[str, str]:
    out, actual = {}, None
    for linea in body.splitlines():
        m = re.match(r"^###\s+(.*)$", linea.strip())
        if m:
            actual = m.group(1).strip(); out[actual] = ""
        elif actual:
            out[actual] += linea + "\n"
    return {k: v.strip() for k, v in out.items() if v.strip() and v.strip() != "_No response_"}


def main() -> int:
    f = campos(os.environ["ISSUE_BODY"])
    codigo = re.sub(r"[^A-Z0-9_]", "", f.get("Código", "").upper())
    nombre = f.get("Nombre", "").strip()
    ubic = f.get("Ubicación", "Sector nuevo")
    queries = [q.strip() for q in f.get("Búsquedas (una por línea)", "").splitlines() if q.strip()]
    palabras = [p.strip() for p in f.get("Palabras clave (opcional, una por línea)", "").splitlines() if p.strip()]
    backfill = int(f.get("Backfill hacia atrás", "0") or 0)
    if not codigo or not nombre or not queries:
        raise SystemExit("Faltan código, nombre o búsquedas.")

    ruta = DIR_CONFIG / "categorias.yaml"
    doc = yaml.safe_load(ruta.read_text("utf-8"))
    hoy = date.today().isoformat()
    ids = {s["id"] for s in doc["sectores"]} | {c["id"] for s in doc["sectores"] for c in s.get("subcategorias") or []}

    sub = {"id": None, "nombre": nombre, "queries": [_Str(q) for q in queries],
           "activa_desde": hoy}
    if palabras:
        sub["palabras_clave"] = palabras
    if ubic == "Sector nuevo":
        if codigo in ids:
            raise SystemExit(f"Ya existe una categoría con id {codigo}.")
        sub["id"] = f"{codigo}.principal"
        doc["sectores"].append({
            "id": codigo, "nombre": nombre, "origen": "usuario", "congelada": False,
            "activa_desde": hoy, "backfill_dias": backfill, "subcategorias": [sub]})
        nuevo = codigo
    else:
        sector = next((s for s in doc["sectores"] if s["id"] == ubic), None)
        if sector is None:
            raise SystemExit(f"Sector {ubic} no existe.")
        sub["id"] = f"{ubic}.{slug(codigo)}"
        if sub["id"] in ids:
            raise SystemExit(f"Ya existe {sub['id']}.")
        sub["origen"] = "usuario"
        sub["backfill_dias"] = backfill
        sector.setdefault("subcategorias", []).append(sub)
        nuevo = sub["id"]

    # backfill a nivel de subcategoría (Config lo hereda del sector si no está)
    ruta.write_text(yaml.dump(doc, allow_unicode=True, sort_keys=False, width=4000), "utf-8")
    Config()   # valida que el YAML siga cargando
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as fh:
            fh.write(f"id={nuevo}\n")
    print(f"OK categoría {nuevo} agregada (activa desde {hoy}, backfill {backfill} días)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
