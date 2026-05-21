# Plan de Parsers — Cobertura del Catálogo Canónico

> Fuente de la verdad: `core/catalog_r.py` (478 vars). Esto trackea qué parsers
> existen, cuáles faltan, y el archivo de origen para cada uno.

## Estado actual

| Estado | Cobertura |
|--------|-----------|
| ✅ Parser funcional + datos en Supabase | 56 vars |
| ⚠️ URL conocida, parser pendiente      | 122 vars |
| 🆕 Agregadas al catálogo, sin parser    | 300 vars |
| **Total catálogo**                      | **478** |

## Por fuente

### BCRD — 301 variables · Endpoint base: `https://cdn.bancentral.gov.do/documents/`

| Slug | Vars que produce | URL relativa | Estado | Parser |
|------|------------------|--------------|--------|--------|
| `tcn_dia`        | tcn_compra, tcn_venta             | `estadisticas/mercado-cambiario/documents/TASA_DOLAR_REFERENCIA_MC.xlsx` | ✅ | `parser_tcn_dia` |
| `tcn_eur_dia`    | tcn_venta_eur                     | `estadisticas/mercado-cambiario/documents/TASAS_CONVERTIBLES_OTRAS_MONEDAS.xlsx` | 🆕 | TODO |
| `embi`           | embi, embi_rd                     | `entorno-internacional/documents/Serie_Historica_Spread_del_EMBI.xlsx` | ✅ | `parser_embi` |
| `tc_ent_fin`     | tcn_compra_m, tcn_venta_m         | `estadisticas/mercado-cambiario/documents/TASA_ENTIDADES_FINANCIERAS.xls` | ✅ | `parser_tc_ent_fin` |
| `ipc`            | inf_rd                            | `estadisticas/precios/documents/ipc_base_2019-2020.xls` | ✅ | `parser_filas_mes` |
| `ipc_sub`        | inf_sub                           | `estadisticas/precios/documents/ipc_subyacente_base_2019-2020.xlsx` | ✅ | `parser_ipc_sub` |
| `ipc_tnt`        | inf_trans, inf_no_trans           | `estadisticas/precios/documents/ipc_tnt_base_2019-2020.xls` | ⚠️ | TODO |
| `ipc_grupos`     | inf_AyBNA…inf_BySD (12 grupos)    | `estadisticas/precios/documents/ipc_grupos_base_2019-2020.xls` | 🆕 | TODO |
| `imae`           | imae, pib_real                    | `estadisticas/sector-real/documents/imae_2018.xlsx` | ✅ | `parser_filas_mes` |
| `expE`           | ICI                               | `politica-monetaria/expectativas-macroeconomicas/documents/Historico-EOE-(Mensual).xlsx` | 🆕 | TODO |
| `rin`            | rin                               | `estadisticas/sector-externo/documents/reservas_internacionales.xlsx` | ✅ | `parser_rin` |
| `rem_fam`        | rem_fam                           | `estadisticas/sector-externo/documents/Remesas_6.xlsx` | ✅ | `parser_pivot_anio_x_mes` |
| `imp_petroleo`   | imp_pd_va, m_pqoil_rd             | `estadisticas/sector-externo/documents/Importaciones_Crudo_6.xls` | ⚠️ | TODO (segunda col) |
| `balanza_pagos`  | 31 vars BoP                       | `estadisticas/sector-externo/documents/bpagos__trim_6.xls` | ⚠️ | TODO |
| `pii`            | 90 vars PII (activos + pasivos)   | `estadisticas/sector-externo/documents/piitrim_6.xlsx` | ⚠️ | TODO |
| `llegada_tur`    | se_cc_numtur                      | `estadisticas/sector-turismo/documents/lleg_total.xls` | ✅ | `parser_filas_mes` |
| `tpm`            | tpm, DEPOS, REPOS                 | `estadisticas/sector-monetario-y-financiero/documents/Serie_TPM.xlsx` | ⚠️ Solo tpm | TODO DEPOS/REPOS |
| `base_mon`       | bmr_rd                            | `estadisticas/sector-monetario-y-financiero/documents/base_monetaria.xlsx` | ✅ | `parser_filas_mes` |
| `agregados`      | M1, M2, M3                        | `estadisticas/sector-monetario-y-financiero/documents/agregados_monetarios.xlsx` | ⚠️ Solo m1 | TODO M2/M3 |
| `encaje`         | encajemn_d_q, encajeme_d_q        | `estadisticas/sector-monetario-y-financiero/documents/encaje_bancario.xlsx` | ⚠️ Solo encaje_mn | TODO encaje_me |
| `credito_sect`   | prest_tot, prest_agr…             | `estadisticas/sector-monetario-y-financiero/documents/serie_prestamos_por_destino_armonizados.xlsx` | ✅ | `parser_credito_sect` |
| `credito_osd`    | pbcred_nc_rd                      | `estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_osd.xlsx` | 🆕 | TODO |
| `ind_amo_bcrd`   | sm_bcrd_vc + 30 vars data_monetario | `estadisticas/sector-monetario-y-financiero/documents/serie_indicadores_bcrd.xlsx` | ⚠️ Solo sm_bcrd_vc | TODO 30 más |
| `compra_dolar`   | compra_fx_tot                     | `estadisticas/mercado-cambiario/documents/Operaciones_us.xls` | ✅ | `parser_filas_mes` |
| `ti_activa`      | tia_prom_pond_rd, tia_90, tia_5yr | `estadisticas/sector-monetario-y-financiero/documents/tbm_activad.xlsx` | ⚠️ Solo tia_prom | TODO tia_90/tia_5yr |
| `ti_pasiva`      | tip_prom_pond                     | `estadisticas/sector-monetario-y-financiero/documents/tbm_pasivad.xlsx` | ✅ | `parser_ti_pasiva` |
| `vol_pasividad`  | vol_tip, sd_tip                   | `estadisticas/sector-monetario-y-financiero/documents/volatilidades.xls` | 🆕 | TODO |
| `ti_intb`        | tib_rd                            | `estadisticas/sector-monetario-y-financiero/documents/operaciones_interb.xls` | ✅ | `parser_ti_intb` |
| `panorama_bc`    | 13 vars panorama (ae_ronr_bc…)    | `estadisticas/sector-monetario-y-financiero/documents/panorama_pbc.xlsx` | 🆕 | TODO |
| `panorama_osd`   | 13 vars panorama (ae_nr_osd…)     | `estadisticas/sector-monetario-y-financiero/documents/panorama_posd.xlsx` | 🆕 | TODO |
| `credito_spnf`   | 14 vars (a_vda_*, p_dto_*…)       | `estadisticas/sector-monetario-y-financiero/documents/credito_nofinanciero_bc.xlsx` | 🆕 | TODO |
| `pib_gasto`      | pib_nom, ct_nom, cpr_nom… (15 vars) | `estadisticas/sector-real/documents/pib_gasto_retro_2018.xlsx` | ⚠️ | TODO completo |
| `pib_origen`     | inc_agr, agro_real…(15 vars)      | `estadisticas/sector-real/documents/pib_origen_retro_2018.xlsx` | 🆕 | TODO |
| `pib_deflactor`  | defl_pib                          | `estadisticas/sector-real/documents/pib_deflactor_2018.xlsx` | 🆕 | TODO |
| `trabajo`        | l_enftc, wnom_enftc, hrs_enftc    | `estadisticas/mercado-de-trabajo/documents/3_1_Deciles_Rama.xlsx` | 🆕 | TODO |

