"""Upsert directo del catálogo completo a Supabase via REST.

Uso:
    python sql/upsert_catalogo_supabase.py

Requiere SUPABASE_URL y SUPABASE_SERVICE_KEY en .env.
Idempotente: re-correr es seguro.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from core.catalog_r import TODAS
from core.supabase_io import upsert_variables


if __name__ == "__main__":
    print(f"Upsertando {len(TODAS)} variables al catálogo Supabase...")
    n = upsert_variables(TODAS)
    print(f"OK — {n} filas procesadas.")
