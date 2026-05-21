"""Genera un script SQL idempotente para upsertar el catálogo completo en Supabase.

Uso:
    python sql/generar_catalogo_sql.py > sql/catalogo_completo.sql
    # luego pegar en Supabase SQL Editor

El SQL es idempotente: usa INSERT ... ON CONFLICT (id) DO UPDATE.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from core.catalog_r import TODAS


def esc(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    s = str(v).replace("'", "''")
    return f"'{s}'"


print("-- ============================================================================")
print("-- Catálogo de Variables — generado desde core/catalog_r.py")
print(f"-- Total: {len(TODAS)} variables")
print("-- ============================================================================")
print("-- Idempotente: re-correr no rompe nada; actualiza nombre/módulo/etc.")
print("BEGIN;")
print()

for v in TODAS:
    cols = ["id", "nombre", "descripcion", "modulo", "submodulo",
            "frecuencia", "unidad", "escala", "fuente", "fuente_url",
            "tipo", "formula", "activo"]
    vals = [
        esc(v["id"]), esc(v["nombre"]), esc(v.get("descripcion")),
        esc(v["modulo"]), esc(v.get("submodulo")),
        esc(v["frecuencia"]), esc(v["unidad"]), esc(v.get("escala", "Unidad")),
        esc(v["fuente"]), esc(v.get("fuente_url")),
        esc(v.get("tipo", "directa")), esc(v.get("formula")),
        esc(v.get("activo", True)),
    ]
    print(f"INSERT INTO variables ({', '.join(cols)}) VALUES ({', '.join(vals)})")
    print("  ON CONFLICT (id) DO UPDATE SET")
    sets = [f"{c} = EXCLUDED.{c}" for c in cols if c != "id"]
    sets.append("actualizado_en = NOW()")
    print("    " + ",\n    ".join(sets) + ";")
    print()

print("COMMIT;")
print()
print(f"-- Listo. {len(TODAS)} filas upserted.")
