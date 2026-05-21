"""Catálogo canónico de variables — IDs cortos snake_case.

Alineado con `metadata_data_mensual` / `metadata_data_trimestral` del Excel
`dataDGAPF.xlsx` que mantiene la DGAPF. Cuando se quiera agregar una
variable nueva, basta con:

  (a) Agregar la entrada al diccionario MENSUAL/TRIMESTRAL/DIARIA aquí, o
  (b) Agregar una fila en `metadata_data_mensual` del Excel y llamar a
      `core.catalog_loader.cargar_desde_excel(path)` (la unión entre ambos
      se hace por el campo `id`).

Tipos de variables:
  - 'directa'  : viene de una descarga (BCRD, FRED, Yahoo, etc.).
  - 'derivada' : se calcula con una fórmula sobre otras variables. Las
                 fórmulas se evalúan post-ingesta en `core.derived`.

Convenciones de Sector → módulo Supabase (1:1 con metadata DGAPF):
  Real, Precios, Mercado Cambiario, Externo, Fiscal, Monetario, Financiero,
  Eléctrico (M8, no aparece en metadata - es local).
"""
from __future__ import annotations

from typing import Iterable


def _v(id_: str, nombre: str, sector: str, frecuencia: str, unidad: str,
       fuente: str, escala: str = "Unidad", tipo: str = "directa",
       formula: str | None = None, descripcion: str | None = None) -> dict:
    return {
        "id": id_,
        "nombre": nombre,
        "modulo": sector,
        "submodulo": None,
        "frecuencia": frecuencia,
        "unidad": unidad,
        "fuente": fuente,
        "escala": escala,
        "tipo": tipo,                # 'directa' | 'derivada'
        "formula": formula,           # solo si tipo='derivada'
        "descripcion": descripcion,
        "activo": True,
    }


# ============================================================================
# DIARIAS (data_diaria) — desde Yahoo / FRED / scraping mercados
# ============================================================================
DIARIAS: list[dict] = [
    _v("tcn_compra",     "Tipo de cambio (compra)",        "Mercado Cambiario", "diaria", "RD$/US$", "BCRD"),
    _v("tcn_venta",      "Tipo de cambio (venta)",         "Mercado Cambiario", "diaria", "RD$/US$", "BCRD"),
    _v("tcn_spread",     "Spread tipo de cambio venta",    "Mercado Cambiario", "diaria", "RD$/US$", "BCRD",
       tipo="derivada", formula="tcn_venta - tcn_compra"),
    _v("petroleo_wti",   "Petróleo WTI",                   "Externo",   "diaria", "US$/barril", "Yahoo"),
    _v("carbon_aus",     "Carbón Australiano",             "Externo",   "diaria", "US$/ton",    "Yahoo"),
    _v("oro",            "Oro",                             "Externo",   "diaria", "US$/oz",     "Yahoo"),
    _v("gas_natural",    "Gas Natural Estadounidense",     "Externo",   "diaria", "US$/MMBtu",  "Yahoo"),
    _v("embi",           "EMBI Global",                    "Financiero","diaria", "pbs",        "BCRD"),
    _v("embi_rd",        "EMBI RD - Latino",               "Financiero","diaria", "pbs",        "BCRD"),
    _v("sp500",          "S&P 500",                        "Financiero","diaria", "índice",     "Yahoo"),
    _v("dow_jones",      "Dow Jones Industrial Average",   "Financiero","diaria", "índice",     "Yahoo"),
    _v("vix",            "Índice VIX",                     "Financiero","diaria", "índice",     "Yahoo"),
    _v("ust_10y",        "10Y Treasury yield",             "Financiero","diaria", "%",          "FRED"),
    _v("tia_rd_dop",     "Tasa Activa RD$",                "Financiero","diaria", "% anual",    "BCRD"),
    _v("tia_rd_usd",     "Tasa Activa US$",                "Financiero","diaria", "% anual",    "BCRD"),
    _v("tip_rd_dop",     "Tasa Pasiva RD$",                "Financiero","diaria", "% anual",    "BCRD"),
    _v("tip_rd_usd",     "Tasa Pasiva US$",                "Financiero","diaria", "% anual",    "BCRD"),
    _v("tpm",            "Tasa Política Monetaria",        "Financiero","diaria", "%",          "BCRD"),
    _v("prob_fed_alza",  "Prob. FED sube 25 pb",           "Financiero","diaria", "%",          "CME"),
    _v("prob_fed_mant",  "Prob. FED mantiene",             "Financiero","diaria", "%",          "CME"),
    _v("prob_fed_baja",  "Prob. FED baja 25 pb",           "Financiero","diaria", "%",          "CME"),
]


