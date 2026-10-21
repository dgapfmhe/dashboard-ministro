"""Puntuación de sentimiento con modelos intercambiables (config/modelos.yaml).

    python -m pipelines.noticias.sentimiento --minutos 60            # todos los activos
    python -m pipelines.noticias.sentimiento --modelo xlmr_multilingue --forzar

Cada modelo guarda en puntajes/<modelo>/… : pos, neu, neg (probabilidades
promedio ponderadas), polaridad = P(pos) − P(neg) ∈ [−1, 1] y etiqueta (argmax).
Unidades puntuadas: titular (peso 2) + bloques del texto (peso 1/(1+i): el
lede pesa más que el cierre). Si la nota aún no tiene texto se puntúa el
titular (base='titulo') y se RE-puntúa cuando llega el texto (base='texto').
"""
from __future__ import annotations

import argparse
import os
import re
import sys
import time
from datetime import date

import numpy as np
import pandas as pd

from .almacen import Almacen, ahora
from .config import Config

ETQ = ("POS", "NEU", "NEG")


def bloques(texto: str, tam: int = 450, maximo: int = 6) -> list[str]:
    texto = re.sub(r"\s+", " ", texto or "").strip()
    if not texto:
        return []
    partes, actual = [], ""
    for frase in re.split(r"(?<=[.!?])\s+", texto):
        if len(actual) + len(frase) <= tam:
            actual = f"{actual} {frase}".strip()
        else:
            if actual:
                partes.append(actual)
            actual = frase[:tam * 2]
        if len(partes) >= maximo:
            break
    if actual and len(partes) < maximo:
        partes.append(actual)
    return partes[:maximo]


class Modelo:
    """Envoltorio común: probas(lista_textos) → array (n, 3) en orden POS, NEU, NEG."""

    def __init__(self, spec: dict):
        self.spec = spec
        self.id = spec["id"]
        self._m = None

    def _cargar(self):
        if self._m is not None:
            return
        try:
            import torch
            torch.set_num_threads(max(1, os.cpu_count() or 1))
        except Exception:
            pass
        t = self.spec["tipo"]
        if t == "pysentimiento":
            from pysentimiento import create_analyzer
            self._m = create_analyzer(task="sentiment", lang=self.spec.get("lang", "es"))
        elif t in ("hf_pipeline", "local"):
            from transformers import pipeline
            ruta = self.spec["modelo"] if t == "hf_pipeline" else self.spec["ruta"]
            self._m = pipeline("text-classification", model=ruta, tokenizer=ruta,
                               top_k=None, truncation=True)
        else:
            raise ValueError(f"tipo de modelo no soportado: {t}")

    def probas(self, textos: list[str], lote: int = 32) -> np.ndarray:
        self._cargar()
        out = np.zeros((len(textos), 3), dtype=np.float32)
        for i in range(0, len(textos), lote):
            parte = textos[i:i + lote]
            if self.spec["tipo"] == "pysentimiento":
                res = self._m.predict(parte)
                for j, r in enumerate(res):
                    p = r.probas
                    out[i + j] = [p.get("POS", 0), p.get("NEU", 0), p.get("NEG", 0)]
            else:
                mapa = {k.lower(): v for k, v in self.spec.get("mapa", {}).items()}
                res = self._m(parte)
                for j, r in enumerate(res):
                    d = {mapa.get(x["label"].lower(), x["label"].upper()): x["score"] for x in r}
                    out[i + j] = [d.get("POS", 0), d.get("NEU", 0), d.get("NEG", 0)]
        return out

    def puntuar(self, titulos: list[str], textos: list[str | None]) -> pd.DataFrame:
        tam = int(self.spec.get("bloque_chars", 450))
        mx = int(self.spec.get("max_bloques", 6))
        unidades, pesos, dueno = [], [], []
        for k, (ti, tx) in enumerate(zip(titulos, textos)):
            if ti:
                unidades.append(ti); pesos.append(2.0); dueno.append(k)
            for i, b in enumerate(bloques(tx or "", tam, mx)):
                unidades.append(b); pesos.append(1.0 / (1 + i)); dueno.append(k)
        P = self.probas(unidades) if unidades else np.zeros((0, 3))
        w = np.asarray(pesos)[:, None]
        n = len(titulos)
        acc = np.zeros((n, 3)); ws = np.zeros(n); nb = np.zeros(n, dtype=int)
        np.add.at(acc, dueno, P * w)
        np.add.at(ws, dueno, w[:, 0])
        np.add.at(nb, dueno, 1)
        ws[ws == 0] = 1
        prom = acc / ws[:, None]
        return pd.DataFrame({
            "pos": prom[:, 0], "neu": prom[:, 1], "neg": prom[:, 2],
            "polaridad": prom[:, 0] - prom[:, 2],
            "etiqueta": [ETQ[i] for i in prom.argmax(1)],
            "n_bloques": nb,
        })


def puntuar_pendientes(alm: Almacen, cfg: Config, modelos: list[str] | None = None,
                       minutos: float = 60, forzar: bool = False,
                       desde: date | None = None) -> dict:
    t0 = time.time()
    res = {}
    specs = [m for m in cfg.modelos if (m["id"] in modelos if modelos else m.get("activo", True))]
    for spec in specs:
        mod = Modelo(spec)
        idiomas = set(spec.get("idiomas") or ["es"])
        hechos = 0
        for d in reversed(alm.dias("articulos")):
            if desde and d < desde:
                break
            if (time.time() - t0) / 60 > minutos:
                break
            art = alm.leer_dia("articulos", d, columnas=["id", "titulo", "texto", "texto_estado", "idioma"])
            art = art[art["idioma"].fillna("es").isin(idiomas)]
            if art.empty:
                continue
            prev = alm.leer_dia("puntajes", d, modelo=spec["id"])
            base_prev = dict(zip(prev["id"], prev["base"])) if len(prev) else {}
            tiene_txt = art["texto_estado"].eq("ok")
            necesita = art["id"].map(lambda i: i not in base_prev) | (
                tiene_txt & art["id"].map(lambda i: base_prev.get(i) == "titulo"))
            if forzar:
                necesita[:] = True
            todo = art[necesita]
            if todo.empty:
                continue
            textos = [t if e == "ok" else None for t, e in zip(todo["texto"], todo["texto_estado"])]
            p = mod.puntuar(todo["titulo"].tolist(), textos)
            p.insert(0, "id", todo["id"].values)
            p["fecha"] = d
            p["base"] = ["texto" if t else "titulo" for t in textos]
            p["puntuado_en"] = ahora()
            nuevo = pd.concat([prev[~prev["id"].isin(p["id"])], p], ignore_index=True) if len(prev) else p
            alm.escribir_dia("puntajes", d, nuevo, modelo=spec["id"])
            hechos += len(p)
        res[spec["id"]] = hechos
        print(f"[sentimiento] {spec['id']}: {hechos:,} noticias puntuadas", flush=True)
    res["minutos"] = round((time.time() - t0) / 60, 1)
    alm.bitacora({"evento": "sentimiento", **res})
    return res


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=None)
    ap.add_argument("--modelo", action="append", default=None)
    ap.add_argument("--minutos", type=float, default=60)
    ap.add_argument("--forzar", action="store_true")
    ap.add_argument("--desde", default=None)
    a = ap.parse_args(argv)
    puntuar_pendientes(Almacen(a.dir), Config(), a.modelo, a.minutos, a.forzar,
                       date.fromisoformat(a.desde) if a.desde else None)
    return 0


if __name__ == "__main__":
    sys.exit(main())
