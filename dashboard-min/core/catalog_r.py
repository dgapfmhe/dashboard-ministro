"""Catálogo canónico de variables — alineado 1:1 con los scripts R fuente:

  - `Data_dgapf_gg1.R`  → 11 hojas: data_diaria, data_mensual, data_trimestral,
                          data_bop, data_pii, data_deuda, data_monetario,
                          panorama_monetario, data_eo, data_eo_tri,
                          proyecciones_ext_mensuales / _trimestrales.
  - `data1.R`           → indicadores energéticos (1 archivo, ~60 vars).

Total ~300 variables. Cada entrada incluye:
  id, nombre, modulo, submodulo, frecuencia, unidad, escala, fuente, fuente_url,
  tipo (directa|derivada), formula (si derivada), activo.

NOTA: Los IDs son los que aparecen en el código R (`indicadores$xxx`,
`data_bop$xxx`, etc.). Mantenerlos así garantiza que los parsers Python
puedan poblar las mismas columnas que el Excel original.
"""
from __future__ import annotations

from typing import Iterable


def _v(id_: str, nombre: str, sector: str, frecuencia: str, unidad: str,
       fuente: str, submodulo: str | None = None, escala: str = "Unidad",
       tipo: str = "directa", formula: str | None = None,
       fuente_url: str | None = None, descripcion: str | None = None) -> dict:
    return {
        "id": id_, "nombre": nombre, "modulo": sector, "submodulo": submodulo,
        "frecuencia": frecuencia, "unidad": unidad, "escala": escala,
        "fuente": fuente, "fuente_url": fuente_url, "tipo": tipo,
        "formula": formula, "descripcion": descripcion, "activo": True,
    }


# ============================================================================
# DIARIAS — Data_dgapf_gg1.R `data_diaria`
# ============================================================================
DIARIAS: list[dict] = [
    # Tipo de cambio diario (BCRD: TASA_DOLAR_REFERENCIA_MC.xlsx)
    _v("tcn_compra",      "Tipo de Cambio Compra (diaria)",        "Mercado Cambiario", "diaria", "RD$/US$", "BCRD"),
    _v("tcn_venta",       "Tipo de Cambio Venta (diaria)",          "Mercado Cambiario", "diaria", "RD$/US$", "BCRD"),
    _v("tcn_venta_eur",   "Tipo de Cambio Venta EUR (diaria)",      "Mercado Cambiario", "diaria", "RD$/EUR", "BCRD"),
    _v("tcn_usa_spread",  "Spread Venta - Compra",                  "Mercado Cambiario", "diaria", "RD$/US$", "Derivada",
       tipo="derivada", formula="tcn_venta - tcn_compra"),
    # EMBI diario (BCRD entorno internacional) — múltiples regiones
    _v("embi",            "EMBI RD (legacy alias)",                  "Financiero",       "diaria", "pbs", "BCRD"),
    _v("embi_global",     "EMBI Global",                              "Financiero",       "diaria", "pbs", "BCRD"),
    _v("embi_latam",      "EMBI LATAM",                                "Financiero",       "diaria", "pbs", "BCRD"),
    # Yahoo Finance daily
    _v("p_petroleo_d",    "Petróleo WTI (diario)",                  "Externo",  "diaria", "US$/barril", "Yahoo"),
    _v("p_oro_d",         "Oro (diario)",                            "Externo",  "diaria", "US$/oz",     "Yahoo"),
    _v("p_gas_nat_d",     "Gas Natural (diario)",                    "Externo",  "diaria", "US$/MMBtu",  "Yahoo"),
    _v("carb_aus_d",      "Carbón Australiano (diario)",            "Externo",  "diaria", "US$/ton",    "Yahoo"),
    _v("sp500_d",         "S&P 500 (diario)",                       "Financiero","diaria", "índice",    "Yahoo"),
    _v("dow_jones_d",     "Dow Jones (diario)",                     "Financiero","diaria", "índice",    "Yahoo"),
    _v("vix_d",           "VIX (diario)",                            "Financiero","diaria", "índice",    "Yahoo"),
    _v("dgs10_d",         "Tasa Tesoro EE.UU. 10 años (DGS10)",     "Financiero","diaria", "%",          "FRED"),
    # Depósitos remunerados de corto plazo (diaria, operaciones_monetarias.xlsx)
    _v("deprem_cp",       "Depósitos Remunerados de Corto Plazo (Ventanilla Directa)",
       "Monetario", "diaria", "MM RD$", "BCRD", escala="Millones"),
    # Tasas mercado RD (SIPROMFI tdia_YYYY.xlsx)
    _v("tap_rd",          "Tasa Activa Promedio RD (diaria)",        "Financiero", "diaria", "%", "BCRD"),
    _v("tpp_rd",          "Tasa Pasiva Promedio RD (diaria)",        "Financiero", "diaria", "%", "BCRD"),
    _v("tap_us",          "Tasa Activa Promedio US$ (diaria)",       "Financiero", "diaria", "%", "BCRD"),
    _v("tpp_us",          "Tasa Pasiva Promedio US$ (diaria)",       "Financiero", "diaria", "%", "BCRD"),
]


