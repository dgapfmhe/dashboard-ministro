"""Backfill desde una computadora local (cuando GitHub Actions no está disponible).

Procesa la cola de días (relleno.py) en tramos de 30 min hasta vaciar el rango pedido;
tras cada tramo puntúa el sentimiento de lo nuevo, sube los índices a Supabase y hace
commit+push al repo de datos. Se detiene solo ante un bloqueo de Google.

    set NOTICIAS_DIR=C:/Users/patri/Desktop/dashboard-noticias
    python -m pipelines.noticias.herramientas.backfill_local --desde 2026-07-13 --hasta 2026-08-23
"""
from __future__ import annotations

import argparse
import os
import subprocess
from datetime import date
from pathlib import Path

from ..almacen import Almacen, rango_dias
from ..config import Config
from ..gnews import GoogleNews
from .. import relleno as R
from .. import sentimiento as SE

GUARDAR = Path(__file__).resolve().parents[1] / "guardar_datos.sh"


def guardar(alm: Almacen, msg: str) -> None:
    subprocess.run(["bash", str(GUARDAR), str(alm.base).replace("\\", "/"), msg], check=False)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--desde", required=True)
    ap.add_argument("--hasta", required=True)
    ap.add_argument("--tramo", type=float, default=30)
    a = ap.parse_args()
    objetivo = {str(d) for d in rango_dias(date.fromisoformat(a.desde), date.fromisoformat(a.hasta))}
    alm, cfg = Almacen(), Config()
    gn = GoogleNews()
    while True:
        r = R.relleno(alm, cfg, gn, a.tramo, hasta_vaciar=objetivo)
        SE.puntuar_pendientes(alm, cfg, minutos=10, desde=date(2026, 7, 9))
        if os.environ.get("SUPABASE_URL"):
            try:
                from .. import indices as I
                I.correr(alm, cfg, False, True)
            except Exception as e:
                print(f"[local] índices: {type(e).__name__}: {e}")
        guardar(alm, f"backfill local {', '.join(r['dias_completos'][-3:]) or 'parcial'}")
        quedan = [u["d"] for u in R._cargar_plan(alm)["dias"] if u["d"] in objetivo]
        print(f"[local] quedan {len(quedan)} días del rango pedido", flush=True)
        if not quedan or r["abortado"] == "Bloqueado":
            break


if __name__ == "__main__":
    main()
