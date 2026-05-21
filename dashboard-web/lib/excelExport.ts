'use client'

/**
 * Exportación Excel profesional, multi-hoja, con:
 *   1. README (cómo usar el archivo)
 *   2. Catalogo (metadata de todas las variables)
 *   3. data_diaria / data_mensual / data_trimestral / data_anual
 *      - Formato ancho (fecha en filas, una columna por variable)
 *      - Mensuales snap a día 01, trimestrales a Q1/Q4/Q7/Q10
 *      - Sin filas vacías intermedias
 *   4. graficos_principales (datos de cada gráfico del dashboard, listos para
 *      armar la visualización en Excel sobre las mismas tablas)
 *   5. formulas (descripción de variables derivadas con su cálculo)
 */
import * as XLSX from 'xlsx'
import {
  fetchCatalogWithData,
  fetchSeries,
  type CatalogVariable,
} from './queries'
import type { DataPoint } from '@/types'

type FreqGroup = 'diaria' | 'mensual' | 'trimestral' | 'anual'

const FREQ_SHEET_NAME: Record<FreqGroup, string> = {
  diaria: 'data_diaria',
  mensual: 'data_mensual',
  trimestral: 'data_trimestral',
  anual: 'data_anual',
}

/* ───────────────────────── normalizadores de fecha ──────────────────────── */
function normalizarFechaMensual(fecha: string): string {
  // YYYY-MM-XX → YYYY-MM-01
  return fecha.slice(0, 7) + '-01'
}
function normalizarFechaTrimestral(fecha: string): string {
  // YYYY-MM-XX → snap al inicio del trimestre (Q1=01, Q2=04, Q3=07, Q4=10)
  const [y, m] = fecha.split('-')
  const mNum = parseInt(m, 10)
  const qMonth = Math.floor((mNum - 1) / 3) * 3 + 1
  return `${y}-${String(qMonth).padStart(2, '0')}-01`
}
function normalizarFechaAnual(fecha: string): string {
  return fecha.slice(0, 4) + '-01-01'
}
function normalizarFecha(fecha: string, freq: FreqGroup): string {
  switch (freq) {
    case 'diaria':     return fecha.slice(0, 10)
    case 'mensual':    return normalizarFechaMensual(fecha)
    case 'trimestral': return normalizarFechaTrimestral(fecha)
    case 'anual':      return normalizarFechaAnual(fecha)
  }
}

/* ───────────────────────── pivot wide ───────────────────────────────────── */
function pivotWide(
  vars: CatalogVariable[],
  seriesByVar: Record<string, DataPoint[]>,
  freq: FreqGroup,
): { fecha: string; [k: string]: string | number | null }[] {
  // Normaliza fechas y reduce duplicados (último valor por fecha normalizada)
  const dateSet = new Set<string>()
  const mapsPorVar = new Map<string, Map<string, number>>()
  for (const v of vars) {
    const m = new Map<string, number>()
    for (const d of seriesByVar[v.id] ?? []) {
      if (!isFinite(d.valor)) continue
      const f = normalizarFecha(d.fecha, freq)
      m.set(f, d.valor)  // último gana
      dateSet.add(f)
    }
    mapsPorVar.set(v.id, m)
  }
  const dates = [...dateSet].sort()
  return dates.map((fecha) => {
    const row: { fecha: string; [k: string]: string | number | null } = { fecha }
    for (const v of vars) {
      row[v.id] = mapsPorVar.get(v.id)?.get(fecha) ?? null
    }
    return row
  })
}

/* ───────────────────────── hoja "graficos_principales" ─────────────────── */
type ChartSpec = {
  pestana: string
  grafico: string
  tipo: string
  variables: string[]
  formula?: string
  descripcion: string
}

