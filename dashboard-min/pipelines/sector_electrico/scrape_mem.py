"""Scraping del Informe de Desempeño del MEM (mem.gob.do).

Replica la lógica de `data1.R` (l. 67-92): localiza el último link cuyo
texto contenga "Anexo" en la página del Informe de Desempeño y descarga
el archivo xlsx.
"""
from __future__ import annotations

from pathlib import Path

from bs4 import BeautifulSoup

from core.http_utils import http_get, download_to
from core.logging_utils import get_logger

log = get_logger(__name__)


INFORME_URL = "https://mem.gob.do/category/sector-electrico/informe-de-desempeno/"


def obtener_url_anexo_vigente() -> str:
    """Devuelve la URL del xlsx "Anexo" más reciente publicado en MEM."""
    html = http_get(INFORME_URL).text
    soup = BeautifulSoup(html, "html.parser")
    anchors = soup.select("div a")
    for a in anchors:
        texto = (a.get_text() or "").strip()
        href = a.get("href") or ""
        if "Anexo" in texto and href.lower().endswith((".xlsx", ".xlsm")):
            log.info("Anexo vigente: %s -> %s", texto, href)
            return href
    # Fallback: tomar el primer href cuyo href contenga 'Anexo'
    for a in anchors:
        href = a.get("href") or ""
        if "Anexo" in href and href.lower().endswith((".xlsx", ".xlsm")):
            return href
    raise RuntimeError("No se encontró un link 'Anexo' en la página del MEM")


def descargar_anexo(dest: Path) -> Path:
    """Descarga el Anexo más reciente al path indicado."""
    url = obtener_url_anexo_vigente()
    return download_to(url, dest)