# ============================================================================
# MENSUALES (data_mensual + metadata_data_mensual)
# ============================================================================
MENSUALES: list[dict] = [
    # ------- Real -------
    _v("imae",           "IMAE",                            "Real",     "mensual", "índice",  "BCRD",  descripcion="Serie empalmada del IMAE"),
    _v("ici",            "Índice Confianza Industrial",     "Real",     "mensual", "índice",  "BCRD"),
    _v("imam",           "IMAM",                            "Real",     "mensual", "índice",  "AIRD",  descripcion="Índice Mensual Actividad Manufacturera"),
    _v("salario",        "Salario nominal",                 "Real",     "mensual", "RD$",     "SIPEN", escala="Miles",
       descripcion="Salario cotizable"),
    _v("ventas_dgii",    "Ventas DGII Total",               "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_const",   "Ventas Construcción",             "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_mineria", "Ventas Minería",                  "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_manuf",   "Ventas Manufactura",              "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_comercio","Ventas Comercio",                 "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_hoteles", "Ventas Hoteles/Bares/Rest.",      "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_transp",  "Ventas Transporte",               "Real",     "mensual", "RD$",     "DGII", escala="Millones"),
    _v("ventas_otros",   "Ventas Otros sectores",           "Real",     "mensual", "RD$",     "DGII", escala="Millones"),

    # ------- Precios -------
    _v("ipc_rd",         "IPC General",                     "Precios",  "mensual", "índice",  "BCRD",
       descripcion="IPC Nacional, Dic.2010=100"),
    _v("ipc_sub",        "IPC Subyacente",                  "Precios",  "mensual", "índice",  "BCRD"),
    _v("ipc_t",          "IPC Transables",                  "Precios",  "mensual", "índice",  "BCRD"),
    _v("ipc_nt",         "IPC No Transables",               "Precios",  "mensual", "índice",  "BCRD"),
    _v("meta",           "Meta de Inflación",               "Precios",  "mensual", "%",       "BCRD"),
    _v("ipc_yoy",        "Inflación interanual",            "Precios",  "mensual", "%",       "BCRD",
       tipo="derivada", formula="ipc_rd / lag(ipc_rd, 12) - 1"),
    _v("ipc_mom",        "Inflación mensual",               "Precios",  "mensual", "%",       "BCRD",
       tipo="derivada", formula="ipc_rd / lag(ipc_rd, 1) - 1"),

    # ------- Mercado Cambiario (mensual: promedio del mes) -------
    _v("tcn_compra_m",   "TC Nominal Compra (prom mes)",    "Mercado Cambiario", "mensual", "RD$/US$", "BCRD"),
    _v("tcn_venta_m",    "TC Nominal Venta (prom mes)",     "Mercado Cambiario", "mensual", "RD$/US$", "BCRD"),
    _v("tcr_rd",         "Tipo de Cambio Real USD/DOP",     "Mercado Cambiario", "mensual", "índice",  "IRCER-secmca"),
    _v("tcn_usa_spread", "Spread TC USA",                   "Mercado Cambiario", "mensual", "RD$/US$", "BCRD"),

    # ------- Externo -------
    _v("indpro_usa",     "IPI EE.UU.",                      "Externo",  "mensual", "índice",  "FRED"),
    _v("cpi_usa",        "CPI EE.UU.",                      "Externo",  "mensual", "índice",  "FRED"),
    _v("ur_sa_usa",      "Desempleo USA SA",                "Externo",  "mensual", "%",       "BLS"),
    _v("ur_usa",         "Desempleo USA NSA",               "Externo",  "mensual", "%",       "BLS"),
    _v("imp_pd_va",      "Imp. Petróleo y derivados (valor)","Externo",  "mensual", "US$",     "BCRD"),
    _v("m_pqoil_rd",     "Imp. Petróleo y derivados (vol)", "Externo",  "mensual", "barriles","BCRD",  escala="Millones"),
    _v("se_cc_numtur",   "Llegada de turistas",             "Externo",  "mensual", "personas","BCRD"),
    _v("import",         "Importaciones Totales",           "Externo",  "mensual", "US$",     "DGA",   escala="Millones"),
    _v("export",         "Exportaciones Totales",           "Externo",  "mensual", "US$",     "DGA",   escala="Millones"),
    _v("rem_fam",        "Remesas familiares",              "Externo",  "mensual", "US$",     "BCRD",  escala="Millones"),
    _v("p_petroleo",     "Precio Petróleo (WB)",            "Externo",  "mensual", "US$",     "BancoMundial"),
    _v("ti_fond_fed",    "Fed Funds rate",                  "Externo",  "mensual", "%",       "FRED"),
    _v("balanza_com",    "Balanza Comercial",               "Externo",  "mensual", "US$",     "DGA",   escala="Millones",
       tipo="derivada", formula="export - import"),

    # ------- Fiscal -------
    _v("ing_trib",       "Ingresos Tributarios",            "Fiscal",   "mensual", "RD$",     "DGAPF", escala="Millones"),
    _v("ing_ext",        "Ingresos Extraordinarios",        "Fiscal",   "mensual", "RD$",     "DGPLT", escala="Millones"),
    _v("gk",             "Gasto de Capital",                "Fiscal",   "mensual", "RD$",     "DGAPF", escala="Millones"),
    _v("res_primario",   "Resultado Primario",              "Fiscal",   "mensual", "RD$",     "DGAPF", escala="Millones"),
    _v("res_global",     "Resultado Global",                "Fiscal",   "mensual", "RD$",     "DGAPF", escala="Millones"),

    # ------- Monetario -------
    _v("bmr_rd",         "Base Monetaria Restringida",      "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("compra_fx_tot",  "Compra total de US$",             "Monetario","mensual", "US$",     "BCRD",  escala="Millones"),
    _v("encaje_me",      "Encaje Excedente ME",             "Monetario","mensual", "US$",     "BCRD",  escala="Millones"),
    _v("encaje_mn",      "Encaje Excedente MN",             "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("m1_rd",          "Medio Circulante (M1)",           "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("pbcred_nc_rd",   "Crédito OSD Sector Público MN",   "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("pvcred_nc_rd",   "Crédito OSD Sector Privado MN",   "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_tot",      "Préstamos OSD a Sector Privado",  "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_agr",      "Préstamos Agricultura",           "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_ind",      "Préstamos Industria",             "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_con",      "Préstamos Construcción",          "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_com",      "Préstamos Comercio",              "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_viv",      "Préstamos Vivienda",              "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_tar",      "Préstamos Tarjetas",              "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("prest_cons",     "Préstamos Consumo",               "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("sm_bcrd_vc",     "Valores en Circulación",          "Monetario","mensual", "RD$",     "BCRD",  escala="Millones"),
    _v("tib_rd",         "Tasa Interbancaria",              "Monetario","mensual", "%",       "BCRD"),
    _v("rin",            "Reservas Internacionales Netas",  "Monetario","mensual", "US$",     "BCRD",  escala="Millones"),

    # ------- Financiero -------
    _v("calact_rd",      "Calidad de Activos",              "Financiero","mensual", "%",      "Superintendencia Bancos"),
    _v("libor_3m",       "LIBOR 3M",                        "Financiero","mensual", "%",      "FRED"),
    _v("liq_rd",         "Liquidez",                        "Financiero","mensual", "%",      "Superintendencia Bancos"),
    _v("tia_prom_pond",  "TIA Promedio Ponderado",          "Financiero","mensual", "%",      "BCRD"),
    _v("tip_prom_pond",  "TIP Promedio Ponderado",          "Financiero","mensual", "%",      "BCRD"),
    _v("tia_90",         "TIA 90 días",                     "Financiero","mensual", "%",      "BCRD"),
    _v("tia_5yr",        "TIA 5 años",                      "Financiero","mensual", "%",      "BCRD"),
]


# ============================================================================
# TRIMESTRALES (data_trimestral + metadata_data_trimestral)
# ============================================================================
TRIMESTRALES: list[dict] = [
    # ------- Real (cuentas nacionales) -------
    _v("defl_pib",   "Deflactor del PIB",                            "Real", "trimestral", "índice",   "BCRD"),
    _v("pib_nom",    "PIB nominal",                                  "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("ct_nom",     "Consumo total nominal",                        "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("cpr_nom",    "Consumo privado nominal",                      "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("cpu_nom",    "Consumo público nominal",                      "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("fbkf_nom",   "FBCF nominal",                                 "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("exp_nom",    "Exportaciones nominal",                        "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("imp_nom",    "Importaciones nominal",                        "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("pib_real",   "PIB real",                                     "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("ct_real",    "Consumo total real",                           "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("cpr_real",   "Consumo privado real",                         "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("cpu_real",   "Consumo público real",                         "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("fbkf_real",  "FBCF real",                                    "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("exp_real",   "Exportaciones real",                           "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("imp_real",   "Importaciones real",                           "Real", "trimestral", "RD$",      "BCRD", escala="Millones"),
    _v("pond_cpr",   "Consumo privado / PIB",                        "Real", "trimestral", "%",        "BCRD",
       tipo="derivada", formula="cpr_nom / pib_nom"),
    _v("pond_cpu",   "Consumo público / PIB",                        "Real", "trimestral", "%",        "BCRD",
       tipo="derivada", formula="cpu_nom / pib_nom"),
    _v("pond_fbkf",  "FBCF / PIB",                                   "Real", "trimestral", "%",        "BCRD",
       tipo="derivada", formula="fbkf_nom / pib_nom"),
    _v("pond_exp",   "Exportaciones / PIB",                          "Real", "trimestral", "%",        "BCRD",
       tipo="derivada", formula="exp_nom / pib_nom"),
    _v("pond_imp",   "Importaciones / PIB",                          "Real", "trimestral", "%",        "BCRD",
       tipo="derivada", formula="imp_nom / pib_nom"),
    _v("pib_eeuu",   "PIB EE.UU.",                                   "Real", "trimestral", "índice",   "FRED"),
    _v("inc_ve",     "Indicador de Confianza Empresarial Venezuela", "Real", "trimestral", "índice",   "BCRD"),
    _v("tia_pp",     "Tasa Activa Promedio Pond. (trim)",            "Financiero","trimestral", "%",   "BCRD"),
    _v("tcn",        "Tipo de cambio nominal (trim)",                "Mercado Cambiario","trimestral", "RD$/US$", "BCRD"),
    # ------- Externo / BoP -------
    _v("cue_cor",    "Cuenta Corriente",                             "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
    _v("bbys",       "Balanza de Bienes y Servicios",                "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
    _v("ing_pri",    "Ingreso Primario",                             "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
    _v("ing_sec",    "Ingreso Secundario",                           "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
    _v("cue_cap",    "Cuenta de Capital",                            "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
    _v("cue_fin",    "Cuenta Financiera",                            "Externo","trimestral", "US$",    "BCRD", escala="Millones"),
]


# ============================================================================
# MÓDULO 8 - SECTOR ELÉCTRICO (no aparece en metadata DGAPF; IDs propios)
# Prefijo `el_` para no chocar con macro.
# ============================================================================
def _ede(prefix: str, nombre: str) -> list[dict]:
    return [
        _v(f"el_{prefix}_pmv",      f"{nombre} - Precio medio venta",        "Eléctrico","mensual","cUSD/kWh","MEM"),
        _v(f"el_{prefix}_pcs",      f"{nombre} - Precio compra SPOT",        "Eléctrico","mensual","cUSD/kWh","MEM"),
        _v(f"el_{prefix}_pcc",      f"{nombre} - Precio compra Contratos",   "Eléctrico","mensual","cUSD/kWh","MEM"),
        _v(f"el_{prefix}_cri",      f"{nombre} - CRI",                       "Eléctrico","mensual","%",       "MEM"),
        _v(f"el_{prefix}_efact",    f"{nombre} - Energía facturada",         "Eléctrico","mensual","GWh",     "MEM"),
        _v(f"el_{prefix}_perdidas", f"{nombre} - Pérdidas",                  "Eléctrico","mensual","%",       "MEM"),
        _v(f"el_{prefix}_cobranzas",f"{nombre} - Cobranzas",                 "Eléctrico","mensual","%",       "MEM"),
    ]


ELECTRICO: list[dict] = [
    # Generación
    _v("el_gen_total",      "Generación total",          "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_carbon",     "Generación carbón",         "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_gas",        "Generación gas natural",    "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_fo2",        "Generación Fuel Oil #2",    "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_fo6",        "Generación Fuel Oil #6",    "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_hidraulica", "Generación hidráulica",     "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_eolica",     "Generación eólica",         "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_solar",      "Generación solar FV",       "Eléctrico", "mensual", "GWh", "MEM"),
    _v("el_gen_biomasa",    "Generación biomasa",        "Eléctrico", "mensual", "GWh", "MEM"),
    # Costos
    _v("el_cmg_energia",    "Costo Marginal de Energía",     "Eléctrico", "mensual", "cUSD/kWh",   "MEM"),
    _v("el_cmg_potencia",   "Costo Marginal de Potencia",    "Eléctrico", "mensual", "cUSD/kW-mes","MEM"),
    _v("el_peaje_trans",    "Peaje Transmisión",             "Eléctrico", "mensual", "cUSD/kWh",   "MEM"),
    # Precios combustibles
    _v("el_p_carbon",       "Precio Carbón Mineral",          "Eléctrico", "mensual", "US$/MMBtu",  "MEM"),
    _v("el_p_gas",          "Precio Gas Natural",             "Eléctrico", "mensual", "US$/MMBtu",  "MEM"),
    _v("el_p_fo2",          "Precio Fuel Oil #2",             "Eléctrico", "mensual", "US$/MMBtu",  "MEM"),
    _v("el_p_fo6",          "Precio Fuel Oil #6",             "Eléctrico", "mensual", "US$/MMBtu",  "MEM"),
    _v("el_tc",             "TC Mensual (MEM)",               "Eléctrico", "mensual", "RD$/US$",    "MEM"),
    # Consolidado distribuidoras + por EDE
    *_ede("dist", "Distribuidoras consolidado"),
    *_ede("edenorte", "Edenorte"),
    *_ede("edesur",   "Edesur"),
    *_ede("edeeste",  "Edeeste"),
    # Balances financieros (anuales)
    _v("el_def_op",      "Balance Operacional",          "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_op_n",    "Edenorte - Balance Operacional","Eléctrico","anual", "US$", "MEM", escala="Millones"),
    _v("el_def_op_s",    "Edesur - Balance Operacional", "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_op_e",    "Edeeste - Balance Operacional","Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_capex",   "Balance con Inversiones",      "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_capex_n", "Edenorte - Balance c/Inv.",    "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_capex_s", "Edesur - Balance c/Inv.",      "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_capex_e", "Edeeste - Balance c/Inv.",     "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_fin",     "Balance luego Financiamiento", "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_fin_n",   "Edenorte - Balance fin.",      "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_fin_s",   "Edesur - Balance fin.",        "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
    _v("el_def_fin_e",   "Edeeste - Balance fin.",       "Eléctrico", "anual", "US$", "MEM", escala="Millones"),
]


# ============================================================================
# PROYECCIONES (proyecciones_ext_*) — Hacienda EO + EIA STEO + SIPEN
# Llenan las hojas `proyecciones_ext_mensuales/trimestrales/anuales`.
# ============================================================================
PROYECCIONES: list[dict] = [
    # EIA STEO (precios y consumo proyectados)
    _v("wti_proy",            "WTI proyectado (EIA STEO)",        "Externo",  "mensual", "US$/barril", "EIA STEO",
       descripcion="Proyección STEO 9atab"),
    _v("brent_proy",          "Brent proyectado (EIA STEO)",      "Externo",  "mensual", "US$/barril", "EIA STEO"),
    _v("gas_proy",            "Henry Hub proyectado (EIA STEO)",  "Externo",  "mensual", "US$/MMBtu",  "EIA STEO"),
    _v("consumo_pet_mundial_proy",
       "Consumo mundial petróleo proyectado",                     "Externo",  "mensual", "Mb/d", "EIA STEO",
       escala="Millones"),
]


# ============================================================================
# Unificadores
# ============================================================================
def todas_variables() -> list[dict]:
    return [*DIARIAS, *MENSUALES, *TRIMESTRALES, *ELECTRICO, *PROYECCIONES]


def filtrar_modulo(modulo: str, catalogo: Iterable[dict] | None = None) -> list[dict]:
    cat = list(catalogo) if catalogo is not None else todas_variables()
    return [v for v in cat if v["modulo"] == modulo]


def filtrar_directas(catalogo: Iterable[dict] | None = None) -> list[dict]:
    """Solo variables que vienen de descargas (no fórmulas).

    Si se pasa ``catalogo`` filtra sobre esa lista (útil cuando se está
    trabajando con el catálogo fusionado Python ∪ Excel); si se omite,
    opera sobre el catálogo Python canónico.
    """
    cat = list(catalogo) if catalogo is not None else todas_variables()
    return [v for v in cat if v.get("tipo", "directa") == "directa"]


def filtrar_derivadas(catalogo: Iterable[dict] | None = None) -> list[dict]:
    """Solo variables calculadas con fórmulas (acepta catálogo opcional)."""
    cat = list(catalogo) if catalogo is not None else todas_variables()
    return [v for v in cat if v.get("tipo") == "derivada"]


def por_id() -> dict[str, dict]:
    """Lookup rápido id -> variable."""
    return {v["id"]: v for v in todas_variables()}


def ids_de(variables: Iterable[dict]) -> list[str]:
    return [v["id"] for v in variables]
