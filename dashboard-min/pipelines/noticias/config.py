"""Carga de configuración (categorías, medios, modelos) y etiquetado por palabras clave.

Etiquetado de una noticia (multi-etiqueta, reproducible):
  1) por QUERY: la búsqueda de la categoría la trajo           → universo 'query'
  2) por PALABRAS CLAVE sobre titular + texto                  → universo 'amplio'
     (amplio = query ∪ palabras clave, incluye el barrido general)

Las palabras clave se derivan solas de las queries (grupos AND de términos OR,
sin el ancla "Republica Dominicana"); se pueden sobreescribir con `palabras_clave`.
"""
from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from datetime import date
from functools import cached_property
from pathlib import Path

import yaml

from .almacen import normalizar

DIR_CONFIG = Path(__file__).parent / "config"
ANCLAS = {"republica dominicana", "rd", "dominicana"}

# ── Filtro geográfico (motor v3 de la investigación) ────────────────────────
RX_RD = re.compile(
    r"dominic|republica dominicana|\brd\b|bcrd|banco central de la rep|dgii|banreservas|"
    r"abinader|pro\s?consumidor|indotel|\bmicm\b|\bmepyd\b|adozona|cnzfe|asonahores|mitur|"
    r"\baird\b|refidomsa|punta catalina|edenorte|edesur|edeeste|santo domingo|santiago de los|"
    r"punta cana|san cristobal|peso dominicano|itbis|banco popular dominicano|quisqueya|cibao")
RX_EXT = re.compile(
    r"venezuela|estados unidos|ee\.?\s?uu|mexico|argentina|colombia|brasil|peru\b|chile|cuba|"
    r"espana|china|rusia|ucrania|israel|gaza|reserva federal|wall street|union europea|ecuador|"
    r"guatemala|honduras|el salvador|nicaragua|bolivia|panama|costa rica|uruguay|paraguay|quito|"
    r"bogota|caracas|lima\b|buenos aires|ciudad de mexico|madrid|santa marta|cartagena|medellin")
DOMINIOS_RD = re.compile(r"(\.do$|diariolibre|listindiario|acento|eldinero|hoy\.com|elcaribe|"
                         r"elnuevodiario|elnacional|noticiassin|z101|almomento|remolacha|"
                         r"diariodominicano|primiciasrd|dominicanostoday|eljaya|elsoldelafrontera|arecoa)")


def relevancia_rd(titulo_n: str, cuerpo_n: str, dom: str | None) -> str:
    """'si' | 'no' | '?'  — solo se descarta ('no') lo CLARAMENTE extranjero:
    medio no dominicano + texto disponible + sin ancla RD + menciona otro país."""
    if dom and DOMINIOS_RD.search(dom):
        return "si"
    blob = f"{titulo_n} {cuerpo_n[:3000]}"
    if RX_RD.search(blob):
        return "si"
    if cuerpo_n and dom and RX_EXT.search(blob):
        return "no"
    return "?"


@dataclass
class Categoria:
    id: str
    nombre: str
    nivel: int                      # 0 = todo, 1 = sector, 2 = subcategoría
    padre: str | None
    origen: str = "investigacion"
    congelada: bool = False
    activa_desde: date = date(2016, 1, 1)
    queries: list[str] = field(default_factory=list)
    palabras_clave: list[list[str]] = field(default_factory=list)   # grupos AND de OR
    backfill_dias: int = 0

    @cached_property
    def _regex(self) -> list[re.Pattern]:
        return [re.compile(r"\b(?:" + "|".join(re.escape(normalizar(t)) for t in g) + r")\b")
                for g in self.palabras_clave if g]

    def coincide(self, titulo_n: str, cuerpo_n: str) -> bool:
        """titulo_n / cuerpo_n ya normalizados (minúsculas, sin acentos)."""
        rx = self._regex
        if not rx:
            return False
        if all(r.search(titulo_n) for r in rx):
            return True
        if not cuerpo_n:
            return False
        blob = f"{titulo_n} {cuerpo_n}"
        if not all(r.search(blob) for r in rx):
            return False
        distintos = set()
        for r in rx:
            distintos.update(m.group(0) for m in r.finditer(blob))
        return len(distintos) >= 2


def terminos_de_query(q: str) -> list[list[str]]:
    """'(a OR "b c") AND (d OR e) AND "Republica Dominicana"' → [[a,'b c'],[d,e]]"""
    grupos = []
    for parte in re.split(r"\)\s+AND\s+|\s+AND\s+(?=[(\"])", q):
        terms = re.findall(r'"([^"]+)"|([^\s()"]+)', parte)
        ts = [a or b for a, b in terms]
        ts = [t for t in ts if t.upper() not in {"AND", "OR", "NOT"} and ":" not in t]
        if not ts or {normalizar(t) for t in ts} <= ANCLAS:
            continue
        grupos.append(ts)
    return grupos