const CHART_SPECS: ChartSpec[] = [
  // SECTOR EXTERNO
  { pestana: 'Sector Externo', grafico: 'Exportaciones Totales (anual USD)', tipo: 'Barras', variables: ['exp_nom', 'tcn_venta_m'],
    formula: 'export_anual_usd[año] = Σ(exp_nom[Q1..Q4]) / promedio_anual(tcn_venta_m)',
    descripcion: 'Exportaciones nominales trimestrales (RD$) sumadas anualmente, convertidas a USD con TCN promedio del año' },
  { pestana: 'Sector Externo', grafico: 'Remesas Familiares (mensual)', tipo: 'Barras', variables: ['rem_fam'],
    descripcion: 'Remesas mensuales en MM US$' },
  { pestana: 'Sector Externo', grafico: 'IED (BoP trimestral)', tipo: 'Barras', variables: ['ied_bp'],
    descripcion: 'Inversión Extranjera Directa (entrada neta) — Cuenta Financiera BoP' },
  { pestana: 'Sector Externo', grafico: 'Ingresos por Turismo', tipo: 'Barras', variables: ['viajes_bp'],
    descripcion: 'Viajes (crédito) de Balanza de Pagos en MM US$' },
  { pestana: 'Sector Externo', grafico: 'Llegada No Residentes (mensual)', tipo: 'Barras', variables: ['se_cc_numtur'],
    descripcion: 'Llegada total de turistas no residentes (BCRD)' },
  { pestana: 'Sector Externo', grafico: 'RIN y % PIB', tipo: 'Combo (Barras + Línea)', variables: ['rin', 'pib_nom', 'tcn_venta_m'],
    formula: 'rin_pct_pib[t] = rin[t] / (pibTrailing4Q(pib_nom, t) / tcn_venta_m[t]) × 100',
    descripcion: 'RIN nivel (US$M, izq.) y RIN sobre PIB anualizado en USD (%, der.)' },
  { pestana: 'Sector Externo', grafico: 'EMBI Global, LATAM, RD', tipo: 'Líneas', variables: ['embi_global', 'embi_latam', 'embi_rd'],
    descripcion: 'Riesgo soberano — último valor del mes (diario agregado)' },
  // TIPO DE CAMBIO
  { pestana: 'Tipo de Cambio', grafico: 'TCN diario y depreciación YoY', tipo: 'Combo', variables: ['tcn_venta'],
    formula: 'depr_yoy[t] = (tcn_venta[t] / tcn_venta[t-365d] - 1) × 100',
    descripcion: 'TCN venta diario y depreciación interanual % en eje derecho' },
  { pestana: 'Tipo de Cambio', grafico: 'TCR — Tipo de Cambio Real', tipo: 'Combo', variables: ['tcn_venta_m', 'cpi_usa', 'ipc_rd'],
    formula: 'TCR = (TCN/1.358727436) × (CPI_USA/218.076 × 100) / IPC_RD',
    descripcion: 'Tipo de cambio real bilateral RD-USA. CPI_USA base 2010, IPC_RD base 2019-2020 (coef enlace 1.3587)' },
  // TASAS
  { pestana: 'Tasas', grafico: 'Corredor de Tasas', tipo: 'Líneas', variables: ['tpm', 'tia_prom_pond', 'tip_prom_pond'],
    descripcion: 'TPM (BCRD), Tasa Activa y Tasa Pasiva promedio ponderado' },
  { pestana: 'Tasas', grafico: 'TPM Real', tipo: 'Líneas', variables: ['tpm', 'ipc_yoy', 'ipc_sub'],
    formula: 'tpm_real_gen = tpm - ipc_yoy ; tpm_real_sub = tpm - ipc_sub_yoy',
    descripcion: 'TPM deflactada por inflación general y subyacente' },
  { pestana: 'Tasas', grafico: 'Regla de Taylor', tipo: 'Líneas',
    variables: ['tpm', 'ipc_yoy', 'imae'],
    formula: 'i = r* + π* + α·(π − π*) + β·(y − ȳ)',
    descripcion: 'Tasa implícita por la regla de Taylor con 2 escenarios editables (r*, π*, α, β, ȳ)' },
  // DEPÓSITOS Y PRÉSTAMOS
  { pestana: 'Depósitos y Préstamos', grafico: 'Base Monetaria + Crecimiento', tipo: 'Combo', variables: ['bmr_rd'],
    formula: 'bmr_yoy[t] = (bmr[t]/bmr[t-12] − 1) × 100',
    descripcion: 'BMR nivel (RD$M) y variación interanual %' },
  { pestana: 'Depósitos y Préstamos', grafico: 'Préstamos en ME', tipo: 'Combo', variables: ['prest_me_usd_osd', 'prest_tot_osd', 'tc_fin_mes_osd'],
    formula: 'prest_me_pct = (prest_me_usd × tc_fin_mes) / prest_tot × 100',
    descripcion: 'Préstamos en moneda extranjera (US$M) y % sobre cartera total OSD' },
  { pestana: 'Depósitos y Préstamos', grafico: 'Depósitos del Gobierno', tipo: 'Líneas', variables: ['dep_sp_osd'],
    descripcion: 'Depósitos del Sector Público en OSD (MM RD$) con media móvil 12m' },
  { pestana: 'Depósitos y Préstamos', grafico: 'AEN Sistema Financiero', tipo: 'Líneas', variables: ['aen_osd_act', 'aen_osd_pas'],
    formula: 'aen_osd = aen_osd_act − aen_osd_pas',
    descripcion: 'Activos Externos Netos del sistema financiero (OSD)' },
  { pestana: 'Depósitos y Préstamos', grafico: 'Préstamos por Sector (Montos / YoY)', tipo: 'Líneas',
    variables: ['prest_agr', 'prest_ind', 'prest_con', 'prest_com', 'prest_viv', 'prest_tar', 'prest_cons'],
    descripcion: 'Saldo y crecimiento interanual de préstamos por sector económico (BCRD)' },
  // SECTOR ELÉCTRICO
  { pestana: 'Sector Eléctrico', grafico: 'Generación por Combustible', tipo: 'Líneas',
    variables: ['el_gen_total', 'el_gen_carbon', 'el_gen_gas_nat', 'el_gen_fo2', 'el_gen_fo6', 'el_gen_hidro', 'el_gen_eolica', 'el_gen_solar', 'el_gen_biomasa'],
    descripcion: 'Mix energético mensual en GWh por tipo de combustible (MEM)' },
  { pestana: 'Sector Eléctrico', grafico: 'Pérdidas por Distribuidora', tipo: 'Líneas',
    variables: ['el_perd_tot', 'el_perd_edn', 'el_perd_eds', 'el_perd_ede'],
    formula: 'pérdida_%_visualización = pérdida × 100 (BCRD guarda como fracción 0..1)',
    descripcion: 'Pérdidas técnicas y no técnicas como % de energía facturada' },
  { pestana: 'Sector Eléctrico', grafico: 'Balance Operacional Anual', tipo: 'Líneas',
    variables: ['el_def_op_tot', 'el_def_op_edn', 'el_def_op_eds', 'el_def_op_ede'],
    descripcion: 'Balance financiero operacional por distribuidora (anual, MM RD$)' },
  // DEPÓSITOS REMUNERADOS CP
  { pestana: 'Depósitos Remunerados CP', grafico: 'Nivel + MA30', tipo: 'Líneas', variables: ['deprem_cp'],
    formula: 'ma30[t] = promedio(deprem_cp[t-29..t])',
    descripcion: 'Saldo diario de la Ventanilla Directa BCRD' },
  { pestana: 'Depósitos Remunerados CP', grafico: 'Nivel + Var YoY', tipo: 'Combo', variables: ['deprem_cp'],
    formula: 'yoy_daily[t] = (deprem_cp[t]/deprem_cp[≈t-365d] − 1) × 100',
    descripcion: 'Saldo y variación interanual diaria' },
  { pestana: 'Depósitos Remunerados CP', grafico: 'Términos Reales', tipo: 'Líneas', variables: ['deprem_cp', 'ipc_rd'],
    formula: 'deprem_real[t] = deprem_cp[t] / (ipc_rd[mes(t)] / ipc_rd[primer_mes_rango])',
    descripcion: 'Saldo deflactado por IPC (base = primer mes del rango visible)' },
]