# ============================================================================
# MENSUALES — Data_dgapf_gg1.R `data_mensual`
# ============================================================================
MENSUALES: list[dict] = [
    # ---- Sector Real ----
    _v("imae",            "IMAE - Indice Mensual de Actividad Económica", "Real", "mensual", "índice", "BCRD"),
    _v("pib_real_imae",   "PIB real mensual interanual (IMAE-based)",       "Real", "mensual", "%",       "BCRD"),

    # ---- Precios (IPC general y subyacente) ----
    _v("inf_rd",          "Inflación interanual RD",                       "Precios", "mensual", "%", "BCRD"),
    _v("inf_sub",         "Inflación subyacente interanual",               "Precios", "mensual", "%", "BCRD"),
    _v("inf_trans",       "Inflación transables",                          "Precios", "mensual", "%", "BCRD"),
    _v("inf_no_trans",    "Inflación no transables",                       "Precios", "mensual", "%", "BCRD"),
    # Inflación por grupos (BCRD ipc_grupos)
    _v("inf_AyBNA",       "Inflación Alimentos y Bebidas No Alcohólicas",  "Precios", "mensual", "%", "BCRD"),
    _v("inf_BAyT",        "Inflación Bebidas Alcohólicas y Tabaco",        "Precios", "mensual", "%", "BCRD"),
    _v("inf_vestir",      "Inflación Vestir y Calzado",                    "Precios", "mensual", "%", "BCRD"),
    _v("inf_viv",         "Inflación Vivienda",                            "Precios", "mensual", "%", "BCRD"),
    _v("inf_mue",         "Inflación Muebles",                             "Precios", "mensual", "%", "BCRD"),
    _v("inf_sal",         "Inflación Salud",                               "Precios", "mensual", "%", "BCRD"),
    _v("inf_transport",   "Inflación Transporte",                          "Precios", "mensual", "%", "BCRD"),
    _v("inf_com",         "Inflación Comunicación",                        "Precios", "mensual", "%", "BCRD"),
    _v("inf_Ryc",         "Inflación Recreación y Cultura",                "Precios", "mensual", "%", "BCRD"),
    _v("inf_edu",         "Inflación Educación",                           "Precios", "mensual", "%", "BCRD"),
    _v("inf_RyH",         "Inflación Restaurantes y Hoteles",              "Precios", "mensual", "%", "BCRD"),
    _v("inf_BySD",        "Inflación Bienes y Servicios Diversos",         "Precios", "mensual", "%", "BCRD"),

    # ---- Expectativas / Confianza ----
    _v("ICI",             "Índice de Confianza al Consumidor",             "Real", "mensual", "índice", "BCRD"),

    # ---- Mercado Cambiario ----
    _v("tcn_compra_m",    "Tipo de Cambio Compra (mensual)",               "Mercado Cambiario", "mensual", "RD$/US$", "BCRD"),
    _v("tcn_venta_m",     "Tipo de Cambio Venta (mensual)",                "Mercado Cambiario", "mensual", "RD$/US$", "BCRD"),
    _v("tcn_eur_m",       "Tipo de Cambio Venta EUR (mensual)",            "Mercado Cambiario", "mensual", "RD$/EUR", "BCRD"),
    _v("tcr_rd",          "Tipo de Cambio Real RD",                        "Mercado Cambiario", "mensual", "índice", "Derivada",
       tipo="derivada", formula="(tcn_venta_m/1.358727436 * ipc_eeuu/218.076*100)/inf_rd"),
    _v("tcn_usa_spread_m","Spread Venta-Compra (mensual)",                 "Mercado Cambiario", "mensual", "RD$/US$", "Derivada",
       tipo="derivada", formula="tcn_venta_m - tcn_compra_m"),

    # ---- Sector Externo ----
    _v("imp_pd_va",       "Importaciones petroleras (valor)",              "Externo", "mensual", "US$", "BCRD", escala="Millones"),
    _v("m_pqoil_rd",      "Importaciones petroleras (cantidad)",           "Externo", "mensual", "MM barriles", "BCRD"),
    _v("rem_fam",         "Remesas familiares",                            "Externo", "mensual", "US$", "BCRD", escala="Millones"),
    _v("se_cc_numtur",    "Llegada de Turistas",                           "Externo", "mensual", "personas", "BCRD"),
    _v("export",          "Exportaciones (DGA)",                           "Externo", "mensual", "US$", "DGA", escala="Millones"),
    # Balanza de Pagos trimestral (BoP)
    _v("viajes_bp",       "Ingresos por Turismo (Viajes, BoP)",            "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ied_bp",          "Inversión Extranjera Directa (entrada neta, BoP)", "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ied_renta_bp",    "Renta de la IED (BoP)",                          "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ingr_prim_bp",    "Ingreso Primario (BoP)",                         "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ingr_sec_bp",     "Ingreso Secundario / Transferencias (BoP)",      "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("rem_fam_bp_cred", "Remesas Familiares (crédito, BoP)",              "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("rem_fam_bp_deb",  "Remesas Familiares (débito, BoP)",               "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("x_bp",            "Exportaciones bienes (BoP)",                     "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("m_bp",            "Importaciones bienes (BoP)",                     "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("cta_cap_bp",      "Cuenta de Capital (BoP)",                         "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("cta_fin_bp",      "Cuenta Financiera (BoP)",                         "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("inv_cart_bp",     "Inversión de Cartera (BoP)",                     "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("act_res_bp",      "Activos de Reservas (cambio, BoP)",              "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    # Nuevas vars BoP para que la tabla Fuentes y Usos balancee
    _v("saldo_cc_bp",     "Saldo Cuenta Corriente (BoP)",                    "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("bal_bys_bp",      "Balanza de Bienes y Servicios (BoP)",             "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("bal_bienes_bp",   "Balanza de Bienes (X−M, BoP)",                   "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("bal_serv_bp",     "Balanza de Servicios (BoP)",                      "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("serv_cred_bp",    "Servicios crédito BoP (Viajes+Manuf+Otros)",      "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("serv_deb_bp",     "Servicios débito BoP (Fletes+Otros)",             "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("renta_inv_bp",    "Renta de la Inversión neta (BoP)",                "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ingr_sec_cred_bp","Ingreso Secundario crédito (BoP)",                "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("ingr_sec_deb_bp", "Ingreso Secundario débito (BoP)",                 "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    _v("eyo_bp",          "Errores y Omisiones (BoP)",                       "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop"),
    # OSD: Otras Sociedades de Depósitos
    _v("aen_osd_act",     "Activos Externos OSD",                            "Monetario", "mensual", "US$", "BCRD", escala="Millones", submodulo="osd"),
    _v("aen_osd_pas",     "Pasivos Externos OSD",                            "Monetario", "mensual", "US$", "BCRD", escala="Millones", submodulo="osd"),
    _v("aen_osd",         "Activos Externos Netos OSD",                      "Monetario", "mensual", "US$", "Derivada", escala="Millones", submodulo="osd",
       tipo="derivada", formula="aen_osd_act - aen_osd_pas"),
    _v("prest_tot_osd",   "Préstamos totales OSD (RD$)",                     "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("prest_mn_osd",    "Préstamos en Moneda Nacional OSD",                "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("prest_me_usd_osd","Préstamos en Moneda Extranjera (USD)",            "Financiero", "mensual", "US$", "BCRD", escala="Millones", submodulo="osd"),
    _v("prest_sp_tot_osd","Préstamos Sector Público OSD",                    "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("prest_spr_tot_osd","Préstamos Sector Privado OSD",                   "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("dep_tot_osd",     "Depósitos totales OSD",                            "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("dep_sp_osd",      "Depósitos del Gobierno en Sistema Financiero",    "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("dep_spr_osd",     "Depósitos Sector Privado OSD",                    "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="osd"),
    _v("tc_fin_mes_osd",  "TC fin de mes (OSD)",                              "Mercado Cambiario", "mensual", "RD$/US$", "BCRD", submodulo="osd"),
    _v("import",          "Importaciones (DGA)",                           "Externo", "mensual", "US$", "DGA", escala="Millones"),
    _v("rin",             "Reservas Internacionales Netas",                "Externo", "mensual", "US$", "BCRD", escala="Millones"),
    _v("embi_rd",         "EMBI RD (diaria)",                              "Financiero", "diaria", "pbs", "BCRD"),

    # ---- Sector Monetario ----
    _v("bmr_rd",          "Base Monetaria Restringida",                    "Monetario", "mensual", "RD$", "BCRD", escala="Millones"),
    _v("M1",              "Medio Circulante M1",                           "Monetario", "mensual", "RD$", "BCRD", escala="Millones"),
    _v("M2",              "Medio Circulante M2",                           "Monetario", "mensual", "RD$", "BCRD", escala="Millones"),
    _v("M3",              "Medio Circulante M3",                           "Monetario", "mensual", "RD$", "BCRD", escala="Millones"),
    _v("encajemn_d_q",    "Encaje legal MN (disponible vs requerido)",    "Monetario", "mensual", "%", "BCRD"),
    _v("encajeme_d_q",    "Encaje legal ME (disponible vs requerido)",    "Monetario", "mensual", "%", "BCRD"),
    _v("compra_fx_tot",   "Compra total US$ (Operaciones)",               "Mercado Cambiario", "mensual", "US$", "BCRD", escala="Millones"),
    _v("sm_bcrd_vc",      "Valores en circulación BCRD",                  "Monetario", "mensual", "RD$", "BCRD", escala="Millones"),

    # ---- Crédito sectorial (BCRD prestamos_por_destino_armonizados) ----
    _v("prest_tot",       "Préstamos al Sector Privado (consolidado)",    "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_agr",       "Préstamos Agricultura, Silvicultura y Pesca", "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_ind",       "Préstamos Industrias Manufactureras",          "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_con",       "Préstamos Construcción",                       "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_com",       "Préstamos Comercio",                           "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_viv",       "Préstamos Adquisición de Viviendas",           "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_cons",      "Préstamos de Consumo",                         "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("prest_tar",       "Préstamos Tarjetas de Crédito",                "Financiero", "mensual", "RD$", "BCRD", escala="Millones", submodulo="credito"),
    _v("pvcred_nc_rd",    "Crédito Sector Privado M/N",                   "Financiero", "mensual", "RD$", "BCRD", escala="Millones"),
    _v("pbcred_nc_rd",    "Crédito Sector Público M/N",                   "Financiero", "mensual", "RD$", "BCRD", escala="Millones"),

    # ---- Tasas de interés mensual ----
    _v("tia_prom_pond_rd","Tasa Interés Activa Promedio Ponderada",       "Financiero", "mensual", "%", "BCRD"),
    _v("tip_prom_pond",   "Tasa Interés Pasiva Promedio Ponderada",       "Financiero", "mensual", "%", "BCRD"),
    _v("tia_90",          "Tasa Activa 0-90 días",                        "Financiero", "mensual", "%", "BCRD"),
    _v("tia_5yr",         "Tasa Activa 2-5 años",                         "Financiero", "mensual", "%", "BCRD"),
    _v("tib_rd",          "Tasa Interbancaria RD",                        "Financiero", "mensual", "%", "BCRD"),
    _v("tpm",             "Tasa de Política Monetaria",                   "Monetario", "mensual", "%", "BCRD"),
    _v("DEPOS",           "Tasa de depósito de facilidad permanente",     "Monetario", "mensual", "%", "BCRD"),
    _v("REPOS",           "Tasa Repos overnight",                         "Monetario", "mensual", "%", "BCRD"),
    _v("vol_tip",         "Volatilidad tasa pasiva (* 2.33)",            "Financiero", "mensual", "%", "BCRD"),
    _v("sd_tip",          "Desv. típica tasa pasiva",                     "Financiero", "mensual", "%", "BCRD"),

    # ---- Externos (FRED / Yahoo / WB monthly) ----
    _v("p_petroleo",      "Petróleo WTI (mensual, WB)",                  "Externo",   "mensual", "US$/barril", "BancoMundial"),
    _v("p_gas_nat",       "Gas Natural (mensual, WB)",                   "Externo",   "mensual", "US$/MMBtu",  "BancoMundial"),
    _v("p_oro",           "Oro (mensual, WB)",                            "Externo",   "mensual", "US$/oz",     "BancoMundial"),
    _v("ind_p_AyB",       "Índice precios Alimentos y Bebidas (WB)",     "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("ener_ind",        "Índice precios Energía (WB)",                  "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("non_ener_ind",    "Índice precios No Energía (WB)",              "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("food_ind",        "Índice precios Alimentos (WB)",                "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("metals_ind",      "Índice precios Metales (WB)",                  "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("prec_metal_ind",  "Índice precios Metales Preciosos (WB)",       "Externo",   "mensual", "índice",     "BancoMundial"),
    _v("vix",             "VIX (mensual)",                                "Financiero","mensual", "índice",     "Yahoo"),
    _v("bolsa_DowJones",  "Dow Jones (mensual)",                          "Financiero","mensual", "índice",     "Yahoo"),
    _v("ipc_eeuu",        "IPC EE.UU. (CPIAUCSL)",                        "Externo",   "mensual", "índice",     "FRED"),
    _v("indpro_usa",      "Producción Industrial EE.UU. (INDPRO)",       "Externo",   "mensual", "índice",     "FRED"),
    _v("indproMan_usa",   "Producción Industrial Manufactura EE.UU.",   "Externo",   "mensual", "índice",     "FRED"),
    _v("epu_eeuu",        "Índice de Incertidumbre Política EE.UU.",     "Externo",   "mensual", "índice",     "FRED"),
    _v("epu_global",      "Índice de Incertidumbre Política Global",     "Externo",   "mensual", "índice",     "FRED"),
    _v("ti_fond_fed",     "Fed Funds Rate",                                "Externo",   "mensual", "%",          "FRED"),
    _v("ur_usa",          "Desempleo EE.UU. (no ajust.)",                 "Externo",   "mensual", "%",          "FRED"),
    _v("ur_sa_usa",       "Desempleo EE.UU. (ajustado)",                 "Externo",   "mensual", "%",          "FRED"),

    # ---- DGII / Fiscal ----
    _v("ing_trib",        "Ingresos Tributarios (Hacienda EO)",          "Fiscal", "mensual", "RD$", "Hacienda", escala="Millones"),
    _v("gk",               "Gasto de Capital (Hacienda EO)",              "Fiscal", "mensual", "RD$", "Hacienda", escala="Millones"),
    _v("ventas_dgii_rd",  "Ventas Totales DGII (ITBIS)",                  "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_const",    "Ventas DGII - Construcción",                   "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_mineria",  "Ventas DGII - Minería",                        "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_manuf",    "Ventas DGII - Manufactura",                    "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_comercio", "Ventas DGII - Comercio",                       "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_hoteles",  "Ventas DGII - Hoteles, Bares, Restaurantes",   "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_transp",   "Ventas DGII - Transporte",                     "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("ventas_otros",    "Ventas DGII - Otros (residual)",               "Fiscal", "mensual", "RD$", "Derivada", escala="Millones",
       tipo="derivada", formula="ventas_dgii_rd - (ventas_const+ventas_mineria+ventas_manuf+ventas_comercio+ventas_hoteles+ventas_transp)"),
    _v("Hidro_av",        "Recaudo Hidrocarburos Ad Valorem",             "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("Hidro_esp",       "Recaudo Hidrocarburos Específico",             "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("itbis_ret_ca",    "Retención ITBIS Comprobantes (CA)",            "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),
    _v("imp_cheq",        "Impuesto al Cheque",                            "Fiscal", "mensual", "RD$", "DGII", escala="Millones"),

    # ---- SIPEN ----
    _v("salario",         "Salario promedio (SIPEN)",                     "Real", "mensual", "RD$", "SIPEN"),
    _v("cot_tss",         "Cotizantes al SDSS",                            "Real", "mensual", "personas", "SIPEN"),
]


# ============================================================================
# TRIMESTRALES — Data_dgapf_gg1.R `data_trimestral`
# ============================================================================
TRIMESTRALES: list[dict] = [
    # PIB desde el gasto - Nominal
    _v("pib_nom",         "PIB Nominal",                                   "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("ct_nom",          "Consumo Total Nominal",                          "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("cpr_nom",         "Consumo Privado Nominal",                        "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("cpu_nom",         "Consumo Público Nominal",                        "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("fbkt",            "Formación Bruta Capital Total (legacy)",         "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("fbkt_nom",        "FBK Total Nominal",                              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("ve_nom",          "Variación Existencias Nominal",                  "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("fbkf_nom",        "FBKF Nominal",                                   "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("ve",              "Variación de Existencias",                       "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("exp_nom",         "Exportaciones Nominal",                          "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("imp_nom",         "Importaciones Nominal",                          "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    # PIB desde el gasto - Real (precios constantes 2018)
    _v("ct_real",         "Consumo Total Real",                              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("cpr_real",        "Consumo Privado Real",                            "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("cpu_real",        "Consumo Público Real",                            "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("fbkt_real",       "FBK Total Real",                                  "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("fbkf_real",       "FBKF Real",                                       "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("ve_real",         "Variación Existencias Real",                       "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("exp_real",        "Exportaciones Real",                              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("imp_real",        "Importaciones Real",                              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("pib_real",        "PIB Real (precios constantes 2018)",              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("pib_real_trim",   "PIB Real (alias)",                                 "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("defl_pib",        "Deflactor del PIB",                                "Real", "trimestral", "índice", "BCRD"),
    # PIB acumulado nominal y real (Q1=Q1, Q2=Q1+Q2, Q3=Q1+Q2+Q3, Q4=anual)
    _v("ct_nom_acum",     "Consumo Total Nominal (acumulado)",                "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("cpr_nom_acum",    "Consumo Privado Nominal (acumulado)",              "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("cpu_nom_acum",    "Consumo Público Nominal (acumulado)",              "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("fbkt_nom_acum",   "FBK Total Nominal (acumulado)",                    "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("fbkf_nom_acum",   "FBKF Nominal (acumulado)",                         "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("ve_nom_acum",     "Variación Existencias (acumulado)",                "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("exp_nom_acum",    "Exportaciones Nominal (acumulado)",                "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("imp_nom_acum",    "Importaciones Nominal (acumulado)",                "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("pib_nom_acum",    "PIB Nominal (acumulado, Q4=anual)",               "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("ct_real_acum",    "Consumo Total Real (acumulado)",                   "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("cpr_real_acum",   "Consumo Privado Real (acumulado)",                 "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("cpu_real_acum",   "Consumo Público Real (acumulado)",                 "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("fbkt_real_acum",  "FBK Total Real (acumulado)",                       "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("fbkf_real_acum",  "FBKF Real (acumulado)",                            "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("exp_real_acum",   "Exportaciones Real (acumulado)",                   "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("imp_real_acum",   "Importaciones Real (acumulado)",                   "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    _v("pib_real_acum",   "PIB Real (acumulado, Q4=anual)",                  "Real", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="acumulado"),
    # Incidencias
    _v("inc_con",         "Incidencia Consumo en PIB",                       "Real", "trimestral", "pp", "BCRD"),
    _v("inc_fbkf",        "Incidencia FBKF en PIB",                          "Real", "trimestral", "pp", "BCRD"),
    _v("inc_exp",         "Incidencia Exportaciones en PIB",                 "Real", "trimestral", "pp", "BCRD"),
    _v("inc_imp",         "Incidencia Importaciones en PIB",                 "Real", "trimestral", "pp", "BCRD"),
    # Ponderaciones
    _v("pond_cpr",        "Ponderación Consumo Privado",                     "Real", "trimestral", "%", "BCRD"),
    _v("pond_cpu",        "Ponderación Consumo Público",                     "Real", "trimestral", "%", "BCRD"),
    _v("pond_fbkf",       "Ponderación FBKF",                                 "Real", "trimestral", "%", "BCRD"),
    _v("pond_exp",        "Ponderación Exportaciones",                       "Real", "trimestral", "%", "BCRD"),
    _v("pond_imp",        "Ponderación Importaciones",                       "Real", "trimestral", "%", "BCRD"),
    # PIB origen
    _v("inc_agr",         "Incidencia Agropecuario en PIB",                  "Real", "trimestral", "pp", "BCRD"),
    _v("inc_ind",         "Incidencia Industria en PIB",                     "Real", "trimestral", "pp", "BCRD"),
    _v("inc_ser",         "Incidencia Servicios en PIB",                     "Real", "trimestral", "pp", "BCRD"),
    _v("agro_real",       "PIB Agropecuario Real",                           "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("minas_real",      "PIB Minería Real",                                 "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("manzf_real",      "PIB Manufactura Zonas Francas Real",              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("cons_real",       "PIB Construcción Real",                           "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("serv_real",       "PIB Servicios Real",                              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("com_real",        "PIB Comercio Real",                               "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("HByR_real",       "PIB Hoteles, Bares y Restaurantes Real",          "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("trans_real",      "PIB Transporte Real",                             "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("intfin_real",     "PIB Intermediación Financiera Real",              "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("viv_real",        "PIB Vivienda Real",                               "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("otros_real",      "PIB Otros sectores Real",                         "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    _v("adminpub_real",   "PIB Administración Pública Real",                 "Real", "trimestral", "RD$", "BCRD", escala="Millones"),
    # Mercado laboral (ENFT empalmada)
    _v("l_enftc_empalmado",    "Ocupados (ENFT empalmada)",                  "Real", "trimestral", "personas", "BCRD"),
    _v("wnom_enftc_empalmado", "Ingreso laboral nominal/hora (ENFT)",        "Real", "trimestral", "RD$", "BCRD"),
    _v("hrs_enftc_empalmado",  "Horas trabajadas (ENFT)",                    "Real", "trimestral", "horas", "BCRD"),
    # Externos trimestrales (FRED + WB agregados)
    _v("pib_eeuu",        "PIB EE.UU. real (GDPC1)",                         "Externo", "trimestral", "US$", "FRED", escala="Miles de millones"),
]


# ============================================================================
# BALANZA DE PAGOS — Data_dgapf_gg1.R `data_bop` (trimestral)
# ============================================================================
BOP: list[dict] = [
    _v(_id, _nom, "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="bop")
    for _id, _nom in [
        ("x_ncnl",         "Exportaciones nacionales"),
        ("x_zf",           "Exportaciones zonas francas"),
        ("m_ncnl",         "Importaciones nacionales"),
        ("m_zf",           "Importaciones zonas francas"),
        ("viajes",         "Servicios - Viajes"),
        ("serv_mifpt",     "Servicios - Manufactura int. e info., telecomunicaciones"),
        ("otros_serv_cred","Otros servicios (crédito)"),
        ("fletes",         "Servicios - Fletes"),
        ("otros_serv_deb", "Otros servicios (débito)"),
        ("remu_empl",      "Remuneración empleados"),
        ("ied",            "Inversión extranjera directa"),
        ("idc",            "Inversión directa cartera"),
        ("otra_i",         "Otra inversión"),
        ("adr",            "Activos de reserva (cambio)"),
        ("rem_fam_cred",   "Remesas familiares (crédito)"),
        ("otras_transf_cred","Otras transferencias (crédito)"),
        ("rem_fam_deb",    "Remesas familiares (débito)"),
        ("otras_transf_deb","Otras transferencias (débito)"),
        ("cuenta_cap",     "Cuenta de capital"),
        ("id",             "Inversión directa"),
        ("inv_cart",       "Inversión de cartera"),
        ("dpp_mlp",        "Deuda pasiva pública MLP"),
        ("dpp_cp",         "Deuda pasiva pública CP"),
        ("myd",            "Moneda y depósitos"),
        ("otros_cf",       "Otros capital financiero"),
        ("saldo",          "Saldo balanza de pagos"),
        ("eyo",            "Errores y omisiones"),
        ("adr_financ",     "ADR financieros"),
        ("u_cpfmi",        "Uso crédito FMI"),
        ("transf_financ",  "Transferencias financieras"),
        ("otra_inv_pas",   "Otra inversión pasivos"),
    ]
]


# ============================================================================
# POSICIÓN INVERSIÓN INTERNACIONAL — Data_dgapf_gg1.R `data_pii` (trimestral)
# ============================================================================
PII: list[dict] = [
    _v(_id, _nom, "Externo", "trimestral", "US$", "BCRD", escala="Millones", submodulo="pii")
    for _id, _nom in [
        # Activos
        ("a_pc_ide", "Activos PC IDE"), ("a_pc_eid", "Activos PC EID"), ("a_pc_eee", "Activos PC EEE"),
        ("a_inst_ide", "Activos Instituciones IDE"), ("a_inst_eid", "Activos Instituciones EID"), ("a_inst_eee", "Activos Instituciones EEE"),
        ("a_bc_pcf", "Activos BC PCF"), ("a_sd_pcf", "Activos SD PCF"), ("a_gg_pcf", "Activos GG PCF"),
        ("a_osf_pcf", "Activos OSF PCF"), ("a_snfhsfl_pcf", "Activos SNFHSFL PCF"),
        ("a_bc_td", "Activos BC TD"), ("a_sd_td", "Activos SD TD"), ("a_gg_td", "Activos GG TD"),
        ("a_osf_td", "Activos OSF TD"), ("a_snfhsfl_td", "Activos SNFHSFL TD"),
        ("a_dfoc", "Activos DFOC"), ("a_opc", "Activos OPC"),
        ("a_bc_md", "Activos BC MD"), ("a_sd_md", "Activos SD MD"), ("a_gg_md", "Activos GG MD"),
        ("a_osf_md", "Activos OSF MD"), ("a_snfhsfl_md", "Activos SNFHSFL MD"),
        ("a_bc_pms", "Activos BC PMS"), ("a_sd_pms", "Activos SD PMS"), ("a_gg_pms", "Activos GG PMS"),
        ("a_osf_pms", "Activos OSF PMS"), ("a_snfhsfl_pms", "Activos SNFHSFL PMS"),
        ("a_segpen", "Activos Seguros y Pensiones"),
        ("a_bc_cac", "Activos BC CAC"), ("a_sd_cac", "Activos SD CAC"), ("a_gg_cac", "Activos GG CAC"),
        ("a_osf_cac", "Activos OSF CAC"), ("a_snfhsfl_cac", "Activos SNFHSFL CAC"),
        ("a_bc_ocpc", "Activos BC OCPC"), ("a_sd_ocpc", "Activos SD OCPC"), ("a_gg_ocpc", "Activos GG OCPC"),
        ("a_osf_ocpc", "Activos OSF OCPC"), ("a_snfhsfl_ocpc", "Activos SNFHSFL OCPC"),
        ("a_lingoro", "Activos Lingotes de Oro"),
        ("a_coro_nasg", "Activos Otros Oro NASG"),
        ("a_dereg", "Activos DEG"),
        ("a_pres_fmi", "Activos Préstamos FMI"),
        ("a_deraam", "Activos DERAAM"), ("a_deraoe", "Activos DERAOE"),
        ("a_td_tv", "Activos TD TV"), ("a_pcf_tv", "Activos PCF TV"),
        ("a_drvfin", "Activos Derivados Financieros"),
        ("a_oda", "Activos ODA"),
        # Pasivos
        ("p_pc_ide", "Pasivos PC IDE"), ("p_pc_eid", "Pasivos PC EID"), ("p_pc_eee", "Pasivos PC EEE"),
        ("p_inst_ide", "Pasivos Instituciones IDE"), ("p_inst_eid", "Pasivos Instituciones EID"), ("p_inst_eee", "Pasivos Instituciones EEE"),
        ("p_bc_pcf", "Pasivos BC PCF"), ("p_sd_pcf", "Pasivos SD PCF"), ("p_gg_pcf", "Pasivos GG PCF"),
        ("p_osf_pcf", "Pasivos OSF PCF"), ("p_snfhsfl_pcf", "Pasivos SNFHSFL PCF"),
        ("p_bc_td", "Pasivos BC TD"), ("p_sd_td", "Pasivos SD TD"), ("p_gg_td", "Pasivos GG TD"),
        ("p_osf_td", "Pasivos OSF TD"), ("p_snfhsfl_td", "Pasivos SNFHSFL TD"),
        ("p_dfoc", "Pasivos DFOC"), ("p_opc", "Pasivos OPC"),
        ("p_bc_md", "Pasivos BC MD"), ("p_sd_md", "Pasivos SD MD"), ("p_gg_md", "Pasivos GG MD"),
        ("p_osf_md", "Pasivos OSF MD"), ("p_snfhsfl_md", "Pasivos SNFHSFL MD"),
        ("p_bc_pms", "Pasivos BC PMS"), ("p_sd_pms", "Pasivos SD PMS"), ("p_gg_pms", "Pasivos GG PMS"),
        ("p_osf_pms", "Pasivos OSF PMS"), ("p_snfhsfl_pms", "Pasivos SNFHSFL PMS"),
        ("p_segpen", "Pasivos Seguros y Pensiones"),
        ("p_bc_cac", "Pasivos BC CAC"), ("p_sd_cac", "Pasivos SD CAC"), ("p_gg_cac", "Pasivos GG CAC"),
        ("p_osf_cac", "Pasivos OSF CAC"), ("p_snfhsfl_cac", "Pasivos SNFHSFL CAC"),
        ("p_bc_ocpc", "Pasivos BC OCPC"), ("p_sd_ocpc", "Pasivos SD OCPC"), ("p_gg_ocpc", "Pasivos GG OCPC"),
        ("p_osf_ocpc", "Pasivos OSF OCPC"), ("p_snfhsfl_ocpc", "Pasivos SNFHSFL OCPC"),
        ("p_dereg", "Pasivos DEG"),
        ("p_pii", "PII NETA"),
    ]
]


# ============================================================================
# DEUDA PÚBLICA CONSOLIDADA — `data_deuda` (trimestral)
# ============================================================================
DEUDA: list[dict] = [
    _v(_id, _nom, "Fiscal", "trimestral", "US$", "DGAPF", escala="Millones", submodulo="deuda",
       fuente_url="https://www.creditopublico.gob.do/Content/estadisticas/consolidada/trimestral/04Deuda Pública Consolidada por Sector Institucional Trimestral.xlsx")
    for _id, _nom in [
        ("dpc_ext",       "Deuda Pública Consolidada Externa"),
        ("dpc_int",       "Deuda Pública Consolidada Interna"),
        ("d_ext_spnf_gc", "Deuda Ext. SPNF Gobierno Central"),
        ("d_int_spnf_gc", "Deuda Int. SPNF Gobierno Central"),
        ("d_ext_spnf_r",  "Deuda Ext. SPNF Resto"),
        ("d_int_spnf_r",  "Deuda Int. SPNF Resto"),
        ("d_ext_spf",     "Deuda Ext. Sector Público Financiero"),
        ("d_int_spf",     "Deuda Int. Sector Público Financiero"),
    ]
]


# ============================================================================
# ESTADO DE OPERACIONES — `data_eo` (mensual)
# ============================================================================
EO: list[dict] = [
    _v(_id, _nom, "Fiscal", "mensual", "RD$", "Hacienda", escala="Millones", submodulo="eo",
       fuente_url="https://www.hacienda.gob.do/estadisticas-fiscales/")
    for _id, _nom in [
        # Ingresos
        ("isr_pf",  "ISR Personas Físicas"),
        ("isr_se",  "ISR Sociedades y otras empresas"),
        ("isp",     "Impuestos sobre la propiedad"),
        ("iva",     "ITBIS (impuestos al valor agregado)"),
        ("ist_fc",  "Impuestos sobre transacciones financieras y de capital"),
        ("i_sel",   "Impuestos selectivos"),
        ("isse",    "Impuestos sobre servicios específicos"),
        ("isb",     "Impuestos sobre uso de bienes y permisos"),
        ("isct",    "Impuestos sobre comercio y transacciones internacionales"),
        ("otros_imp","Otros impuestos"),
        ("cs_ing",  "Contribuciones sociales (ingreso)"),
        ("don",     "Donaciones (ingreso)"),
        ("otros_ing","Otros ingresos"),
        # Gastos corrientes
        ("ss",      "Sueldos y salarios"),
        ("cs_gasto","Contribuciones sociales (gasto)"),
        ("u_bys",   "Uso de bienes y servicios"),
        ("inter_nr","Intereses a no residentes"),
        ("inter_r", "Intereses a residentes"),
        ("subs_sp", "Subsidios a sociedades públicas"),
        ("subs_ep", "Subsidios a empresas privadas"),
        ("don_ge",  "Donaciones a gobiernos extranjeros"),
        ("don_ogint","Donaciones a organismos internacionales"),
        ("don_gg_corr","Donaciones GG corrientes"),
        ("don_gg_cap","Donaciones GG capital"),
        ("prest_soc","Prestaciones sociales"),
        ("transf_corr_ncop","Transferencias corrientes no clasificadas"),
        ("transf_cap_ncop","Transferencias de capital no clasificadas"),
        # Gastos de capital / activos no financieros
        ("act_f",   "Activos fijos"),
        ("obj_val", "Objetos de valor"),
        ("act_np",  "Activos no producidos"),
        # Financiamiento (adquisición activos financieros)
        ("din_ld",  "Dinero legal y depósitos"),
        ("part_cap_di","Participaciones de capital y FDI"),
        ("otras_cpc","Otras cuentas por cobrar"),
        ("emis_ai", "Emisiones (activos internos)"),
        ("amort_ai","Amortizaciones (activos internos)"),
        ("resto_ai","Resto activos internos"),
        ("loan_sb_ai","Préstamos sector bancario AI"),
        ("loan_snb_ai","Préstamos sector no bancario AI"),
        ("otros_pas_ai","Otros pasivos AI"),
        ("emis_ae", "Emisiones (activos externos)"),
        ("amort_ae","Amortizaciones (activos externos)"),
        ("resto_ae","Resto activos externos"),
        ("desemb_loan_ae","Desembolsos préstamos AE"),
        ("amort_loan_ae","Amortizaciones préstamos AE"),
        ("resto_loan_ae","Resto préstamos AE"),
        # Resto SPNF
        ("din_ld_rspnf","Dinero legal y depósitos RSPNF"),
        ("tdd_rspnf","Títulos de deuda RSPNF"),
        ("cpc_rspnf","Cuentas por cobrar RSPNF"),
        ("de_rspnf","Deudores externos RSPNF"),
        ("pas_tdd_ai","Pasivos títulos de deuda AI"),
        ("loan_rspnf","Préstamos RSPNF"),
        ("otros_pas_rspnf","Otros pasivos RSPNF"),
        ("ae_rspnf","Acreedores externos RSPNF"),
    ]
]


# ============================================================================
# DATA MONETARIO TRIMESTRAL — `data_monetario`
# ============================================================================
MONETARIO_T: list[dict] = [
    _v(_id, _nom, "Monetario", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="monetario_t")
    for _id, _nom in [
        ("a_in_b", "Activos internos brutos"),
        ("rib", "Reservas Internacionales Brutas"),
        ("rin_t", "Reservas Internacionales Netas (trim.)"),
        ("a_fgc", "Activos frente al GC"),
        ("a_fsp", "Activos frente al SP"),
        ("cred_osd", "Crédito a OSD"),
        ("val_circ", "Valores en circulación"),
        ("desc_vem", "Descuento de valores emitidos por BCRD"),
        ("deprem_cp_q", "Depósitos remunerados CP (trim.)"),
        ("bm_em_bmr", "Base monetaria emisión BMR"),
        ("el_sc_osd_bmr", "El sector consolidado OSD - BMR"),
        ("valbc_pososd_bmr", "Valores BCRD posición OSD BMR"),
        ("bmr", "Base Monetaria Restringida"),
        ("el_sc_osd_bma", "Sector consolidado OSD - BMA"),
        ("deprem_cp_me", "Depósitos remunerados CP - ME"),
        ("ovn", "Overnight"),
        ("od_osd_bc", "Operaciones de descuento OSD - BC"),
        ("valcp_embc_osd", "Valores CP emitidos BCRD - OSD"),
        ("bm_pp", "Base monetaria papel privado"),
        ("dt_mn", "Depósitos transferibles MN"),
        ("m1", "M1 (trim.)"),
        ("od_mn", "Otros depósitos MN"),
        ("valda_mn_emosd", "Valores DA MN emitidos OSD"),
        ("valda_mn_embc", "Valores DA MN emitidos BCRD"),
        ("m2", "M2 (trim.)"),
        ("od_me", "Otros depósitos ME"),
        ("valda_me", "Valores DA ME"),
        ("k2_1", "K2 - clase 1"),
        ("k2_2", "K2 - clase 2"),
        ("k2_3", "K2 - clase 3"),
        ("tc_t", "Tipo de cambio (trim.)"),
    ]
]


# ============================================================================
# PANORAMA MONETARIO — `panorama_monetario` (trimestral)
# ============================================================================
PANORAMA_M: list[dict] = [
    _v(_id, _nom, "Monetario", "trimestral", "RD$", "BCRD", escala="Millones", submodulo="panorama")
    for _id, _nom in [
        # Banco Central
        ("ae_ronr_bc", "AE-RONR Banco Central"),
        ("ae_onr_bc",  "AE-ONR Banco Central"),
        ("p_cp_nr",    "Pasivos CP NR"),
        ("p_lp_nr",    "Pasivos LP NR"),
        ("rin_pm",     "RIN (Panorama monetario)"),
        ("ai_gc_bc",   "Activos internos GC - BC"),
        ("ai_snf_bc",  "Activos internos SNF - BC"),
        ("ai_osd_bc",  "Activos internos OSD - BC"),
        ("ai_os_bc",   "Activos internos OS - BC"),
        ("ai_op_bc",   "Activos internos OP - BC"),
        ("bm_circ",    "Base monetaria circulante"),
        ("dvp",        "Depósitos VP"),
        ("tc",         "Tipo de cambio panorama"),
        # OSD
        ("ae_nr_osd",  "AE-NR OSD"),
        ("p_nr_osd",   "Pasivos NR OSD"),
        ("ai_gc_osd",  "Activos internos GC - OSD"),
        ("ai_gel_osd", "Activos internos GEL - OSD"),
        ("ai_snf_osd", "Activos internos SNF - OSD"),
        ("ai_bcbm_osd","Activos internos BCBM - OSD"),
        ("ai_bcd_osd", "Activos internos BCD - OSD"),
        ("ai_bcv_osd", "Activos internos BCV - OSD"),
        ("ai_osf_osd", "Activos internos OSF - OSD"),
        ("ai_osnf_osd","Activos internos OSNF - OSD"),
        ("ai_hsfl_osd","Activos internos HSFL - OSD"),
        ("ai_op_osd",  "Activos internos OP - OSD"),
        ("p_dsa_dt_osd","Pasivos DSA-DT OSD"),
        ("p_dsa_odv_osd","Pasivos DSA-ODV OSD"),
        # Crédito SPNF
        ("a_vda_gc",   "Activos valores deuda GC"),
        ("a_vda_gel",  "Activos valores deuda GEL"),
        ("a_vda_snf",  "Activos valores deuda SNF"),
        ("a_prm_gc",   "Activos préstamos GC"),
        ("a_prm_gel",  "Activos préstamos GEL"),
        ("a_prm_snf",  "Activos préstamos SNF"),
        ("a_o",        "Otros activos"),
        ("p_dto_gc",   "Pasivos depósitos GC"),
        ("p_dto_gel",  "Pasivos depósitos GEL"),
        ("p_dto_snf",  "Pasivos depósitos SNF"),
        ("p_vto_gc",   "Pasivos valores GC"),
        ("p_vto_gel",  "Pasivos valores GEL"),
        ("p_vto_snf",  "Pasivos valores SNF"),
        ("p_o",        "Otros pasivos"),
    ]
]


# ============================================================================
# PROYECCIONES EXTERNAS — `proyecciones_ext_mensuales` (EIA STEO + WB)
# ============================================================================
PROY_M: list[dict] = [
    _v(_id, _nom, "Externo", "mensual", "índice", "EIA STEO", submodulo="proyeccion", tipo="directa")
    for _id, _nom in [
        ("indpro_usa_f",    "Pron. Producción Industrial EE.UU."),
        ("indproMan_usa_f", "Pron. Producción Industrial Manufactura EE.UU."),
        ("ipc_eeuu_f",      "Pron. IPC EE.UU."),
        ("ur_sa_usa_f",     "Pron. Desempleo EE.UU."),
        ("p_petroleo_f",    "Pron. Petróleo WTI"),
        ("p_gas_nat_f",     "Pron. Gas Natural"),
    ]
]
PROY_T: list[dict] = [
    _v("pib_eeuu_f", "Pron. PIB EE.UU.", "Externo", "trimestral", "US$", "EIA STEO",
       submodulo="proyeccion", escala="Miles de millones"),
]


# ============================================================================
# SECTOR ELÉCTRICO — data1.R (mensual + anual)
# ============================================================================
def _el(id_, nombre, freq="mensual", unidad="GWh", submodulo="generacion"):
    return _v(id_, nombre, "Eléctrico", freq, unidad, "MEM", submodulo=submodulo,
              fuente_url="https://mem.gob.do/category/sector-electrico/informe-de-desempeno/")

ELECTRICO: list[dict] = [
    # Generación por tipo de combustible
    _el("el_gen_total",        "Generación Total"),
    _el("el_gen_carbon",       "Generación Carbón Mineral"),
    _el("el_gen_gas_nat",      "Generación Gas Natural"),
    _el("el_gen_fo2",          "Generación Fuel Oil No. 2"),
    _el("el_gen_fo6",          "Generación Fuel Oil No. 6"),
    _el("el_gen_fo26",         "Generación Fuel Oil No. 2 y No. 6"),
    _el("el_gen_hidro",        "Generación Hidráulica"),
    _el("el_gen_eolica",       "Generación Eólica"),
    _el("el_gen_solar",        "Generación Solar Fotovoltaica"),
    _el("el_gen_biomasa",      "Generación Biomasa"),
    # Costos
    _el("el_cmg_energia",      "Costo Marginal de Energía",   unidad="USCents/kWh", submodulo="costos"),
    _el("el_cmg_potencia",     "Costo Marginal de Potencia",  unidad="US$/kW-mes",  submodulo="costos"),
    _el("el_peaje_trans",      "Peaje de Transmisión",         unidad="USCents/kWh", submodulo="costos"),
    _el("el_der_conex",        "Derecho de Conexión Unitario", unidad="US$/kW-mes",  submodulo="costos"),
    # Precios combustibles
    _el("el_pcomb_fo2",        "Precio Fuel Oil No. 2",        unidad="US$/MMBTU", submodulo="precios_comb"),
    _el("el_pcomb_fo6",        "Precio Fuel Oil No. 6",        unidad="US$/MMBTU", submodulo="precios_comb"),
    _el("el_pcomb_gas",        "Precio Gas Natural",            unidad="US$/MMBTU", submodulo="precios_comb"),
    _el("el_pcomb_gas_conv",   "Precio Gas Natural (Conv.)",   unidad="US$/MMBTU", submodulo="precios_comb"),
    _el("el_pcomb_carbon",     "Precio Carbón Mineral",         unidad="US$/MMBTU", submodulo="precios_comb"),
    _el("el_tc",               "Tasa de Cambio Sector Eléctrico", unidad="RD$/US$", submodulo="precios_comb"),
]

# Precios venta/compra por distribuidora (total + EDN/EDS/EDE) × {SPOT, CONTRATOS, Venta}
for prefijo, label_corto in [("el_pventa", "Precio Venta"),
                              ("el_pcomp_spot", "Precio Compra SPOT"),
                              ("el_pcomp_cont", "Precio Compra CONTRATOS")]:
    for sufijo, dist in [("_tot", "Total"), ("_edn", "EDENORTE"), ("_eds", "EDESUR"), ("_ede", "EDEESTE")]:
        ELECTRICO.append(_el(f"{prefijo}{sufijo}", f"{label_corto} {dist}",
                              unidad="USCents/kWh", submodulo="precios_dist"))

# CRI, Energía Facturada, Pérdidas, Cobranzas (Total + 3 distribuidoras)
for prefijo, label_corto, unidad in [
    ("el_cri", "CRI", "%"),
    ("el_efact", "Energía Facturada", "GWh"),
    ("el_perd", "Pérdidas", "%"),
    ("el_cobr", "Cobranzas", "%"),
]:
    for sufijo, dist in [("_tot", "Total"), ("_edn", "EDENORTE"), ("_eds", "EDESUR"), ("_ede", "EDEESTE")]:
        ELECTRICO.append(_el(f"{prefijo}{sufijo}", f"{label_corto} {dist}",
                              unidad=unidad, submodulo="distribucion"))

# Resultados financieros (anual)
for prefijo, label_corto in [
    ("el_def_op",    "Balance Operacional"),
    ("el_def_capex", "Balance con Inversiones"),
    ("el_def_fin",   "Balance luego de Financiamiento"),
]:
    for sufijo, dist in [("_tot", "Total"), ("_edn", "EDENORTE"), ("_eds", "EDESUR"), ("_ede", "EDEESTE")]:
        ELECTRICO.append(_el(f"{prefijo}{sufijo}", f"{label_corto} {dist}",
                              freq="anual", unidad="RD$", submodulo="financiero"))


# ============================================================================
# Concatenación
# ============================================================================
TODAS: list[dict] = (
    DIARIAS + MENSUALES + TRIMESTRALES +
    BOP + PII + DEUDA + EO +
    MONETARIO_T + PANORAMA_M +
    PROY_M + PROY_T + ELECTRICO
)


def todas_variables() -> list[dict]:
    return list(TODAS)


def filtrar_por(modulo: str | None = None, frecuencia: str | None = None,
                fuente: str | None = None, tipo: str | None = None) -> list[dict]:
    out = TODAS
    if modulo:     out = [v for v in out if v["modulo"] == modulo]
    if frecuencia: out = [v for v in out if v["frecuencia"] == frecuencia]
    if fuente:     out = [v for v in out if v["fuente"] == fuente]
    if tipo:       out = [v for v in out if v["tipo"] == tipo]
    return out


def filtrar_directas(rows: Iterable[dict] | None = None) -> list[dict]:
    return [v for v in (rows or TODAS) if v["tipo"] == "directa"]


def filtrar_derivadas(rows: Iterable[dict] | None = None) -> list[dict]:
    return [v for v in (rows or TODAS) if v["tipo"] == "derivada"]


if __name__ == "__main__":
    from collections import Counter
    print(f"Total variables: {len(TODAS)}")
    print(f"Por módulo:     {dict(Counter(v['modulo']     for v in TODAS))}")
    print(f"Por frecuencia: {dict(Counter(v['frecuencia'] for v in TODAS))}")
    print(f"Por fuente:     {dict(Counter(v['fuente']     for v in TODAS))}")
    print(f"Por tipo:       {dict(Counter(v['tipo']       for v in TODAS))}")
