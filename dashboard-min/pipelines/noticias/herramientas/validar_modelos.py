"""Valida cada modelo de sentimiento contra el set-oro etiquetado a mano
(319 titulares económicos de la investigación; se excluyen los 'Irrelevante').

    python -m pipelines.noticias.herramientas.validar_modelos \
        [--importar ".../Investigacion/files/validacion_nlp_template.xlsx"] [--modelo ID]

El set-oro se guarda en el repo privado (validacion/oro.parquet). Resultado en
estado/validacion_modelos.json → se publica en sent_modelos (F1, kappa).
"""
from __future__ import annotations

import argparse

import pandas as pd
from sklearn.metrics import cohen_kappa_score, f1_score

from ..almacen import Almacen, ahora
from ..config import Config
from ..sentimiento import Modelo

MAPA = {"Positive": "POS", "Neutral": "NEU", "Negative": "NEG"}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=None)
    ap.add_argument("--importar", default=None)
    ap.add_argument("--modelo", action="append", default=None)
    a = ap.parse_args()
    alm, cfg = Almacen(a.dir), Config()
    ruta = alm.base / "validacion" / "oro.parquet"
    if a.importar:
        d = pd.read_excel(a.importar, sheet_name="ETIQUETAR")
        d = d[d["humana_1"].isin(MAPA)]
        oro = pd.DataFrame({"titulo": d["Titular"].astype(str).str.replace(r"\s+-\s+[^-]+$", "", regex=True),
                            "etiqueta": d["humana_1"].map(MAPA), "categoria": d["Categoria"]})
        ruta.parent.mkdir(parents=True, exist_ok=True)
        oro.to_parquet(ruta, index=False)
        print(f"set-oro importado: {len(oro)} titulares")
    oro = pd.read_parquet(ruta)
    res = alm.estado("validacion_modelos", {})
    for spec in cfg.modelos:
        if a.modelo and spec["id"] not in a.modelo:
            continue
        if not a.modelo and not spec.get("activo", True):
            continue
        p = Modelo(spec).puntuar(oro["titulo"].tolist(), [None] * len(oro))
        y, yhat = oro["etiqueta"], p["etiqueta"]
        res[spec["id"]] = {
            "f1_macro": round(float(f1_score(y, yhat, average="macro")), 4),
            "exactitud": round(float((y == yhat).mean()), 4),
            "kappa": round(float(cohen_kappa_score(y, yhat)), 4),
            "n": int(len(oro)), "evaluado_en": ahora(),
            "confusion": pd.crosstab(y, yhat).to_dict(),
        }
        print(spec["id"], res[spec["id"]])
    alm.guardar_estado("validacion_modelos", res)


if __name__ == "__main__":
    main()
