'use client'
import { useEffect, useMemo, useState } from 'react'
import { fetchSeries } from '@/lib/queries'
import { movingAverage, monthsAgo, dailyYoYGrowth } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import LineChartSimple from '@/components/charts/LineChartSimple'
import BarChartVert from '@/components/charts/BarChartVert'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { SeriesMap, DataPoint } from '@/types'
import { C } from '@/lib/colors'

const ALL_IDS = ['deprem_cp', 'tcn_venta', 'ipc_rd']

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

const xFmtDay = (v: string) => {
  if (!v || v.length < 7) return v
  const [y, m, d] = v.split('-')
  return `${d ?? '01'}/${['E','F','M','A','M','J','J','A','S','O','N','D'][+m-1]}/${y.slice(2)}`
}

export default function DepositosRemunerados() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const today = new Date().toISOString().slice(0, 7)

  useEffect(() => {
    fetchSeries(ALL_IDS, '2015-01-01').then(setSeries).finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(24), today]
  const [r1, onR1] = useRange(def)
  const [r2, onR2] = useRange(def)
  const [r3, onR3] = useRange(def)
  const [r4, onR4] = useRange(def)
  // Eje TCN editable para la combo "Depósitos vs TCN" (G4)
  const [tcnMin, setTcnMin] = useState<number>(55)
  const [tcnMax, setTcnMax] = useState<number>(65)

  /* Serie diaria limpia */
  const deprData = useMemo(
    () => (series.deprem_cp ?? []).filter(d => isFinite(d.valor)),
    [series.deprem_cp])

  /* Filtro por rango (mensual prefix) */
  const filtRange = (arr: DataPoint[], r: [string, string]) =>
    arr.filter(d => d.fecha.slice(0, 7) >= r[0] && d.fecha.slice(0, 7) <= r[1])

  /* Resampleo: último valor por mes para visualizaciones mensuales */
  const deprMensual = useMemo(() => {
    const m: Record<string, DataPoint> = {}
    for (const d of deprData) {
      const k = d.fecha.slice(0, 7)
      if (!m[k] || d.fecha > m[k].fecha) m[k] = d
    }
    return Object.values(m).sort((a, b) => a.fecha.localeCompare(b.fecha))
      .map(d => ({ fecha: d.fecha.slice(0, 7) + '-01', valor: d.valor }))
  }, [deprData])

  /* Media móvil 30 días en serie diaria */
  const deprMa30 = useMemo(() => movingAverage(deprData, 30), [deprData])

  /* Combo: nivel + variación interanual diaria */
  const deprYoY = useMemo(() => dailyYoYGrowth(deprData), [deprData])
  const deprCombo = useMemo(() => {
    const ym: Record<string, number> = {}
    for (const d of deprYoY) ym[d.fecha] = d.valor
    return deprData.map(d => ({
      fecha: d.fecha,
      nivel: d.valor,
      yoy: ym[d.fecha] ?? null,
    }))
  }, [deprData, deprYoY])

  /* vs Tipo de Cambio */
  const deprVsTcn = useMemo(() => {
    const tcnMap: Record<string, number> = {}
    for (const d of (series.tcn_venta ?? [])) {
      if (isFinite(d.valor)) tcnMap[d.fecha] = d.valor
    }
    return deprData.map(d => ({
      fecha: d.fecha,
      nivel: d.valor,
      tcn: tcnMap[d.fecha] ?? null,
    })).filter(d => d.tcn != null)
  }, [deprData, series.tcn_venta])

  /* Real (deflactado por IPC, base = primer mes en rango) */
  const deprReal = useMemo(() => {
    const ipcMap: Record<string, number> = {}
    for (const d of (series.ipc_rd ?? [])) {
      if (isFinite(d.valor)) ipcMap[d.fecha.slice(0, 7)] = d.valor
    }
    const ipcBase = Object.values(ipcMap)[0]
    if (!ipcBase) return [] as DataPoint[]
    return deprMensual.map(d => {
      const ipc = ipcMap[d.fecha.slice(0, 7)]
      if (!ipc) return { fecha: d.fecha, valor: NaN }
      return { fecha: d.fecha, valor: d.valor / (ipc / ipcBase) }
    }).filter(d => isFinite(d.valor))
  }, [deprMensual, series.ipc_rd])

  /* Resumen último valor + variaciones */
  const stats = useMemo(() => {
    if (deprData.length < 2) return null
    const last = deprData[deprData.length - 1]
    const prevDay = deprData[deprData.length - 2]
    const prev30 = deprData[deprData.length - 31] ?? deprData[0]
    const prev365 = (() => {
      const t = new Date(last.fecha + 'T00:00:00')
      t.setFullYear(t.getFullYear() - 1)
      const target = t.toISOString().slice(0, 10)
      let best = deprData[0]
      for (const d of deprData) if (d.fecha <= target) best = d
      return best
    })()
    return {
      last,
      dod: ((last.valor - prevDay.valor) / prevDay.valor) * 100,
      mom: ((last.valor - prev30.valor) / prev30.valor) * 100,
      yoy: ((last.valor - prev365.valor) / prev365.valor) * 100,
    }
  }, [deprData])

  const pctFmt = (v: number) => `${v.toFixed(1)}%`

  return (
    <div className="space-y-4">

      {/* KPIs resumen */}
      {stats && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <div className="bg-white rounded-xl border border-[#D1D9E0] p-3 shadow-sm">
            <p className="text-[10px] uppercase text-[#6B7280] font-semibold">Último valor</p>
            <p className="text-[18px] font-bold text-[#1B3A5C] tabular-nums">{(stats.last.valor / 1000).toFixed(2)}<span className="text-[12px] text-[#6B7280] ml-1">MM RD$</span></p>
            <p className="text-[10px] text-[#9CA3AF]">{stats.last.fecha}</p>
          </div>
          <div className="bg-white rounded-xl border border-[#D1D9E0] p-3 shadow-sm">
            <p className="text-[10px] uppercase text-[#6B7280] font-semibold">Var. diaria</p>
            <p className={`text-[18px] font-bold tabular-nums ${stats.dod >= 0 ? 'text-[#2C7A7B]' : 'text-[#8B2E2E]'}`}>{stats.dod >= 0 ? '+' : ''}{stats.dod.toFixed(2)}%</p>
            <p className="text-[10px] text-[#9CA3AF]">vs día anterior</p>
          </div>
          <div className="bg-white rounded-xl border border-[#D1D9E0] p-3 shadow-sm">
            <p className="text-[10px] uppercase text-[#6B7280] font-semibold">Var. mensual</p>
            <p className={`text-[18px] font-bold tabular-nums ${stats.mom >= 0 ? 'text-[#2C7A7B]' : 'text-[#8B2E2E]'}`}>{stats.mom >= 0 ? '+' : ''}{stats.mom.toFixed(2)}%</p>
            <p className="text-[10px] text-[#9CA3AF]">vs hace 30 días</p>
          </div>
          <div className="bg-white rounded-xl border border-[#D1D9E0] p-3 shadow-sm">
            <p className="text-[10px] uppercase text-[#6B7280] font-semibold">Var. interanual</p>
            <p className={`text-[18px] font-bold tabular-nums ${stats.yoy >= 0 ? 'text-[#2C7A7B]' : 'text-[#8B2E2E]'}`}>{stats.yoy >= 0 ? '+' : ''}{stats.yoy.toFixed(2)}%</p>
            <p className="text-[10px] text-[#9CA3AF]">vs hace 12 meses</p>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

        {/* G1 - Serie diaria nivel + MA30 */}
        <ChartWrapper title="Depósitos Remunerados de Corto Plazo"
          subtitle="MM de RD$ — diario con media móvil de 30 días"
          from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
          downloadName="deprem-cp-diario">
          <LineChartSimple
            data={(() => {
              const ma: Record<string, number> = {}
              for (const d of deprMa30) ma[d.fecha] = d.valor
              return filtRange(deprData, r1).map(d => ({
                fecha: d.fecha, nivel: d.valor, ma30: ma[d.fecha] ?? null,
              }))
            })()}
            series={[
              { key: 'nivel', label: 'Nivel diario', color: C.blue, strokeWidth: 1.5 },
              { key: 'ma30',  label: 'Media móvil 30d', color: C.red, dashed: true },
            ]}
            unit="MM RD$" yFormatter={v => `${(v/1000).toFixed(1)}B`}
            xFormatter={xFmtDay}
          />
        </ChartWrapper>

        {/* G2 - Nivel + variación interanual (combo) */}
        <ChartWrapper title="Depósitos Remunerados — Nivel y Variación Interanual"
          subtitle="MM RD$ (barras, eje izq.) y % YoY (línea, eje der.)"
          from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
          downloadName="deprem-cp-combo">
          <ComboChartDual
            data={deprCombo.filter(d => d.fecha.slice(0,7) >= r2[0] && d.fecha.slice(0,7) <= r2[1])}
            barKey="nivel" barLabel="Nivel (MM RD$)" barColor={C.blue}
            lineKey="yoy"  lineLabel="Var. interanual %" lineColor={C.red}
            yLeftFormatter={v => `${(v/1000).toFixed(1)}B`}
            yRightFormatter={v => `${v?.toFixed(1) ?? '—'}%`}
            xFormatter={xFmtDay}
          />
        </ChartWrapper>

        {/* G3 - Real deflactado */}
        <ChartWrapper title="Depósitos Remunerados — Términos Reales"
          subtitle={`Deflactado por IPC RD (base = primer mes del rango)`}
          from={r3[0]} to={r3[1]} isLoading={loading} onRangeChange={onR3}
          downloadName="deprem-cp-real">
          <LineChartSimple
            data={filtRange(deprReal, r3)}
            series={[{ key: 'valor', label: 'Depósitos reales (RD$ deflactados)', color: C.teal, strokeWidth: 2 }]}
            unit="MM RD$" yFormatter={v => `${(v/1000).toFixed(1)}B`}
            xFormatter={v => { const [y,m] = v.split('-'); return `${['E','F','M','A','M','J','J','A','S','O','N','D'][+m-1]}'${y.slice(2)}` }}
          />
        </ChartWrapper>

        {/* G4 - vs TCN — eje TCN ajustable para enfocar la relación visual */}
        <ChartWrapper title="Depósitos Remunerados vs Tipo de Cambio"
          subtitle="Nivel (MM RD$, eje izq.) y TCN Venta (RD$/US$, eje der.)"
          from={r4[0]} to={r4[1]} isLoading={loading} onRangeChange={onR4}
          downloadName="deprem-cp-vs-tcn">
          <div className="flex items-center gap-2 mb-1 -mt-1 text-[10px] text-[#6B7280]">
            <span className="uppercase tracking-wider font-semibold">Eje TCN:</span>
            <span>min</span>
            <input type="number" step="0.5" value={tcnMin}
              onChange={e => setTcnMin(parseFloat(e.target.value) || 0)}
              className="w-14 border border-[#D1D9E0] rounded px-1 py-0.5 text-right tabular-nums" />
            <span>max</span>
            <input type="number" step="0.5" value={tcnMax}
              onChange={e => setTcnMax(parseFloat(e.target.value) || 0)}
              className="w-14 border border-[#D1D9E0] rounded px-1 py-0.5 text-right tabular-nums" />
            <button onClick={() => { setTcnMin(55); setTcnMax(65) }}
              className="ml-1 text-[9px] px-1.5 py-0.5 rounded border border-[#D1D9E0] hover:bg-[#EEF0F4]">reset</button>
          </div>
          <div style={{ height: 280 }}>
            <ComboChartDual
              data={deprVsTcn.filter(d => d.fecha.slice(0,7) >= r4[0] && d.fecha.slice(0,7) <= r4[1])}
              barKey="nivel" barLabel="Depósitos (MM RD$)" barColor={C.blue}
              lineKey="tcn"  lineLabel="TCN Venta (RD$/US$)" lineColor={C.amber}
              yLeftFormatter={v => `${(v/1000).toFixed(1)}B`}
              yRightFormatter={v => `${v?.toFixed(2) ?? '—'}`}
              yRightDomain={[tcnMin, tcnMax]}
              xFormatter={xFmtDay}
            />
          </div>
        </ChartWrapper>
      </div>

      {/* Tabla últimos 30 días */}
      {deprData.length > 0 && (
        <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-4">
          <h3 className="text-[13px] font-semibold text-[#1A202C] mb-3">
            Últimos 30 días — Depósitos Remunerados de Corto Plazo
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full text-[11px]">
              <thead>
                <tr className="bg-[#F0F2F5] text-[#1A202C]">
                  <th className="px-2 py-1.5 text-left font-semibold">Fecha</th>
                  <th className="px-2 py-1.5 text-right font-semibold">Nivel (MM RD$)</th>
                  <th className="px-2 py-1.5 text-right font-semibold">Δ diaria</th>
                  <th className="px-2 py-1.5 text-right font-semibold">Δ desde 1 mes</th>
                </tr>
              </thead>
              <tbody>
                {deprData.slice(-30).reverse().map((d, i, arr) => {
                  const idx = deprData.indexOf(d)
                  const prev = idx > 0 ? deprData[idx - 1] : null
                  const prevM = idx >= 30 ? deprData[idx - 30] : null
                  const dDay = prev ? ((d.valor - prev.valor) / prev.valor) * 100 : null
                  const dMon = prevM ? ((d.valor - prevM.valor) / prevM.valor) * 100 : null
                  return (
                    <tr key={d.fecha} className="border-t border-[#F0F2F5]">
                      <td className="px-2 py-1 text-[#1A202C]">{d.fecha}</td>
                      <td className="px-2 py-1 text-right tabular-nums">{(d.valor/1000).toFixed(2)}B</td>
                      <td className={`px-2 py-1 text-right tabular-nums ${dDay != null ? (dDay >= 0 ? 'text-[#2C7A7B]' : 'text-[#8B2E2E]') : 'text-[#9CA3AF]'}`}>
                        {dDay != null ? `${dDay >= 0 ? '+' : ''}${dDay.toFixed(2)}%` : '—'}
                      </td>
                      <td className={`px-2 py-1 text-right tabular-nums ${dMon != null ? (dMon >= 0 ? 'text-[#2C7A7B]' : 'text-[#8B2E2E]') : 'text-[#9CA3AF]'}`}>
                        {dMon != null ? `${dMon >= 0 ? '+' : ''}${dMon.toFixed(2)}%` : '—'}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
