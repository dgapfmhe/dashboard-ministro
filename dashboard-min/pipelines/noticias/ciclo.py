"""Ciclo autónomo de noticias: corre cada 3 h en GitHub Actions y hace lo pendiente
por prioridad, con presupuesto de tiempo y checkpoint (commit al repo de datos)
después de cada paso. Como cada corrida es idéntica ("haz lo que falte"), si GitHub
cancela o retrasa una, la siguiente la cubre.

  1. diario       t-1 (y días atrasados, máx. 5) desde las 05:00 RD · re-barrido t-3
  2. categorías   backfill de categorías nuevas
  3. auditoría    días débiles del último año → cola de relleno (sin Google, 1×/día)
  4. relleno      cola de días (huecos, pedidos, días débiles): categorías con ventana de 1 día + barrido
  5. textos       URL original + texto completo (cola, lo reciente primero)
  6. profundizar  histórico 2016→jul-2026 día por día (cuando la cola de relleno está vacía)
  7. sentimiento  modelos activos sobre lo nuevo / lo que ganó texto
  8. índices + pronósticos oficiales → Supabase

    python -m pipelines.noticias.ciclo --minutos 165
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from datetime import date, datetime, timedelta
from pathlib import Path

from .almacen import Almacen
from .config import Config
from .gnews import TZ_RD, GoogleNews
from . import relleno as R
from . import scraper as S
from . import sentimiento as SE

GUARDAR_SH = Path(__file__).parent / "guardar_datos.sh"
RESERVA_FINAL = 14     # min reservados para sentimiento + índices + pronósticos


class Reloj:
    def __init__(self, minutos: float):
        self.fin = time.time() + minutos * 60
    def resto(self) -> float:
        return max(0.0, (self.fin - time.time()) / 60)
    def libre(self) -> float:
        return max(0.0, self.resto() - RESERVA_FINAL)


def correr(minutos: float = 165, guardar: bool = True, dia_forzado: date | None = None,
           indices_completo: bool = False) -> dict:
    alm, cfg = Almacen(), Config()
    gn = GoogleNews()
    reloj = Reloj(minutos)
    est = alm.estado("ciclo", {})
    resumen: dict = {"inicio": datetime.now(TZ_RD).isoformat(timespec="minutes")}

    def checkpoint(msg: str):
        if guardar and GUARDAR_SH.exists():
            subprocess.run(["bash", str(GUARDAR_SH), str(alm.base), msg], check=False)

    def google_ok() -> bool:
        return not gn.rb.abierto

    ahora_rd = datetime.now(TZ_RD)
    ayer = ahora_rd.date() - timedelta(days=1)

    # 1) diario (con recuperación de días atrasados)
    pendientes_diario = []
    if dia_forzado:
        pendientes_diario = [dia_forzado]
    elif ahora_rd.hour >= 5:
        ultimo = date.fromisoformat(est["ultimo_diario"]) if est.get("ultimo_diario") else ayer - timedelta(days=1)
        d = max(ultimo + timedelta(days=1), ayer - timedelta(days=4))
        while d <= ayer:
            pendientes_diario.append(d); d += timedelta(days=1)
    for d in pendientes_diario:
        if not google_ok() or reloj.libre() < 45:
            break
        r = S.diario(alm, cfg, gn, d)
        resumen.setdefault("diario", []).append({"dia": str(d), "nuevos": r["nuevos"], "abortado": r["abortado"]})
        if not r["abortado"]:
            est["ultimo_diario"] = str(d) if not dia_forzado else est.get("ultimo_diario", str(d))
            alm.guardar_estado("ciclo", est)
        checkpoint(f"diario {d}")

    # 2) categorías nuevas
    if google_ok() and any(c.backfill_dias > 0 for c in cfg.hojas()) and reloj.libre() > 20:
        resumen["categorias"] = S.categorias_nuevas(alm, cfg, gn, min(20, reloj.libre() * 0.15)).get("semanas")
        checkpoint("categorias nuevas")

    # 3) auditoría de cobertura (1 vez por día; sin Google)
    if est.get("ultima_auditoria") != str(ahora_rd.date()):
        resumen["auditoria"] = R.auditar(alm)
        est["ultima_auditoria"] = str(ahora_rd.date())
        alm.guardar_estado("ciclo", est)

    # 4) relleno profundo
    if R._cargar_plan(alm)["dias"] and google_ok() and reloj.libre() > 10:
        r = R.relleno(alm, cfg, gn, reloj.libre() * 0.6)
        resumen["relleno"] = {"consultas": r["consultas"], "nuevos": r["nuevos"], "dias": r["dias_completos"],
                               "pendientes": r["pendientes"], "abortado": r["abortado"]}
        checkpoint("relleno profundo")

    # 5) textos completos
    if reloj.libre() > 10:
        r = S.textos(alm, cfg, gn, reloj.libre() * 0.55)
        resumen["textos"] = {k: r.get(k) for k in ("decodificadas", "textos_ok", "abortado")}
        checkpoint("textos")

    # 6) profundizar histórico (solo si no hay relleno pendiente)
    if not R._cargar_plan(alm)["dias"] and google_ok() and reloj.libre() > 10:
        r = R.profundizar(alm, cfg, gn, reloj.libre() * 0.8)
        resumen["profundizar"] = {k: r.get(k) for k in ("consultas", "nuevos", "dias", "cursor")}
        checkpoint("profundizar historico")

    # 7) sentimiento
    r = SE.puntuar_pendientes(alm, cfg, minutos=max(8, reloj.resto() - 7))
    resumen["sentimiento"] = r
    checkpoint("sentimiento")

    # 8) índices + pronósticos
    if os.environ.get("SUPABASE_URL") and os.environ.get("SUPABASE_SERVICE_KEY"):
        from . import indices as I
        try:
            resumen["indices"] = {k: v for k, v in I.correr(alm, cfg, indices_completo, True).items() if k != "etiquetas_dias"}
        except Exception as e:
            resumen["indices_error"] = f"{type(e).__name__}: {str(e)[:200]}"
            print(f"[ciclo] índices falló: {resumen['indices_error']}")
        try:
            from . import pronosticos as P
            P.correr(True)
        except Exception as e:
            resumen["pronosticos_error"] = f"{type(e).__name__}: {str(e)[:200]}"
            print(f"[ciclo] pronósticos falló: {resumen['pronosticos_error']}")
        checkpoint("indices")

    resumen["bloqueos_google"] = gn.rb.log + gn.rd.log
    resumen["fin"] = datetime.now(TZ_RD).isoformat(timespec="minutes")
    alm.bitacora({"evento": "ciclo", **resumen})
    checkpoint("ciclo")
    print(f"[ciclo] {resumen}")
    return resumen


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--minutos", type=float, default=165)
    ap.add_argument("--sin-guardar", action="store_true")
    ap.add_argument("--dia", default=None)
    ap.add_argument("--indices-completo", action="store_true")
    a = ap.parse_args(argv)
    correr(a.minutos, not a.sin_guardar, date.fromisoformat(a.dia) if a.dia else None, a.indices_completo)
    return 0


if __name__ == "__main__":
    sys.exit(main())
