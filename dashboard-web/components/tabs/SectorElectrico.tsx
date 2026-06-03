'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { merge, filterMergedByRange, monthsAgo, xFmtMonth } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import BarChartVert from '@/components/charts/BarChartVert'
import LineChartSimple from '@/components/charts/LineChartSimple'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { SeriesMap } from '@/types'
import { C } from '@/lib/colors'

/* IDs disponibles desde MEM (catalog_r) — todos los datos vienen de
 * pipelines/sector_electrico/run.py poblando series_datos. */
const GEN_IDS = [
  'el_gen_total', 'el_gen_carbon', 'el_gen_gas_nat',
  'el_gen_fo2', 'el_gen_fo6', 'el_gen_hidro',
  'el_gen_eolica', 'el_gen_solar', 'el_gen_biomasa',
]
const PCOMB_IDS = [
  'el_pcomb_fo2', 'el_pcomb_fo6', 'el_pcomb_gas', 'el_pcomb_carbon',
]
const COSTOS_IDS = ['el_cmg_energia', 'el_cmg_potencia']
const PVENTA_IDS = ['el_pventa_tot', 'el_pventa_edn', 'el_pventa_eds', 'el_pventa_ede']
const PERD_IDS = ['el_perd_tot', 'el_perd_edn', 'el_perd_eds', 'el_perd_ede']
const COBR_IDS = ['el_cobr_tot', 'el_cobr_edn', 'el_cobr_eds', 'el_cobr_ede']
const CRI_IDS = ['el_cri_tot', 'el_cri_edn', 'el_cri_eds', 'el_cri_ede']
const DEF_OP_IDS = ['el_def_op_tot', 'el_def_op_edn', 'el_def_op_eds', 'el_def_op_ede']

const ALL_IDS = [
  ...GEN_IDS, ...PCOMB_IDS, ...COSTOS_IDS, ...PVENTA_IDS,
  ...PERD_IDS, ...COBR_IDS, ...CRI_IDS, ...DEF_OP_IDS,
  'el_tc',
]

const GEN_LABELS: Record<string, string> = {
  el_gen_total:   'Total',
  el_gen_carbon:  'Carbón',
  el_gen_gas_nat: 'Gas Natural',
  el_gen_fo2:     'Fuel Oil #2',
  el_gen_fo6:     'Fuel Oil #6',
  el_gen_hidro:   'Hidráulica',
  el_gen_eolica:  'Eólica',
  el_gen_solar:   'Solar',
  el_gen_biomasa: 'Biomasa',
}

const PCOMB_LABELS: Record<string, string> = {
  el_pcomb_fo2:    'Fuel Oil #2',
  el_pcomb_fo6:    'Fuel Oil #6',
  el_pcomb_gas:    'Gas Natural',
  el_pcomb_carbon: 'Carbón',
}

const DIST_LABELS: Record<string, string> = {
  tot: 'Total', edn: 'EDENORTE', eds: 'EDESUR', ede: 'EDEESTE',
}

const GEN_COLORS = [C.gray, C.amber, C.lightBlue, C.red, '#A0522D',
                    C.blue, C.teal, '#F59E0B', C.green]
const DIST_COLORS = [C.blue, C.green, C.amber, C.red]

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

// Alias para preservar referencias del archivo (xFmtMonth global del lib)
const xFmtM = xFmtMonth
const xFmtY = (v: string) => v.slice(0, 4)