def _fecha(v) -> date:
    return v if isinstance(v, date) else date.fromisoformat(str(v))


class Config:
    def __init__(self, dir_config: Path = DIR_CONFIG):
        self.dir = Path(dir_config)
        self.cat_raw = yaml.safe_load((self.dir / "categorias.yaml").read_text("utf-8"))
        self.medios = yaml.safe_load((self.dir / "medios.yaml").read_text("utf-8"))
        self.modelos = yaml.safe_load((self.dir / "modelos.yaml").read_text("utf-8"))["modelos"]
        self.categorias: dict[str, Categoria] = {}
        self._construir()

    def _construir(self) -> None:
        self.categorias["TODO"] = Categoria("TODO", "Todas las noticias", 0, None,
                                            origen="sistema", congelada=True)
        for s in self.cat_raw["sectores"]:
            kw = dict(origen=s.get("origen", "investigacion"),
                      congelada=bool(s.get("congelada", False)),
                      activa_desde=_fecha(s.get("activa_desde", "2016-01-01")),
                      backfill_dias=int(s.get("backfill_dias", 0)))
            sector = Categoria(s["id"], s["nombre"], 1, None, **kw)
            self.categorias[sector.id] = sector
            subs = s.get("subcategorias") or []
            if s.get("queries"):           # categoría de usuario sin subcategorías
                subs = [{"id": f"{s['id']}.principal", "nombre": s["nombre"],
                         "queries": s["queries"], "palabras_clave": s.get("palabras_clave")}] + subs
            for sub in subs:
                qs = list(sub.get("queries") or [])
                pk = sub.get("palabras_clave")
                if pk:
                    grupos = [g if isinstance(g, list) else [g] for g in pk]
                    if all(len(g) == 1 for g in grupos):   # lista plana = un grupo OR
                        grupos = [[g[0] for g in grupos]]
                else:
                    grupos = []
                    for q in qs:                          # varias queries → OR de grupos
                        g = terminos_de_query(q)
                        if g:
                            grupos = g if not grupos else _union_grupos(grupos, g)
                self.categorias[sub["id"]] = Categoria(
                    sub["id"], sub["nombre"], 2, sector.id, queries=qs,
                    palabras_clave=grupos,
                    **{**kw,
                       "activa_desde": _fecha(sub.get("activa_desde", kw["activa_desde"])),
                       "backfill_dias": int(sub.get("backfill_dias", kw["backfill_dias"])),
                       "origen": sub.get("origen", kw["origen"]),
                       "congelada": bool(sub.get("congelada", kw["congelada"]))})

    # ── consultas ────────────────────────────────────────────────────────────
    def sectores(self) -> list[Categoria]:
        return [c for c in self.categorias.values() if c.nivel == 1]

    def hojas(self) -> list[Categoria]:
        return [c for c in self.categorias.values() if c.nivel == 2]

    def hijos(self, sector_id: str) -> list[Categoria]:
        return [c for c in self.hojas() if c.padre == sector_id]

    def tareas_query(self, dia: date) -> list[tuple[str, str]]:
        """[(subcat_id, query)] activas en `dia`."""
        return [(c.id, q) for c in self.hojas() if c.activa_desde <= dia for q in c.queries]

    def modelos_activos(self) -> list[dict]:
        return [m for m in self.modelos if m.get("activo", True)]

    @cached_property
    def hash_etiquetado(self) -> str:
        blob = "v2|" + json.dumps({c.id: c.palabras_clave for c in self.hojas()}, sort_keys=True)
        return hashlib.sha1(blob.encode()).hexdigest()[:12]

    def etiquetar(self, titulo: str, texto: str | None, dom: str | None = None) -> tuple[list[str], str]:
        """→ (subcategorías por palabras clave, relevancia RD 'si'|'no'|'?')."""
        t = normalizar(titulo)
        b = normalizar((texto or "")[:5000])
        return [c.id for c in self.hojas() if c.coincide(t, b)], relevancia_rd(t, b, dom)


def _union_grupos(a: list[list[str]], b: list[list[str]]) -> list[list[str]]:
    """Dos queries de la misma subcategoría: si tienen un solo grupo, se unen por OR.
    Si alguna tiene varios grupos AND, se conserva la más restrictiva (la primera)."""
    if len(a) == 1 and len(b) == 1:
        return [sorted(set(a[0]) | set(b[0]))]
    return a
