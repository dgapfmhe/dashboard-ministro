"""Agregaciones mensual→trimestral equivalentes a `mens_a_trim` del R.

El R usaba `aggregate.ts(serie, nfrequency=4, FUN=...)` con distintas FUN:
- 'mean' para niveles, tasas, multiplicadores (IPC, TC, TPM, tasas).
- 'sum'  para flujos (recaudación, remesas).
- 'last' para stocks (deuda, reservas, RIN).

Este módulo expone un mapa var_id -> FUN y una función que aplica
las reglas correctas según el catálogo.
"""
from __future__ import annotations

import pandas as pd

from core.dates import monthly_to_quarterly
from core.logging_utils import get_logger

log = get_logger(__name__)


# Convenciones de agregación: var_id -> FUN
# Usa los IDs cortos del catálogo (ipc_rd, imae, tpm, ...).
AGG_FUN: dict[str, str] = {
    # Tasas / precios / índices / TC -> mean
    "ipc_rd":              "mean",
    "ipc_sub":             "mean",
    "ipc_t":               "mean",
    "ipc_nt":              "mean",
    "imae":                "mean",
    "ici":                 "mean",
    "imam":                "mean",
    "tpm":                 "mean",
    "tia_prom_pond":       "mean",
    "tia_prom_pond_rd":    "mean",
    "tip_prom_pond":       "mean",
    "tib_rd":              "mean",
    "tcn_compra":          "mean",
    "tcn_venta":           "mean",
    "tcn_compra_m":        "mean",
    "tcn_venta_m":         "mean",
    "tcr_rd":              "mean",
    "embi_rd":             "mean",
    "embi":                "mean",
    "cpi_usa":             "mean",
    "indpro_usa":          "mean",
    "ur_sa_usa":           "mean",
    "ur_usa":              "mean",
    "ti_fond_fed":         "mean",
    "ust_10y":             "mean",
    "libor_3m":            "mean",
    "calact_rd":           "mean",
    "liq_rd":              "mean",
    "meta":                "mean",
    "p_petroleo":          "mean",
    "petroleo_wti":        "mean",
    "carbon_aus":          "mean",
    "gas_natural":         "mean",
    "oro":                 "mean",
    "sp500":               "mean",
    "dow_jones":           "mean",
    "vix":                 "mean",
    # Flujos -> sum
    "rem_fam":             "sum",
    "imp_pd_va":           "sum",
    "m_pqoil_rd":          "sum",
    "se_cc_numtur":        "sum",
    "import":              "sum",
    "export":              "sum",
    "ing_trib":            "sum",
    "ing_trib_a":          "sum",
    "ing_ext":             "sum",
    "gk":                  "sum",
    "res_primario":        "sum",
    "res_global":          "sum",
    "ventas_dgii":         "sum",
    "ventas_dgii_rd":      "sum",
    "ventas_const":        "sum",
    "ventas_mineria":      "sum",
    "ventas_manuf":        "sum",
    "ventas_comercio":     "sum",
    "ventas_hoteles":      "sum",
    "ventas_transp":       "sum",
    "ventas_otros":        "sum",
    "compra_fx_tot":       "sum",
    # Stocks -> last
    "rin":                 "last",
    "bmr_rd":              "last",
    "m1_rd":               "last",
    "encaje_me":           "last",
    "encaje_mn":           "last",
    "encajeme_d_q":        "last",
    "encajemn_d_q":        "last",
    "pbcred_nc_rd":        "last",
    "pvcred_nc_rd":        "last",
    "prest_tot":           "last",
    "prest_agr":           "last",
    "prest_ind":           "last",
    "prest_con":           "last",
    "prest_com":           "last",
    "prest_viv":           "last",
    "prest_tar":           "last",
    "prest_cons":          "last",
    "sm_bcrd_vc":          "last",
    "salario":             "last",
}


def largo_a_trimestral(df: pd.DataFrame) -> pd.DataFrame:
    """Toma un DataFrame largo (variable_id, fecha, valor) mensual y lo agrega
    a trimestral aplicando la FUN correspondiente a cada variable."""
    if df.empty:
        return df.copy()
    out: list[pd.DataFrame] = []
    for var_id, sub in df.groupby("variable_id"):
        fun = AGG_FUN.get(var_id, "mean")
        s = sub.set_index(pd.to_datetime(sub["fecha"]))["valor"].sort_index()
        q = monthly_to_quarterly(s, fun=fun)  # type: ignore[arg-type]
        out.append(pd.DataFrame({
            "variable_id": var_id,
            "fecha": q.index.date,
            "valor": q.values.astype(float),
        }).dropna())
    return pd.concat(out, ignore_index=True) if out else pd.DataFrame()
