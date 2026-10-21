"""Descarga y extracción del TEXTO COMPLETO de cada noticia (trafilatura).

Se guarda el texto íntegro (sin truncar): cada modelo de sentimiento trunca
según su propio tokenizer. Cortesía por dominio: ≥2 s entre peticiones al
mismo medio; dominios distintos se procesan en paralelo (hilos).
"""
from __future__ import annotations

import re
import threading
import time
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor

import requests

from .gnews import UA, dominio

MAX_CHARS = 60_000       # tope de seguridad (páginas que traen todo el sitio)
_locks: dict[str, threading.Lock] = defaultdict(threading.Lock)
_ultimo: dict[str, float] = defaultdict(float)
PAUSA_DOMINIO = 2.0

# Dominios donde no hay texto que extraer (redes sociales, video)
SIN_TEXTO = re.compile(r"(instagram|facebook|twitter|x\.com|tiktok|youtube|youtu\.be)", re.I)


def _cortesia(dom: str) -> None:
    with _locks[dom]:
        dt = time.time() - _ultimo[dom]
        if dt < PAUSA_DOMINIO:
            time.sleep(PAUSA_DOMINIO - dt)
        _ultimo[dom] = time.time()


def extraer(url: str, timeout: int = 25) -> tuple[str, str]:
    """→ (estado, texto). estado ∈ {'ok','vacio','error','sin_texto'}."""
    import trafilatura

    if not url:
        return "error", ""
    if SIN_TEXTO.search(dominio(url)):
        return "sin_texto", ""
    _cortesia(dominio(url))
    try:
        r = requests.get(url, headers={"User-Agent": UA, "Accept-Language": "es,en;q=0.8"},
                         timeout=timeout)
        if r.status_code >= 400:
            return "error", ""
        html = r.text
    except requests.RequestException:
        return "error", ""
    try:
        txt = trafilatura.extract(html, include_comments=False, include_tables=False,
                                  favor_recall=True, url=url) or ""
    except Exception:
        txt = ""
    txt = re.sub(r"[ \t]+", " ", txt).strip()[:MAX_CHARS]
    return ("ok" if len(txt) >= 200 else "vacio"), txt


def extraer_lote(urls: list[str], hilos: int = 6) -> dict[str, tuple[str, str]]:
    """Extrae en paralelo respetando la cortesía por dominio."""
    out: dict[str, tuple[str, str]] = {}
    with ThreadPoolExecutor(max_workers=hilos) as ex:
        for url, res in zip(urls, ex.map(extraer, urls)):
            out[url] = res
    return out


# ── idioma (heurística por palabras vacías; suficiente para es/en) ──────────
_ES = set("el la los las de del que y en un una por con para es se no al lo como más pero sus".split())
_EN = set("the of and to in is that for on with as was by it at from are be this have".split())


def idioma(texto: str) -> str:
    w = re.findall(r"[a-záéíóúñ]+", (texto or "")[:3000].lower())
    if len(w) < 5:
        return "es"
    es = sum(x in _ES for x in w)
    en = sum(x in _EN for x in w)
    return "en" if en > es * 1.2 else "es"