const FORMULAS_SPECS: { variable: string; descripcion: string; formula: string; fuentes: string }[] = [
  { variable: 'tcr_rd', descripcion: 'Tipo de Cambio Real bilateral RD-USA',
    formula: '(tcn_venta_m / 1.358727436) × (cpi_usa / 218.076 × 100) / ipc_rd',
    fuentes: 'tcn_venta_m: BCRD · cpi_usa: FRED CPIAUCSL · ipc_rd: BCRD' },
  { variable: 'rin_pct_pib', descripcion: 'RIN sobre PIB anualizado',
    formula: 'rin / (Σ pib_nom[Q-3..Q0] / tcn_venta_m) × 100',
    fuentes: 'rin: BCRD · pib_nom: BCRD pib_gasto · tcn_venta_m: BCRD' },
  { variable: 'aen_osd', descripcion: 'Activos Externos Netos del Sistema Financiero',
    formula: 'aen_osd_act − aen_osd_pas',
    fuentes: 'BCRD credito_osd.xlsx' },
  { variable: 'prest_me_pct', descripcion: 'Préstamos en ME como % del total',
    formula: '(prest_me_usd_osd × tc_fin_mes_osd) / prest_tot_osd × 100',
    fuentes: 'BCRD credito_osd.xlsx' },
  { variable: 'taylor_rate', descripcion: 'Regla de Taylor',
    formula: 'i = r* + π* + α·(π − π*) + β·(y − ȳ)',
    fuentes: 'tpm/ipc_yoy/imae: BCRD' },
  { variable: 'bmr_yoy / ipc_yoy / cualquier yoy', descripcion: 'Crecimiento interanual',
    formula: '(x[t] / x[t-12] − 1) × 100',
    fuentes: 'cálculo en frontend' },
  { variable: 'cualquier ma12', descripcion: 'Media móvil 12 meses',
    formula: 'promedio(x[t-11..t])',
    fuentes: 'cálculo en frontend' },
  { variable: 'deprem_real', descripcion: 'Depósitos remunerados deflactados',
    formula: 'deprem_cp / (ipc_rd[mes] / ipc_rd[base])',
    fuentes: 'BCRD operaciones_monetarias.xlsx + ipc_rd' },
]

