'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { merge, movingAverage, yoyGrowth, filterByRange, filterMergedByRange, monthsAgo, xFmtMonth, ultimaObs } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import BarChartVert from '@/components/charts/BarChartVert'
import LineChartSimple from '@/components/charts/LineChartSimple'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { SeriesMap } from '@/types'
import { C } from '@/lib/colors'

const SECTOR_IDS = ['prest_agr','prest_ind','prest_con','prest_com','prest_viv','prest_tar','prest_cons']
const SECTOR_LABELS: Record<string, string> = {
  prest_agr: 'Agricultura', prest_ind: 'Industria', prest_con: 'Construcción',
  prest_com: 'Comercio', prest_viv: 'Vivienda', prest_tar: 'Tarjetas', prest_cons: 'Consumo',
}
const SECTOR_COLORS = [C.blue, C.red, C.lightBlue, C.gray, C.amber, C.green, C.purple]

const ALL_IDS = ['bmr_rd', 'prest_tot', 'sm_bcrd_vc', 'ipc_rd', ...SECTOR_IDS,
  // OSD (mensual)
  'prest_tot_osd', 'prest_mn_osd', 'prest_me_usd_osd',
  'dep_sp_osd', 'aen_osd_act', 'aen_osd_pas', 'tc_fin_mes_osd']

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

const NOTE_DEP = 'Variables pendientes: depósitos sector privado y depósitos del gobierno. Requieren extracción desde encuesta monetaria ampliada BCRD.'
const NOTE_BMA = 'Nota: se usa Base Monetaria Restringida (BMR) disponible. Base Monetaria Ampliada (BMA) requiere variable adicional del pipeline.'

