"""Cliente Google News con ritmo holgado (prioridad: NO ser bloqueado).

Dos operaciones contra news.google.com:
  · buscar(query, dia)  → RSS de búsqueda con after:/before: (≤100 items/consulta)
  · decodificar(link)   → URL original del medio (2 peticiones: página + batchexecute)

Ritmo: todas las peticiones comparten UN reloj. Pausa mínima + jitter aleatorio,
espera exponencial ante 429/503/captcha y un "disyuntor": tras N bloqueos seguidos
la corrida deja de pedir a Google (lo pendiente queda para la próxima corrida).
"""
from __future__ import annotations

import json
import random
import re
import time
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from urllib.parse import quote, urlparse

import feedparser
import requests

UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/124.0 Safari/537.36")
TZ_RD = timezone(timedelta(hours=-4))   # RD no tiene horario de verano


class Bloqueado(RuntimeError):
    """Google respondió con bloqueo persistente: abortar peticiones a Google."""


@dataclass
class Ritmo:
    pausa_min: float = 6.0       # s entre peticiones (mínimo)
    jitter: float = 4.0          # + U(0, jitter) s
    max_bloqueos: int = 3        # bloqueos consecutivos antes de abrir el disyuntor
    esperas: tuple = (60, 180, 420)
    _ultimo: float = 0.0
    _bloqueos: int = 0
    abierto: bool = False
    n_peticiones: int = 0
    n_bloqueos_total: int = 0
    log: list = field(default_factory=list)

    def esperar(self) -> None:
        if self.abierto:
            raise Bloqueado("disyuntor abierto")
        objetivo = self.pausa_min + random.uniform(0, self.jitter)
        dt = time.time() - self._ultimo
        if dt < objetivo:
            time.sleep(objetivo - dt)
        self._ultimo = time.time()
        self.n_peticiones += 1

    def ok(self) -> None:
        self._bloqueos = 0

    def bloqueo(self, motivo: str) -> None:
        self._bloqueos += 1
        self.n_bloqueos_total += 1
        self.log.append(f"{datetime.now():%H:%M:%S} bloqueo: {motivo}")
        if self._bloqueos >= self.max_bloqueos:
            self.abierto = True
            raise Bloqueado(motivo)
        espera = self.esperas[min(self._bloqueos - 1, len(self.esperas) - 1)]
        print(f"  [gnews] {motivo} → espero {espera}s", flush=True)
        time.sleep(espera)


def esperar_conexion(max_horas: float = 6.0) -> bool:
    """Caída de internet ≠ bloqueo de Google: espera a que vuelva la red (prueba cada
    60 s hasta `max_horas`). → True si volvió."""
    import socket
    t0 = time.time()
    avisado = False
    while time.time() - t0 < max_horas * 3600:
        try:
            socket.create_connection(("news.google.com", 443), timeout=10).close()
            if avisado:
                print(f"  [red] conexión restablecida tras {round((time.time() - t0) / 60)} min", flush=True)
            return True
        except OSError:
            if not avisado:
                print("  [red] sin conexión a internet → espero a que vuelva…", flush=True)
                avisado = True
            time.sleep(60)
    return False


class SinRed(RuntimeError):
    """La red no volvió en el tiempo máximo de espera."""