### Externos (no BCRD)

| Slug | Vars | URL/API | Estado |
|------|------|---------|--------|
| Yahoo (yfinance) | 7 daily + 2 monthly (vix, DowJones) | `^GSPC, ^DJI, ^VIX, CL=F, NG=F, GC=F, MTF=F` | ✅ |
| FRED API | cpi_usa, indpro_usa, indproMan_usa, fedFunds, ur_*, **epu_eeuu, epu_global, pib_eeuu** | `CPIAUCSL, INDPRO, IPMAN, FEDFUNDS, UNRATE, UNRATENSA, USEPUINDXM, GEPUCURRENT, GDPC1, DGS10` | ✅ parcial — falta `epu_*`, `indproMan_usa`, `pib_eeuu` |
| WB CMO | p_petroleo, p_gas_nat, p_oro, ind_p_AyB, ener_ind, non_ener_ind, food_ind, metals_ind, prec_metal_ind | `CMO-Historical-Data-Monthly.xlsx` (2026 URL: `74e8be41ceb20fa0da750cda2f6b9e4e-0050012026`) | ⚠️ URL caducada en pipeline |
| EIA STEO | 7 forecast vars (`_f` suffix)         | `https://www.eia.gov/outlooks/steo/xls/STEO_m.xlsx` | 🆕 TODO |

