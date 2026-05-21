"""HTTP con retry + user-agent coherente. Reemplaza `download.file` de R."""
from __future__ import annotations

from pathlib import Path

import requests
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from .config import get_settings
from .logging_utils import get_logger

log = get_logger(__name__)


@retry(
    reraise=True,
    stop=stop_after_attempt(4),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    retry=retry_if_exception_type((requests.RequestException,)),
)
def http_get(url: str, params: dict | None = None, timeout: int = 60) -> requests.Response:
    headers = {"User-Agent": get_settings().user_agent, "Accept": "*/*"}
    log.info("GET %s", url)
    r = requests.get(url, params=params, headers=headers, timeout=timeout, allow_redirects=True)
    r.raise_for_status()
    return r


def download_to(url: str, dest: Path, timeout: int = 120) -> Path:
    """Descarga binario (xlsx, csv, pdf) con retries."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    r = http_get(url, timeout=timeout)
    dest.write_bytes(r.content)
    log.info("↓ %s (%d bytes)", dest.name, len(r.content))
    return dest