export default function DepositosPrestamos() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const [selectedSectors, setSelectedSectors] = useState<string[]>(SECTOR_IDS)
  const [montosView, setMontosView] = useState<'nivel' | 'yoy'>('nivel')
  const today = new Date().toISOString().slice(0, 7)

  useEffect(() => {
    fetchSeries(ALL_IDS, '2005-01-01')
      .then(setSeries)
      .finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(24), today]
  const [rBmr, onRBmr] = useRange(def)
  const [rPrest, onRPrest] = useRange(def)
  const [rDep, onRDep] = useRange(def)
  const [rSec, onRSec] = useRange(def)

  /* BMR + crecimiento interanual */
  const bmrData = series.bmr_rd ?? []
  const bmrYoY = useMemo(() => yoyGrowth(bmrData), [bmrData])
  const bmrDual = useMemo(() => {
    const yMap: Record<string, number> = {}
    for (const d of bmrYoY) yMap[d.fecha.slice(0, 7)] = d.valor
    return bmrData.map((d) => ({
      fecha: d.fecha.slice(0, 7),
      bmr: d.valor,
      yoy: yMap[d.fecha.slice(0, 7)] ?? null,
    }))
  }, [bmrData, bmrYoY])

  /* Préstamos totales */
  const prestData = series.prest_tot ?? []
  const prestYoY = useMemo(() => yoyGrowth(prestData), [prestData])
  const prestMA = useMemo(() => movingAverage(prestYoY, 12), [prestYoY])
  const prestMerged = useMemo(
    () => prestYoY.map((d, i) => ({ fecha: d.fecha.slice(0, 7), yoy: d.valor, ma12: prestMA[i]?.valor ?? null })),
    [prestYoY, prestMA])

  /* Valores en circulación */
  const vcData = series.sm_bcrd_vc ?? []

  /* Sector breakdown */
  const sectorPct = useMemo(() => {
    const dates = [...new Set(SECTOR_IDS.flatMap(id => (series[id] ?? []).map(d => d.fecha)))].sort()
    return dates.map(fecha => {
      const total = SECTOR_IDS.reduce((s, id) => {
        const pt = series[id]?.find(d => d.fecha === fecha)
        return s + (pt?.valor ?? 0)
      }, 0)
      const row: Record<string, number | string> = { fecha: fecha.slice(0, 7) }
      for (const id of SECTOR_IDS) {
        const pt = series[id]?.find(d => d.fecha === fecha)
        row[id] = total > 0 ? Math.round(((pt?.valor ?? 0) / total) * 1000) / 10 : 0
      }
      return row
    })
  }, [series])

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G2 BMR y crecimiento */}
      <ChartWrapper
        lastValue={(() => { const l = ultimaObs(series.bmr_rd); return l ? { label: 'BMR', value: l.valor, fecha: xFmtMonth(l.fecha.slice(0,7)), unit: 'MM RD$', valueFormatter: v => `${(v/1000).toFixed(1)}B` } : undefined })()}
        title="Base Monetaria y Crecimiento Interanual"
        subtitle="BMR en MM de RD$ (barras) y variación % interanual (línea)"
        from={rBmr[0]} to={rBmr[1]} isLoading={loading} onRangeChange={onRBmr}
        downloadName="base-monetaria" note={NOTE_BMA}>
        <ComboChartDual
          data={bmrDual.filter(d => d.fecha >= rBmr[0] && d.fecha <= rBmr[1])}
          barKey="bmr" barLabel="BMR (MM RD$)" barColor={C.blue}
          lineKey="yoy" lineLabel="Crec. interanual %" lineColor={C.red}
          yLeftFormatter={v => `${(v/1000).toFixed(0)}B`}
          yRightFormatter={v => `${v?.toFixed(1)}%`}
          xFormatter={v => { const [y,m]=v.split('-'); return `${['E','F','M','A','M','J','J','A','S','O','N','D'][+m-1]}'${y.slice(2)}` }}
        />
      </ChartWrapper>

      {/* G6 Crecimiento nominal préstamos + MA12 */}
      <ChartWrapper
        lastValue={(() => { const l = ultimaObs(series.prest_tot); return l ? { label: 'Prest. Total', value: l.valor, fecha: xFmtMonth(l.fecha.slice(0,7)), unit: 'MM RD$', valueFormatter: v => `${(v/1000).toFixed(1)}B` } : undefined })()}
        title="Crecimiento Interanual — Préstamos al Sector Privado (MN)"
        subtitle="Saldo total prest_tot (Sector Privado en Moneda Nacional, BCRD) · % YoY y MA12"
        from={rPrest[0]} to={rPrest[1]} isLoading={loading} onRangeChange={onRPrest}
        downloadName="prestamos-crecimiento">
        <LineChartSimple
          data={prestMerged.filter(d => d.fecha >= rPrest[0] && d.fecha <= rPrest[1])}
          series={[
            { key: 'yoy', label: 'Crecimiento interanual', color: C.blue },
            { key: 'ma12', label: 'Media móvil 12m', color: C.red, dashed: true, strokeWidth: 1.5 },
          ]}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`} refLine={0}
        />
      </ChartWrapper>

      {/* G15 Valores en circulación — formato mensual */}
      <ChartWrapper title="Valores en Circulación del Banco Central"
        subtitle="MM de RD$ — mensual"
        from={rDep[0]} to={rDep[1]} isLoading={loading} onRangeChange={onRDep}
        downloadName="valores-circulacion">
        <BarChartVert
          data={vcData.map(d => ({ ...d, fecha: d.fecha.slice(0, 7) })).filter(d => d.fecha >= rDep[0] && d.fecha <= rDep[1])}
          color={C.purple} unit="MM RD$"
          yFormatter={v => `${(v/1000).toFixed(0)}B`}
          xFormatter={xFmtMonth}
          label="Valores en circulación" />
      </ChartWrapper>

      {/* G1 Préstamos en ME — Monto y % del total (OSD) */}
      <ChartWrapper
        lastValue={(() => { const l = ultimaObs(series.prest_me_usd_osd); return l ? { label: 'Prest. ME', value: l.valor, fecha: xFmtMonth(l.fecha.slice(0,7)), unit: 'MM US$' } : undefined })()}
        title="Préstamos en Moneda Extranjera (OSD)"
        subtitle="Monto en MM US$ (eje izq.) y % de la cartera total OSD (eje der.)"
        from={rDep[0]} to={rDep[1]} isLoading={loading} onRangeChange={onRDep}
        downloadName="prestamos-me">
        <ComboChartDual
          data={(() => {
            // Merge prest_me_usd_osd + (prest_tot_osd + tc_fin_mes_osd) → calcula %
            const meMap: Record<string, number> = {}
            const totMap: Record<string, number> = {}
            const tcMap: Record<string, number> = {}
            for (const d of (series.prest_me_usd_osd ?? [])) if (isFinite(d.valor)) meMap[d.fecha.slice(0,7)] = d.valor
            for (const d of (series.prest_tot_osd   ?? [])) if (isFinite(d.valor)) totMap[d.fecha.slice(0,7)] = d.valor
            for (const d of (series.tc_fin_mes_osd  ?? [])) if (isFinite(d.valor)) tcMap[d.fecha.slice(0,7)] = d.valor
            const keys = [...new Set([...Object.keys(meMap), ...Object.keys(totMap)])].sort()
            return keys
              .filter(k => k >= rDep[0] && k <= rDep[1])
              .map(k => {
                const me = meMap[k], tot = totMap[k], tc = tcMap[k]
                if (me == null || tot == null || tot === 0 || tc == null) return null
                const meRd = me * tc  // me_usd × tcn = me_rd
                return { fecha: k, me_usd: me, pct: Math.round((meRd / tot) * 10000) / 100 }
              })
              .filter((d): d is { fecha: string; me_usd: number; pct: number } => d != null)
          })()}
          barKey="me_usd" barLabel="Préstamos ME (MM US$)" barColor={C.blue}
          lineKey="pct"   lineLabel="% del total de cartera" lineColor={C.red}
          yLeftFormatter={v => `${v.toFixed(0)}`}
          yRightFormatter={v => `${v?.toFixed(1) ?? '—'}%`}
          xFormatter={xFmtMonth}
        />
      </ChartWrapper>

      {/* G5 Depósitos del Gobierno en Sistema Financiero (OSD) */}
      <ChartWrapper
        lastValue={(() => { const l = ultimaObs(series.dep_sp_osd); return l ? { label: 'Dep. Gob.', value: l.valor, fecha: xFmtMonth(l.fecha.slice(0,7)), unit: 'MM RD$', valueFormatter: v => `${(v/1000).toFixed(1)}B` } : undefined })()}
        title="Depósitos del Gobierno en el Sistema Financiero"
        subtitle="MM de RD$ y media móvil 12 meses — OSD (Sector Público)"
        from={rDep[0]} to={rDep[1]} isLoading={loading} onRangeChange={onRDep}
        downloadName="dep-gobierno-osd">
        <LineChartSimple
          data={(() => {
            const data = (series.dep_sp_osd ?? []).filter(d => isFinite(d.valor))
            const ma = movingAverage(data, 12)
            const maMap: Record<string, number> = {}
            for (const d of ma) maMap[d.fecha] = d.valor
            return data
              .filter(d => d.fecha.slice(0,7) >= rDep[0] && d.fecha.slice(0,7) <= rDep[1])
              .map(d => ({ fecha: d.fecha.slice(0,7), nivel: d.valor, ma12: maMap[d.fecha] ?? null }))
          })()}
          series={[
            { key: 'nivel', label: 'Depósitos gobierno', color: C.blue, strokeWidth: 2 },
            { key: 'ma12',  label: 'Media móvil 12m',    color: C.red, dashed: true, strokeWidth: 1.5 },
          ]}
          unit="MM RD$" yFormatter={v => `${(v/1000).toFixed(1)}B`}
          xFormatter={xFmtMonth}
        />
      </ChartWrapper>

      {/* G17 Activos Externos Netos — OSD (Activos - Pasivos) */}
      <ChartWrapper title="Activos Externos Netos — Sistema Financiero"
        subtitle="MM US$ = Activos Externos - Pasivos Externos (OSD)"
        from={rDep[0]} to={rDep[1]} isLoading={loading} onRangeChange={onRDep}
        downloadName="aen-osd">
        <LineChartSimple
          data={(() => {
            const actMap: Record<string, number> = {}
            const pasMap: Record<string, number> = {}
            for (const d of (series.aen_osd_act ?? [])) if (isFinite(d.valor)) actMap[d.fecha.slice(0,7)] = d.valor
            for (const d of (series.aen_osd_pas ?? [])) if (isFinite(d.valor)) pasMap[d.fecha.slice(0,7)] = d.valor
            const keys = [...new Set([...Object.keys(actMap), ...Object.keys(pasMap)])].sort()
            return keys
              .filter(k => k >= rDep[0] && k <= rDep[1])
              .map(k => ({
                fecha: k,
                aen: (actMap[k] ?? 0) - (pasMap[k] ?? 0),
                act: actMap[k] ?? null,
                pas: pasMap[k] ?? null,
              }))
          })()}
          series={[
            { key: 'aen', label: 'AEN (neto)', color: C.blue, strokeWidth: 2.5 },
            { key: 'act', label: 'Activos', color: C.green, dashed: true, strokeWidth: 1.5 },
            { key: 'pas', label: 'Pasivos', color: C.red,   dashed: true, strokeWidth: 1.5 },
          ]}
          unit="MM US$" yFormatter={v => `${v.toFixed(0)}`}
          xFormatter={xFmtMonth}
          refLine={0}
        />
      </ChartWrapper>

      {/* G18 Préstamos por sector — % cartera */}
      <ChartWrapper title="Composición Cartera Préstamos por Sector (Sector Privado, MN)"
        subtitle="% del total de préstamos al sector privado en MN — Seleccionar sectores"
        from={rSec[0]} to={rSec[1]} isLoading={loading} onRangeChange={onRSec}
        downloadName="prestamos-por-sector" fullWidth>
        <div className="flex flex-wrap gap-2 mb-3">
          {SECTOR_IDS.map((id, i) => (
            <button key={id}
              onClick={() => setSelectedSectors(prev =>
                prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
              )}
              className="text-[10px] px-2 py-0.5 rounded-full border transition-colors"
              style={{
                borderColor: SECTOR_COLORS[i],
                background: selectedSectors.includes(id) ? SECTOR_COLORS[i] : 'white',
                color: selectedSectors.includes(id) ? 'white' : SECTOR_COLORS[i],
              }}
            >{SECTOR_LABELS[id]}</button>
          ))}
        </div>
        <div style={{ height: 260 }}>
          <LineChartSimple
            data={sectorPct.filter(d => (d.fecha as string) >= rSec[0] && (d.fecha as string) <= rSec[1])}
            series={selectedSectors.map((id, i) => ({
              key: id, label: SECTOR_LABELS[id], color: SECTOR_COLORS[SECTOR_IDS.indexOf(id)],
            }))}
            unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          />
        </div>
      </ChartWrapper>

      {/* G18b — Montos / YoY por sector */}
      <ChartWrapper title="Préstamos por Sector — Montos (Sector Privado, MN)"
        subtitle={montosView === 'nivel'
          ? 'Saldo en MM RD$ · Sector Privado en Moneda Nacional · Seleccionar sectores arriba'
          : 'Crecimiento interanual % · Sector Privado en MN · Seleccionar sectores arriba'}
        from={rSec[0]} to={rSec[1]} onRangeChange={onRSec}
        isLoading={loading} downloadName={`prestamos-sectores-${montosView}`} fullWidth>
        <div className="flex items-center gap-2 mb-2 -mt-1">
          <span className="text-[10px] uppercase tracking-wider font-semibold text-[#6B7280]">Vista:</span>
          {([
            { v: 'nivel', label: 'Nivel (RD$)' },
            { v: 'yoy',   label: 'Crec. interanual %' },
          ] as const).map(({ v, label }) => (
            <button key={v} onClick={() => setMontosView(v)}
              className={[
                'text-[10px] px-2 py-0.5 rounded border transition-colors',
                montosView === v
                  ? 'bg-[#1B3A5C] text-white border-[#1B3A5C]'
                  : 'border-[#D1D9E0] text-[#6B7280] hover:bg-[#EEF0F4]',
              ].join(' ')}>{label}</button>
          ))}
        </div>
        <div style={{ height: 280 }}>
          <LineChartSimple
            data={(() => {
              // Apply YoY transform per series if needed, then merge.
              const seriesData = Object.fromEntries(
                SECTOR_IDS.map(id => {
                  const raw = (series[id] ?? []).filter(d => isFinite(d.valor))
                  const trans = montosView === 'yoy' ? yoyGrowth(raw) : raw
                  return [id, trans]
                })
              )
              return filterMergedByRange(merge(seriesData, selectedSectors), rSec[0], rSec[1])
            })()}
            series={selectedSectors.map((id) => ({
              key: id, label: SECTOR_LABELS[id], color: SECTOR_COLORS[SECTOR_IDS.indexOf(id)],
            }))}
            unit={montosView === 'yoy' ? '%' : 'MM RD$'}
            yFormatter={montosView === 'yoy'
              ? (v => `${v.toFixed(1)}%`)
              : (v => `${(v/1000).toFixed(1)}B`)}
            refLine={montosView === 'yoy' ? 0 : undefined}
          />
        </div>
      </ChartWrapper>
    </div>
  )
}