export default function SectorElectrico() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const today = new Date().toISOString().slice(0, 7)

  useEffect(() => {
    fetchSeries(ALL_IDS, '2020-01-01').then(setSeries).finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(24), today]   // 2 años default (recientes)
  const [rGen, onRGen] = useRange(def)
  const [rCost, onRCost] = useRange(def)
  const [rPCom, onRPCom] = useRange(def)
  const [rPerd, onRPerd] = useRange(def)
  const [rCobr, onRCobr] = useRange(def)
  const [rPventa, onRPventa] = useRange(def)
  const [rFin, onRFin] = useRange([monthsAgo(60), today])

  /* Generación: merge todas, filtrar NaN, formato mensual */
  const genMerged = useMemo(() => {
    const seriesNoTotal = GEN_IDS.filter(id => id !== 'el_gen_total')
    return merge(
      Object.fromEntries(seriesNoTotal.map(id => [id, (series[id] ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0,7) }))])),
      seriesNoTotal,
    )
  }, [series])

  const genTotal = useMemo(
    () => (series.el_gen_total ?? []).map(d => ({ fecha: d.fecha.slice(0, 7), valor: d.valor })),
    [series.el_gen_total])

  /* Costos marginales */
  const costMerged = useMemo(() => merge({
    el_cmg_energia: (series.el_cmg_energia ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0, 7) })),
    el_cmg_potencia: (series.el_cmg_potencia ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0, 7) })),
  }, COSTOS_IDS), [series.el_cmg_energia, series.el_cmg_potencia])

  /* Precios combustibles */
  const pcombMerged = useMemo(() => merge(
    Object.fromEntries(PCOMB_IDS.map(id => [id, (series[id] ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0,7) }))])),
    PCOMB_IDS,
  ), [series])

  /* Pérdidas por distribuidora (BCRD/MEM guarda como fracción 0..1, × 100 → %) */
  const perdMerged = useMemo(() => merge(
    Object.fromEntries(PERD_IDS.map(id => [id, (series[id] ?? [])
      .filter(d => isFinite(d.valor))
      .map(d => ({ fecha: d.fecha.slice(0,7), valor: d.valor * 100 }))])),
    PERD_IDS,
  ), [series])

  /* Cobranzas (fracción × 100) */
  const cobrMerged = useMemo(() => merge(
    Object.fromEntries(COBR_IDS.map(id => [id, (series[id] ?? [])
      .filter(d => isFinite(d.valor))
      .map(d => ({ fecha: d.fecha.slice(0,7), valor: d.valor * 100 }))])),
    COBR_IDS,
  ), [series])

  /* CRI por distribuidora (fracción × 100) */
  const criMerged = useMemo(() => merge(
    Object.fromEntries(CRI_IDS.map(id => [id, (series[id] ?? [])
      .filter(d => isFinite(d.valor))
      .map(d => ({ fecha: d.fecha.slice(0,7), valor: d.valor * 100 }))])),
    CRI_IDS,
  ), [series])

  /* Precios de venta por distribuidora */
  const pventaMerged = useMemo(() => merge(
    Object.fromEntries(PVENTA_IDS.map(id => [id, (series[id] ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0,7) }))])),
    PVENTA_IDS,
  ), [series])

  /* Balance operacional anual por distribuidora (financiero) */
  const defOpAnnual = useMemo(() => merge(
    Object.fromEntries(DEF_OP_IDS.map(id => [id, (series[id] ?? []).map(d => ({ ...d, fecha: d.fecha.slice(0,7) }))])),
    DEF_OP_IDS,
  ), [series])

  /* Resumen para el header: último valor de cada distribuidora */
  const lastVal = (arr: { fecha: string; valor: number }[] | undefined) =>
    arr && arr.length ? arr[arr.length - 1].valor : null

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G1 Generación total */}
      <ChartWrapper title="Generación Total de Energía"
        subtitle="GWh mensuales — MEM"
        from={rGen[0]} to={rGen[1]} onRangeChange={onRGen}
        isLoading={loading} downloadName="generacion-total">
        <BarChartVert
          data={genTotal.filter(d => d.fecha >= rGen[0] && d.fecha <= rGen[1] && isFinite(d.valor))}
          color={C.blue} unit="GWh"
          xFormatter={xFmtM}
          yFormatter={v => `${v.toFixed(0)}`}
          label="Total Generación"
        />
      </ChartWrapper>

      {/* G2 Generación por combustible */}
      <ChartWrapper title="Generación por Tipo de Combustible"
        subtitle="GWh mensuales — mix energético"
        from={rGen[0]} to={rGen[1]} onRangeChange={onRGen}
        isLoading={loading} downloadName="generacion-por-combustible">
        <LineChartSimple
          data={filterMergedByRange(genMerged, rGen[0], rGen[1])}
          series={GEN_IDS.filter(id => id !== 'el_gen_total').map((id, i) => ({
            key: id, label: GEN_LABELS[id], color: GEN_COLORS[i % GEN_COLORS.length],
          }))}
          unit="GWh" yFormatter={v => v.toFixed(0)}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G3 Costos marginales (energía y potencia) */}
      <ChartWrapper title="Costos Marginales"
        subtitle="Energía (USCents/kWh) vs Potencia (US$/kW-mes)"
        from={rCost[0]} to={rCost[1]} onRangeChange={onRCost}
        isLoading={loading} downloadName="costos-marginales">
        <ComboChartDual
          data={filterMergedByRange(costMerged, rCost[0], rCost[1])}
          barKey="el_cmg_energia" barLabel="CMg Energía (cUS$/kWh)" barColor={C.blue}
          lineKey="el_cmg_potencia" lineLabel="CMg Potencia (US$/kW-mes)" lineColor={C.red}
          yLeftFormatter={v => v.toFixed(1)}
          yRightFormatter={v => v?.toFixed(1) ?? '—'}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G4 Precios combustibles */}
      <ChartWrapper title="Precios de Combustibles"
        subtitle="US$/MMBTU mensuales"
        from={rPCom[0]} to={rPCom[1]} onRangeChange={onRPCom}
        isLoading={loading} downloadName="precios-combustibles">
        <LineChartSimple
          data={filterMergedByRange(pcombMerged, rPCom[0], rPCom[1])}
          series={PCOMB_IDS.map((id, i) => ({
            key: id, label: PCOMB_LABELS[id], color: [C.amber, C.red, C.lightBlue, C.gray][i],
          }))}
          unit="US$/MMBTU" yFormatter={v => v.toFixed(1)}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G5 Pérdidas por distribuidora */}
      <ChartWrapper title="Pérdidas por Distribuidora"
        subtitle="% sobre energía facturada"
        from={rPerd[0]} to={rPerd[1]} onRangeChange={onRPerd}
        isLoading={loading} downloadName="perdidas-distribuidoras">
        <LineChartSimple
          data={filterMergedByRange(perdMerged, rPerd[0], rPerd[1])}
          series={PERD_IDS.map((id, i) => ({
            key: id, label: DIST_LABELS[id.split('_').pop() as string], color: DIST_COLORS[i],
          }))}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G6 Cobranzas por distribuidora — escala ajustada al rango efectivo */}
      <ChartWrapper title="Cobranzas por Distribuidora"
        subtitle="% recaudo sobre facturado (escala enfocada para ver diferencias)"
        from={rCobr[0]} to={rCobr[1]} onRangeChange={onRCobr}
        isLoading={loading} downloadName="cobranzas-distribuidoras">
        <LineChartSimple
          data={filterMergedByRange(cobrMerged, rCobr[0], rCobr[1])}
          series={COBR_IDS.map((id, i) => ({
            key: id, label: DIST_LABELS[id.split('_').pop() as string], color: DIST_COLORS[i],
          }))}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          xFormatter={xFmtM}
          yDomain={[80, 110]}   // cobranzas típicas 85-105% → zoom para ver dispersión
        />
      </ChartWrapper>

      {/* G7 Precios de venta — escala ajustada */}
      <ChartWrapper title="Precio Medio de Venta de Energía"
        subtitle="USCents/kWh por distribuidora (escala enfocada)"
        from={rPventa[0]} to={rPventa[1]} onRangeChange={onRPventa}
        isLoading={loading} downloadName="precio-venta-distribuidoras">
        <LineChartSimple
          data={filterMergedByRange(pventaMerged, rPventa[0], rPventa[1])}
          series={PVENTA_IDS.map((id, i) => ({
            key: id, label: DIST_LABELS[id.split('_').pop() as string], color: DIST_COLORS[i],
          }))}
          unit="cUS$/kWh" yFormatter={v => v.toFixed(2)}
          xFormatter={xFmtM}
          yDomain={[10, 22]}    // precios típicos 12-20 cUS$/kWh → enfoca diferencias
        />
      </ChartWrapper>

      {/* G8 Balance Operacional anual */}
      <ChartWrapper title="Balance Operacional Anual"
        subtitle="MM RD$ — por distribuidora"
        from={rFin[0]} to={rFin[1]} onRangeChange={onRFin}
        isLoading={loading} downloadName="balance-operacional-anual">
        <LineChartSimple
          data={filterMergedByRange(defOpAnnual, rFin[0], rFin[1])}
          series={DEF_OP_IDS.map((id, i) => ({
            key: id, label: DIST_LABELS[id.split('_').pop() as string], color: DIST_COLORS[i],
          }))}
          unit="MM RD$" yFormatter={v => `${(v/1000).toFixed(1)}B`}
          xFormatter={xFmtY}
        />
      </ChartWrapper>

      {/* Resumen distribuidoras */}
      <div className="col-span-full bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-3">
        <h3 className="text-[13px] font-semibold text-[#1A202C] mb-2">Resumen último mes por distribuidora</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-[11px]">
            <thead>
              <tr className="bg-[#F0F2F5] text-[#1A202C]">
                <th className="px-2 py-1.5 text-left font-semibold">Distribuidora</th>
                <th className="px-2 py-1.5 text-right font-semibold">CRI (%)</th>
                <th className="px-2 py-1.5 text-right font-semibold">Pérdidas (%)</th>
                <th className="px-2 py-1.5 text-right font-semibold">Cobranzas (%)</th>
                <th className="px-2 py-1.5 text-right font-semibold">P. Venta (cUS$/kWh)</th>
              </tr>
            </thead>
            <tbody>
              {(['tot','edn','eds','ede'] as const).map(d => {
                const cri  = lastVal(series[`el_cri_${d}`])
                const perd = lastVal(series[`el_perd_${d}`])
                const cobr = lastVal(series[`el_cobr_${d}`])
                const pv   = lastVal(series[`el_pventa_${d}`])
                return (
                  <tr key={d} className="border-t border-[#F0F2F5]">
                    <td className="px-2 py-1 font-medium text-[#1A202C]">{DIST_LABELS[d]}</td>
                    <td className="px-2 py-1 text-right tabular-nums">{cri  != null && isFinite(cri)  ? `${(cri  * 100).toFixed(1)}%` : '—'}</td>
                    <td className="px-2 py-1 text-right tabular-nums">{perd != null && isFinite(perd) ? `${(perd * 100).toFixed(1)}%` : '—'}</td>
                    <td className="px-2 py-1 text-right tabular-nums">{cobr != null && isFinite(cobr) ? `${(cobr * 100).toFixed(1)}%` : '—'}</td>
                    <td className="px-2 py-1 text-right tabular-nums">{pv   != null && isFinite(pv)   ? pv.toFixed(2)                : '—'}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