### Hacienda — Estado de Operaciones (55 vars, mensual)

URL HTML scrape: `https://www.hacienda.gob.do/estadisticas-fiscales/` → busca link `"Gobierno central presupuestario estado de operaciones mensual RD$ y US$"`.

Parser: leer hoja 1, skip 12, transponer, alinear contra `eo$periodo` (formato `YYYYMm`). Mapeo a IDs en `core/catalog_r.py::EO`.

**Estado:** 🆕 Pipeline `forecasting/hacienda_eo.py` existe stub pero no extrae las 55 vars. TODO.

### DGII (11 vars, mensual)

- `Operaciones Totales ITBIS YYYY.xlsx` — provisto por DGII vía Excel (no en URL pública). Mapeo: 8 sectores → ventas_*.
- `Recaudo por impuestos semanal 2015 - 2026.xlsx` — Hidro_av, Hidro_esp, itbis_ret_ca, imp_cheq.

**Estado:** 🆕 Requiere ingesta manual del Excel. Considerar Drive sync.

### SIPEN (2 vars)

URL HTML scrape: `https://www.sipen.gob.do/estadisticas/...` → links de "Salario" y "Cotizantes".

**Estado:** 🆕 `pipelines/forecasting/sipen.py` stub. TODO.

### DGA (2 vars: export, import)

Origen: **SQL Server interno** (`172.16.2.91/DGA_PLT`). No accesible desde GitHub Actions cloud.

**Estado:** 🆕 Requiere self-hosted runner en la red MH. Alternativa: Excel manual subido vía Drive/SharePoint.

### MEM Sector Eléctrico (60 vars)

Archivo: `https://mem.gob.do/category/sector-electrico/informe-de-desempeno/` → busca link "Anexo" más reciente → descarga `.xlsx`.

Hojas:
- `EDE's` → 4 distribuidoras (precios venta/compra, CRI, energía facturada, pérdidas, cobranzas)
- `Variables Relevantes` → generación por combustible, costos, precios combustibles
- `Anexo Res Financieros` → Balance Operacional/Capex/Financiamiento por distribuidora (anual)

**Estado:** ⚠️ `pipelines/sector_electrico/parse_anexo.py` parcial. TODO mapeo a IDs `el_*` del catálogo.

## Orden de prioridad sugerido

1. **DESBLOQUEA TODO:** Sincronizar catálogo nuevo (`python sql/upsert_catalogo_supabase.py`) — agrega las 300 vars nuevas a Supabase. Sin esto, el frontend no ve ningún nombre/módulo nuevo.

2. **Quick wins** (parsers simples sobre archivos ya descargados):
   - `ipc_tnt` → 2 vars (inf_trans, inf_no_trans)
   - `ipc_grupos` → 12 vars (inflación por grupo)
   - `agregados` → 2 vars (M2, M3) – mismo archivo que ya leemos
   - `encaje_me` → 1 var – mismo archivo
   - `tia_90`, `tia_5yr` → 2 vars – mismo archivo
   - FRED `epu_eeuu`, `epu_global`, `indproMan_usa`, `pib_eeuu` → 4 vars
   - `tpm` → DEPOS y REPOS – mismo archivo

3. **Medium** (parsers nuevos):
   - WB CMO actualizado (URL 2026) → 9 vars
   - `pib_gasto` completo → 15 vars
   - `pib_origen` → 15 vars
   - `pib_deflactor` → 1 var

4. **High effort, high value:**
   - Hacienda EO → 55 vars fiscales (clave para dashboard)
   - MEM Sector Eléctrico completo → 60 vars
   - Panorama monetario (BC + OSD) → 27 vars
   - Indicadores armonizados BCRD → 30 vars

5. **Requiere infra externa:**
   - DGA SQL Server → self-hosted runner o export manual
   - DGII ITBIS → ingesta manual del Excel
   - EIA STEO → URL fija pero parser complicado (multi-hoja)