/* ───────────────────────── helpers de Excel ─────────────────────────────── */
function autoColWidths(rows: Record<string, unknown>[]): XLSX.ColInfo[] {
  if (rows.length === 0) return []
  const keys = Object.keys(rows[0])
  return keys.map((k) => {
    const maxLen = Math.max(
      k.length,
      ...rows.slice(0, 50).map((r) => String(r[k] ?? '').length),
    )
    return { wch: Math.min(Math.max(maxLen + 2, 8), 28) }
  })
}

/* ───────────────────────── exportación principal ────────────────────────── */
export async function exportarExcelCompleto(
  options: { filename?: string } = {},
): Promise<void> {
  const filename = options.filename ?? `dashboard_ministro_${new Date().toISOString().slice(0, 10)}.xlsx`

  const catalog = await fetchCatalogWithData()
  if (catalog.length === 0) throw new Error('No hay datos disponibles')

  // Agrupar por frecuencia
  const byFreq: Record<FreqGroup, CatalogVariable[]> = {
    diaria: [], mensual: [], trimestral: [], anual: [],
  }
  for (const v of catalog) {
    const f = v.frecuencia
    if (f === 'diaria' || f === 'mensual' || f === 'trimestral' || f === 'anual') {
      byFreq[f].push(v)
    } else if (f === 'semanal') {
      byFreq.diaria.push(v)
    }
  }
  // Ordenar alfabéticamente por id dentro de cada freq
  for (const f of ['diaria', 'mensual', 'trimestral', 'anual'] as const) {
    byFreq[f].sort((a, b) => a.id.localeCompare(b.id))
  }

  // Fetch en lotes
  const fetchInChunks = async (ids: string[]) => {
    const out: Record<string, DataPoint[]> = {}
    const CHUNK = 40
    for (let i = 0; i < ids.length; i += CHUNK) {
      const sub = ids.slice(i, i + CHUNK)
      const part = await fetchSeries(sub, '1990-01-01')
      Object.assign(out, part)
    }
    return out
  }

  const wb = XLSX.utils.book_new()

  // ─── 1. README ───
  const readme: (string | number)[][] = [
    ['Dashboard Macroeconómico DGAPF — Exportación de datos'],
    [`Generado: ${new Date().toLocaleString('es-DO')}`],
    [''],
    ['INSTRUCCIONES'],
    ['1.', 'Cada hoja contiene una FRECUENCIA (diaria, mensual, trimestral, anual).'],
    ['2.', 'Las fechas están normalizadas: mensuales a día 01, trimestrales a Q1=01/Q2=04/Q3=07/Q4=10.'],
    ['3.', 'Una fila = una fecha. Una columna = una variable. Celda vacía = sin observación publicada.'],
    ['4.', 'La hoja "graficos_principales" lista cada gráfico del dashboard con las variables que usa y su fórmula.'],
    ['5.', 'La hoja "formulas" describe el cálculo de variables derivadas.'],
    ['6.', 'La hoja "Catalogo" tiene metadata completa de cada variable_id.'],
    [''],
    ['CONTENIDO POR HOJA'],
    ['Catalogo',          `${catalog.length} variables (id, nombre, módulo, frecuencia, unidad, fuente)`],
    ['data_diaria',       `${byFreq.diaria.length} series diarias`],
    ['data_mensual',      `${byFreq.mensual.length} series mensuales`],
    ['data_trimestral',   `${byFreq.trimestral.length} series trimestrales`],
    ['data_anual',        `${byFreq.anual.length} series anuales`],
    ['graficos_principales', `${CHART_SPECS.length} gráficos del dashboard listados con variables y fórmulas`],
    ['formulas',          `${FORMULAS_SPECS.length} fórmulas de variables derivadas`],
    [''],
    ['FUENTES DE LOS DATOS'],
    ['BCRD',              'Banco Central de la República Dominicana — Excel descargados de cdn.bancentral.gov.do'],
    ['FRED',              'Federal Reserve Economic Data — series CPIAUCSL, INDPRO, DGS10, FEDFUNDS, UNRATE...'],
    ['Yahoo Finance',     'Commodities y bolsa: CL=F (WTI), GC=F (Oro), ^GSPC (S&P), ^VIX...'],
    ['World Bank CMO',    'Pink Sheet de commodities mensual'],
    ['MEM',               'Anexo del Informe de Desempeño Eléctrico (mem.gob.do)'],
    ['Hacienda',          'Estado de Operaciones del gobierno central'],
    [''],
    ['ACTUALIZACIÓN'],
    ['Daily',  'Lun-Vie 12:00 UTC: Yahoo, FRED, BCRD diario'],
    ['Weekly', 'Lunes 14:00 UTC: pipeline BCRD completo'],
    ['Monthly','Días 1 y 15: MEM eléctrico + forecasts'],
  ]
  const wsReadme = XLSX.utils.aoa_to_sheet(readme)
  wsReadme['!cols'] = [{ wch: 25 }, { wch: 90 }]
  XLSX.utils.book_append_sheet(wb, wsReadme, 'README')

  // ─── 2. Catalogo ───
  const catalogRows = catalog.map((v) => ({
    id: v.id,
    nombre: v.nombre,
    modulo: v.modulo,
    submodulo: v.submodulo ?? '',
    frecuencia: v.frecuencia,
    unidad: v.unidad,
    escala: v.escala ?? '',
    fuente: v.fuente,
    tipo: v.tipo ?? 'directa',
  }))
  const wsCatalog = XLSX.utils.json_to_sheet(catalogRows)
  wsCatalog['!cols'] = autoColWidths(catalogRows)
  XLSX.utils.book_append_sheet(wb, wsCatalog, 'Catalogo')

  // ─── 3. Hojas por frecuencia ───
  for (const freq of ['diaria', 'mensual', 'trimestral', 'anual'] as const) {
    const vars = byFreq[freq]
    if (vars.length === 0) continue
    const ids = vars.map((v) => v.id)
    const seriesByVar = await fetchInChunks(ids)
    const wide = pivotWide(vars, seriesByVar, freq)
    if (wide.length === 0) continue
    const ws = XLSX.utils.json_to_sheet(wide)
    ws['!cols'] = autoColWidths(wide as Record<string, unknown>[])
    // Congelar 1ª fila y 1ª columna
    ws['!freeze'] = { xSplit: 1, ySplit: 1, topLeftCell: 'B2', activePane: 'bottomRight', state: 'frozen' }
    XLSX.utils.book_append_sheet(wb, ws, FREQ_SHEET_NAME[freq])
  }

  // ─── 4. graficos_principales ───
  const chartRows = CHART_SPECS.map((c) => ({
    pestaña: c.pestana,
    gráfico: c.grafico,
    tipo: c.tipo,
    'variables_usadas (separadas por |)': c.variables.join(' | '),
    fórmula: c.formula ?? '',
    descripción: c.descripcion,
  }))
  const wsCharts = XLSX.utils.json_to_sheet(chartRows)
  wsCharts['!cols'] = [
    { wch: 26 }, { wch: 42 }, { wch: 22 }, { wch: 60 }, { wch: 70 }, { wch: 80 },
  ]
  XLSX.utils.book_append_sheet(wb, wsCharts, 'graficos_principales')

  // ─── 5. formulas ───
  const formulasRows = FORMULAS_SPECS.map((f) => ({
    'variable / cálculo': f.variable,
    descripción: f.descripcion,
    fórmula: f.formula,
    fuentes: f.fuentes,
  }))
  const wsFormulas = XLSX.utils.json_to_sheet(formulasRows)
  wsFormulas['!cols'] = [{ wch: 30 }, { wch: 50 }, { wch: 70 }, { wch: 55 }]
  XLSX.utils.book_append_sheet(wb, wsFormulas, 'formulas')

  XLSX.writeFile(wb, filename)
}