class GoogleNews:
    def __init__(self, ritmo_busqueda: Ritmo | None = None, ritmo_decod: Ritmo | None = None,
                 hl: str = "es-419", gl: str = "DO", ceid: str = "DO:es-419"):
        self.rb = ritmo_busqueda or Ritmo()
        # La decodificación usa otro endpoint; igual va con calma (2 peticiones/artículo).
        # (0 bloqueos en >6.000 peticiones con 4+U(0,3) s → se acorta con margen)
        self.rd = ritmo_decod or Ritmo(pausa_min=3.0, jitter=2.0)
        self.hl, self.gl, self.ceid = hl, gl, ceid
        self.fallos: list[str] = []      # diagnóstico de la decodificación
        self.s = requests.Session()
        self.s.headers["User-Agent"] = UA
        self.s.headers["Accept-Language"] = "es-419,es;q=0.9"

    # ── búsqueda ─────────────────────────────────────────────────────────────
    def buscar(self, query: str, desde: date, hasta: date, reintentos: int = 3) -> list[dict]:
        """Artículos publicados en [desde, hasta] (fechas RD). Lanza Bloqueado."""
        clausula = f" after:{desde - timedelta(days=1):%Y-%m-%d} before:{hasta + timedelta(days=1):%Y-%m-%d}"
        url = (f"https://news.google.com/rss/search?q={quote(query + clausula)}"
               f"&hl={self.hl}&gl={self.gl}&ceid={self.ceid}")
        for _ in range(reintentos):
            self.rb.esperar()
            try:
                r = self.s.get(url, timeout=30)
            except requests.RequestException as e:
                if isinstance(e, (requests.ConnectionError, requests.Timeout)):
                    if not esperar_conexion():
                        raise SinRed(str(e))
                    continue                     # caída de red: no cuenta como bloqueo
                self.rb.bloqueo(f"red: {type(e).__name__}")
                continue
            if r.status_code in (429, 503) or "sorry/index" in r.url:
                self.rb.bloqueo(f"HTTP {r.status_code}")
                continue
            if r.status_code >= 400:
                return []
            feed = feedparser.parse(r.content)
            if not feed.entries and (feed.bozo or b"<rss" not in r.content[:500]):
                self.rb.bloqueo("respuesta no-RSS (posible captcha)")
                continue
            self.rb.ok()
            out = []
            for e in feed.entries:
                it = _entrada(e)
                if it and desde <= it["fecha"] <= hasta:
                    out.append(it)
            return out
        return []

    # ── decodificación del enlace news.google.com → URL del medio ───────────
    def decodificar(self, link: str) -> str | None:
        """URL original o None si Google no la entrega. Lanza Bloqueado."""
        if "news.google.com" not in link:
            return link
        gid = urlparse(link).path.rstrip("/").split("/")[-1]
        self.rd.esperar()
        try:
            r = self.s.get(f"https://news.google.com/rss/articles/{gid}", timeout=30)
        except requests.RequestException as e:
            if isinstance(e, (requests.ConnectionError, requests.Timeout)):
                if not esperar_conexion():
                    raise SinRed(str(e))
                return None
            self.rd.bloqueo(f"red: {type(e).__name__}")
            return None
        if r.status_code in (429, 503) or "sorry/index" in r.url:
            self.rd.bloqueo(f"decod HTTP {r.status_code}")
            return None
        sg = re.search(r'data-n-a-sg="([^"]+)"', r.text)
        ts = re.search(r'data-n-a-ts="([^"]+)"', r.text)
        if not (sg and ts):
            self.fallos.append(f"sin firma: HTTP {r.status_code} url={r.url[:80]} len={len(r.text)}")
            if "consent." in r.url or "sorry" in r.url:
                self.rd.bloqueo(f"consentimiento/captcha: {r.url[:60]}")
            return None
        req = ["Fbv4je",
               f'["garturlreq",[["X","X",["X","X"],null,null,1,1,"US:en",null,1,null,null,null,'
               f'null,null,0,1],"X","X",1,[1,1,1],1,1,null,0,0,null,0],"{gid}",{ts.group(1)},"{sg.group(1)}"]']
        self.rd.esperar()
        try:
            r2 = self.s.post("https://news.google.com/_/DotsSplashUi/data/batchexecute",
                             data={"f.req": json.dumps([[req]])}, timeout=30,
                             headers={"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"})
        except requests.RequestException as e:
            if isinstance(e, (requests.ConnectionError, requests.Timeout)):
                if not esperar_conexion():
                    raise SinRed(str(e))
                return None
            self.rd.bloqueo(f"red: {type(e).__name__}")
            return None
        if r2.status_code in (429, 503):
            self.rd.bloqueo(f"batchexecute HTTP {r2.status_code}")
            return None
        try:
            parte = json.loads(r2.text.split("\n\n")[1])[:-2]
            url = json.loads(parte[0][2])[1]
        except Exception:
            self.fallos.append(f"batchexecute ilegible: HTTP {r2.status_code} {r2.text[:80]!r}")
            return None
        self.rd.ok()
        return url if isinstance(url, str) and url.startswith("http") else None


def _entrada(e) -> dict | None:
    titulo = (getattr(e, "title", "") or "").strip()
    if not titulo:
        return None
    src = getattr(e, "source", None)
    medio = (src.get("title") if isinstance(src, dict) else getattr(src, "title", None)) or ""
    dom = (src.get("href") if isinstance(src, dict) else getattr(src, "href", None)) or ""
    if not medio and " - " in titulo:
        medio = titulo.rsplit(" - ", 1)[-1]
    if medio and titulo.endswith(f" - {medio}"):
        titulo = titulo[: -(len(medio) + 3)].strip()
    pub = getattr(e, "published_parsed", None) or getattr(e, "updated_parsed", None)
    if not pub:
        return None
    dt_utc = datetime(*pub[:6], tzinfo=timezone.utc)
    dt_rd = dt_utc.astimezone(TZ_RD)
    return {
        "titulo": titulo,
        "medio": medio.strip(),
        "dominio": dominio(dom),
        "url_gn": getattr(e, "link", ""),
        "fecha": dt_rd.date(),
        "publicado_utc": dt_utc.isoformat(timespec="seconds"),
    }


def dominio(url: str) -> str:
    try:
        d = urlparse(url).netloc.lower()
    except Exception:
        return ""
    return d[4:] if d.startswith("www.") else d
