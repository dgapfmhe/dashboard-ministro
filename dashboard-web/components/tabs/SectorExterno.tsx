'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries, fetchWorldBankGDP } from '@/lib/queries'
import { aggregateAnnual, filterByRange, merge, movingAverage, yoyGrowth, monthsAgo, pibTrailing4Q, xFmtMonth, ultimaObs } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import BarChartVert from '@/components/charts/BarChartVert'
import BarChartHoriz, { HBarSeries } from '@/components/charts/BarChartHoriz'
import LineChartSimple from '@/components/charts/LineChartSimple'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { DataPoint, SeriesMap } from '@/types'
import { C } from '@/lib/colors'

const VAR_IDS = ['exp_nom', 'rem_fam', 'se_cc_numtur', 'rin', 'embi_rd', 'embi_global', 'embi_latam', 'pib_nom', 'tcn_venta_m',
  // BoP trimestral - flujos y saldos
  'ied_bp', 'viajes_bp', 'ingr_prim_bp', 'ingr_sec_bp', 'rem_fam_bp_cred', 'x_bp', 'm_bp',
  // BoP - identidad de balance (Fuentes y Usos)
  'saldo_cc_bp', 'bal_bienes_bp', 'bal_serv_bp', 'cta_cap_bp', 'cta_fin_bp',
  'inv_cart_bp', 'eyo_bp', 'act_res_bp']

function useRange(def: [string, string]) {
  const [range, setRange] = useState<[string, string]>(def)
  return [range, (_f: string, _t: string) => setRange([_f, _t])] as const
}

export default function SectorExterno() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [gdpData, setGdpData] = useState<{ country: string; valor: number; anio: string }[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([fetchSeries(VAR_IDS, '1995-01-01'), fetchWorldBankGDP()])
      .then(([s, gdp]) => { setSeries(s); setGdpData(gdp) })
      .finally(() => setLoading(false))
  }, [])

  /* Annual aggregations */
  // exp_nom es trimestral en RD$. Convertimos a USD usando TCN promedio del año
  // antes de sumar anual. Si no hay TCN, queda en RD$ con suffix B.
  const exportAnualUSD = useMemo(() => {
    const tcnMap: Record<string, number[]> = {}
    for (const d of series.tcn_venta_m ?? []) {
      const y = d.fecha.slice(0, 4)
      if (isFinite(d.valor)) (tcnMap[y] ??= []).push(d.valor)
    }
    const usd: { fecha: string; valor: number }[] = []
    for (const d of series.exp_nom ?? []) {
      const y = d.fecha.slice(0, 4)
      const tcns = tcnMap[y]
      const tcn = tcns && tcns.length ? tcns.reduce((s, x) => s + x, 0) / tcns.length : null
      if (tcn && isFinite(d.valor)) {
        usd.push({ fecha: d.fecha, valor: d.valor / tcn })  // RD$M / (RD$/US$) = US$M
      }
    }
    return aggregateAnnual(usd, 'sum')
  }, [series.exp_nom, series.tcn_venta_m])
  const exportAnual = exportAnualUSD
  // rem_fam y se_cc_numtur son MENSUALES en BCRD (frequency=12). Mantenemos
  // versión mensual filtrando valores no-finitos. La agregación anual queda
  // disponible solo para la comparativa de "últimos 2 años" abajo.
  const remMensual = useMemo(
    () => (series.rem_fam ?? [])
      .filter(d => isFinite(d.valor))
      .map(d => ({ fecha: d.fecha.slice(0, 7), valor: d.valor })),
    [series.rem_fam])
  const turMensual = useMemo(
    () => (series.se_cc_numtur ?? [])
      .filter(d => isFinite(d.valor) && d.fecha <= '2026-12-31') // descarta proyecciones
      .map(d => ({ fecha: d.fecha.slice(0, 7), valor: d.valor })),
    [series.se_cc_numtur])
  // Mantengo anuales solo para la tabla comparativa
  const remAnual = useMemo(() => aggregateAnnual(series.rem_fam ?? [], 'sum'), [series.rem_fam])
  const turAnual = useMemo(() => aggregateAnnual(series.se_cc_numtur ?? [], 'sum'), [series.se_cc_numtur])

  /* RIN + % PIB (approx: monthly PIB = quarterly / 3 forward-fill) */
  const rinData = series.rin ?? []
  const pibData = series.pib_nom ?? []
  const tcnData = series.tcn_venta_m ?? []

  // RIN/PIB %: usa el PIB trimestral acumulado (trailing 4Q) en RD$,
  // convertido a USD con el TCN promedio de esos 4 trimestres.
  // Esto resuelve el problema del año en curso (datos incompletos).
  const rinPct = useMemo(() => {
    const tcnMap: Record<string, number> = {}
    for (const d of tcnData) tcnMap[d.fecha.slice(0, 7)] = d.valor
    return rinData.map((d) => {
      const m = d.fecha.slice(0, 7)
      const pib4Q = pibTrailing4Q(pibData, m)
      if (pib4Q == null) return { fecha: d.fecha, valor: NaN }
      const tcn = tcnMap[m] ?? 60
      const pibUSD = pib4Q / tcn  // RD$M trailing 4Q / (RD$/US$) = US$M
      const pct = pibUSD > 0 ? (d.valor / pibUSD) * 100 : 0
      return { fecha: d.fecha, valor: Math.round(pct * 10) / 10 }
    })
  }, [rinData, pibData, tcnData])

  /* EMBI: 3 series diarias (Global, LATAM, RD) — agrupadas a fin de mes */
  const embiMerged = useMemo(() => {
    const byMonth: Record<string, { fecha: string; embi_rd?: number; embi_latam?: number; embi_global?: number }> = {}
    const pickLastOfMonth = (arr: DataPoint[], key: 'embi_rd' | 'embi_latam' | 'embi_global') => {
      // Aggregate to last value per YYYY-MM
      const grouped: Record<string, { fecha: string; valor: number }> = {}
      for (const d of arr) {
        if (!isFinite(d.valor)) continue
        const m = d.fecha.slice(0, 7)
        if (!grouped[m] || d.fecha > grouped[m].fecha) grouped[m] = d
      }
      for (const [m, d] of Object.entries(grouped)) {
        if (!byMonth[m]) byMonth[m] = { fecha: m }
        byMonth[m][key] = d.valor
      }
    }
    pickLastOfMonth(series.embi_rd ?? [], 'embi_rd')
    pickLastOfMonth(series.embi_latam ?? [], 'embi_latam')
    pickLastOfMonth(series.embi_global ?? [], 'embi_global')
    return Object.values(byMonth).sort((a, b) => a.fecha.localeCompare(b.fecha))
  }, [series.embi_rd, series.embi_latam, series.embi_global])

  /* Comparativa Indicadores Externos: 3 columnas
   *   - Año-2 (completo: ej 2024)
   *   - Año-1 (completo: ej 2025)
   *   - Año vigente (parcial: ej 2026 hasta Q1/Q2/Q3 disponible)
   * Para el año parcial se indica hasta qué mes/trimestre hay datos.
   * - Exportaciones (trimestral): suma de los Q acumulados
   * - Remesas (mensual): suma de meses acumulados
   * - RIN (mensual stock): último valor disponible */
  const hbarComp = useMemo(() => {
    const cy = new Date().getFullYear()
    const yrPrev2 = String(cy - 2)
    const yrPrev1 = String(cy - 1)
    const yrCurr  = String(cy)

    const sumByYear = (arr: DataPoint[] | undefined): Record<string, { suma: number; n: number; ultMes: number }> => {
      if (!arr) return {}
      const m: Record<string, { suma: number; n: number; ultMes: number }> = {}
      for (const d of arr) {
        if (!isFinite(d.valor)) continue
        const y = d.fecha.slice(0, 4)
        const mn = parseInt(d.fecha.slice(5, 7), 10)
        if (!m[y]) m[y] = { suma: 0, n: 0, ultMes: 0 }
        m[y].suma += d.valor
        m[y].n += 1
        if (mn > m[y].ultMes) m[y].ultMes = mn
      }
      return m
    }
    const lastByYear = (arr: DataPoint[] | undefined): Record<string, { valor: number; ultMes: number }> => {
      if (!arr) return {}
      const m: Record<string, { valor: number; fecha: string; ultMes: number }> = {}
      const sorted = [...arr].sort((a, b) => a.fecha.localeCompare(b.fecha))
      for (const d of sorted) {
        if (!isFinite(d.valor)) continue
        const y = d.fecha.slice(0, 4)
        const mn = parseInt(d.fecha.slice(5, 7), 10)
        if (!m[y] || d.fecha > m[y].fecha) {
          m[y] = { valor: d.valor, fecha: d.fecha, ultMes: mn }
        }
      }
      return Object.fromEntries(Object.entries(m).map(([k, v]) => [k, { valor: v.valor, ultMes: v.ultMes }]))
    }

    // exp_nom es trimestral en RD$ → exportAnualUSD ya tiene el sum en USD por año
    const expByYear: Record<string, { suma: number; ultMes: number }> = {}
    for (const d of exportAnualUSD) {
      expByYear[d.fecha.slice(0, 4)] = { suma: d.valor, ultMes: 12 }
    }
    // Para 2026 (parcial), recalculamos solo con los Q disponibles
    const expRaw = series.exp_nom ?? []
    const tcnMap: Record<string, number[]> = {}
    for (const d of series.tcn_venta_m ?? []) {
      const y = d.fecha.slice(0, 4)
      if (isFinite(d.valor)) (tcnMap[y] ??= []).push(d.valor)
    }
    const expCurr: { suma: number; ultMes: number } = { suma: 0, ultMes: 0 }
    for (const d of expRaw) {
      if (!isFinite(d.valor)) continue
      const y = d.fecha.slice(0, 4)
      if (y !== yrCurr) continue
      const tcns = tcnMap[y]
      const tcn = tcns && tcns.length ? tcns.reduce((s, x) => s + x, 0) / tcns.length : null
      if (tcn) {
        expCurr.suma += d.valor / tcn
        const mn = parseInt(d.fecha.slice(5, 7), 10)
        if (mn > expCurr.ultMes) expCurr.ultMes = mn
      }
    }
    if (expCurr.suma > 0) expByYear[yrCurr] = expCurr

    const remByYear = sumByYear(series.rem_fam)
    const rinByYear = lastByYear(series.rin)
    const ultMesToLabel = (mes: number, sumOrStock: 'sum' | 'stock'): string => {
      if (mes >= 12) return ''
      if (sumOrStock === 'stock') return `hasta ${['','Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov'][mes] ?? ''}`
      const q = Math.ceil(mes / 3)
      return `Acum. Q${q} (${mes}m)`
    }

    const rows: Array<Record<string, string | number>> = [
      {
        nombre: 'Exportaciones (US$M)',
        [yrPrev2]: expByYear[yrPrev2]?.suma ?? 0,
        [yrPrev1]: expByYear[yrPrev1]?.suma ?? 0,
        [yrCurr]:  expByYear[yrCurr]?.suma ?? 0,
        _nota_curr: expByYear[yrCurr] ? ultMesToLabel(expByYear[yrCurr]!.ultMes, 'sum') : '',
      },
      {
        nombre: 'Remesas (US$M)',
        [yrPrev2]: remByYear[yrPrev2]?.suma ?? 0,
        [yrPrev1]: remByYear[yrPrev1]?.suma ?? 0,
        [yrCurr]:  remByYear[yrCurr]?.suma ?? 0,
        _nota_curr: remByYear[yrCurr] ? ultMesToLabel(remByYear[yrCurr]!.ultMes, 'sum') : '',
      },
      {
        nombre: 'RIN (US$M, stock fin año)',
        [yrPrev2]: rinByYear[yrPrev2]?.valor ?? 0,
        [yrPrev1]: rinByYear[yrPrev1]?.valor ?? 0,
        [yrCurr]:  rinByYear[yrCurr]?.valor ?? 0,
        _nota_curr: rinByYear[yrCurr] ? ultMesToLabel(rinByYear[yrCurr]!.ultMes, 'stock') : '',
      },
    ]
    return { rows, yrPrev2, yrPrev1, yrCurr }
  }, [exportAnualUSD, series.exp_nom, series.tcn_venta_m, series.rem_fam, series.rin])

  const hbarData = hbarComp.rows
  const hbarSeries: HBarSeries[] = [
    { key: hbarComp.yrPrev2, label: hbarComp.yrPrev2, color: C.gray },
    { key: hbarComp.yrPrev1, label: hbarComp.yrPrev1, color: C.blue },
    { key: hbarComp.yrCurr,  label: hbarComp.yrCurr,  color: C.lightBlue },
  ]

  /* RIN dual-axis data. Excluyo entradas con RIN no-finito o sin %PIB
   * disponible, así recharts no pinta caídas a 0 en los meses sin PIB. */
  const rinDual = useMemo(
    () => rinData
      .map((d, i) => ({ d, pct: rinPct[i]?.valor }))
      .filter(({ d, pct }) => isFinite(d.valor) && pct != null && isFinite(pct))
      .map(({ d, pct }) => ({
        fecha: d.fecha.slice(0, 7),
        rin: d.valor,
        pct: pct as number,
      })),
    [rinData, rinPct],
  )

  const today = new Date().toISOString().slice(0, 7)
  const defMes: [string, string] = [monthsAgo(24), today]    // mensual: 2 años (datos recientes)
  const defAnio: [string, string] = [monthsAgo(120), today]  // anual: 10 años
  const [r1, onR1] = useRange(defMes)                        // RIN dual
  const [r2, onR2] = useRange(defMes)                        // EMBI
  const [rExp, onRExp] = useRange(defAnio)                   // Export anual (trimestral)
  const [rRem, onRRem] = useRange(defMes)                    // Remesas MENSUAL
  const [rTur, onRTur] = useRange(defMes)                    // Turistas MENSUAL
  const filtA = (arr: { fecha: string; valor: number }[], r: [string, string]) =>
    arr.filter(d => d.fecha.slice(0, 7) >= r[0] && d.fecha.slice(0, 7) <= r[1])
  const xFmtMon = xFmtMonth

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G1 Exportaciones */}
      <ChartWrapper title="Exportaciones Totales" subtitle="MM de US$, acumulado anual"
        from={rExp[0]} to={rExp[1]} onRangeChange={onRExp}
        isLoading={loading} downloadName="exportaciones-totales"
        lastValue={(() => { const l = ultimaObs(exportAnual); return l ? { label: 'Último año', value: l.valor, fecha: l.fecha.slice(0,4), unit: 'MM US$', valueFormatter: v => `${(v/1000).toFixed(2)}B` } : undefined })()}>
        <BarChartVert data={filtA(exportAnual, rExp)} color={C.blue} unit="MM US$"
          yFormatter={(v) => `${(v / 1000).toFixed(1)}B`} xFormatter={(v) => v.slice(0, 4)} />
      </ChartWrapper>

      {/* G2 Remesas — MENSUAL */}
      <ChartWrapper title="Remesas Familiares" subtitle="MM de US$ — mensual (BCRD)"
        from={rRem[0]} to={rRem[1]} onRangeChange={onRRem}
        isLoading={loading} downloadName="remesas-mensual"
        lastValue={(() => { const l = ultimaObs(remMensual); return l ? { label: 'Último', value: l.valor, fecha: xFmtMon(l.fecha), unit: 'MM US$' } : undefined })()}>
        <BarChartVert data={filtA(remMensual, rRem)} color={C.lightBlue} unit="MM US$"
          yFormatter={(v) => `${v.toFixed(0)}`} xFormatter={xFmtMon}
          label="Remesas familiares" />
      </ChartWrapper>

      {/* G3 IED — Balanza de Pagos (trimestral, MM US$) */}
      <ChartWrapper title="Inversión Extranjera Directa (IED)"
        subtitle="MM de US$ — Cuenta Financiera BoP (trimestral, BCRD)"
        from={rRem[0]} to={rRem[1]} onRangeChange={onRRem}
        isLoading={loading} downloadName="ied-bp"
        lastValue={(() => { const l = ultimaObs(series.ied_bp); return l ? { label: 'Último Q', value: l.valor, fecha: xFmtMon(l.fecha), unit: 'MM US$' } : undefined })()}>
        <BarChartVert
          data={(series.ied_bp ?? [])
            .filter(d => isFinite(d.valor) && d.fecha.slice(0,7) >= rRem[0] && d.fecha.slice(0,7) <= rRem[1])
            .map(d => ({ fecha: d.fecha.slice(0,7), valor: d.valor }))}
          color={C.purple} unit="MM US$"
          xFormatter={xFmtMon}
          yFormatter={v => `${v.toFixed(0)}`}
          label="IED" />
      </ChartWrapper>

      {/* G4 Ingresos por Turismo — Viajes BoP (trimestral) */}
      <ChartWrapper title="Ingresos por Turismo"
        subtitle="MM de US$ — Viajes (BoP, trimestral, BCRD)"
        from={rTur[0]} to={rTur[1]} onRangeChange={onRTur}
        isLoading={loading} downloadName="ingresos-turismo-bp"
        lastValue={(() => { const l = ultimaObs(series.viajes_bp); return l ? { label: 'Último Q', value: l.valor, fecha: xFmtMon(l.fecha), unit: 'MM US$' } : undefined })()}>
        <BarChartVert
          data={(series.viajes_bp ?? [])
            .filter(d => isFinite(d.valor) && d.fecha.slice(0,7) >= rTur[0] && d.fecha.slice(0,7) <= rTur[1])
            .map(d => ({ fecha: d.fecha.slice(0,7), valor: d.valor }))}
          color={C.teal} unit="MM US$"
          xFormatter={xFmtMon}
          yFormatter={v => `${v.toFixed(0)}`}
          label="Ingresos viajes" />
      </ChartWrapper>

      {/* G5 Llegada No Residentes — MENSUAL */}
      <ChartWrapper title="Llegada de No Residentes" subtitle="Personas — mensual (BCRD)"
        from={rTur[0]} to={rTur[1]} onRangeChange={onRTur}
        isLoading={loading} downloadName="llegada-turistas-mensual"
        lastValue={(() => { const l = ultimaObs(turMensual); return l ? { label: 'Último', value: l.valor / 1000, fecha: xFmtMon(l.fecha), unit: 'k personas', valueFormatter: v => v.toFixed(0) } : undefined })()}>
        <BarChartVert
          data={filtA(turMensual, rTur).map(d => ({ ...d, valor: d.valor / 1000 }))}
          color={C.teal} unit="miles personas"
          xFormatter={xFmtMon}
          yFormatter={(v) => `${v.toFixed(0)}k`}
          label="Llegada turistas" />
      </ChartWrapper>

      {/* G6 Indicadores externos comparativos — TABLA limpia 3 años */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-4 flex flex-col">
        <h3 className="text-[13px] font-semibold text-[#1A202C]">
          Indicadores Externos — {hbarComp.yrPrev2} · {hbarComp.yrPrev1} · {hbarComp.yrCurr} (parcial)
        </h3>
        <p className="text-[10px] text-[#6B7280] mb-3">
          Sumas anuales para flujos (Exportaciones, Remesas) y stock al cierre para RIN.
          El año vigente muestra hasta los datos disponibles (parcial).
        </p>
        <div className="overflow-x-auto">
          <table className="w-full text-[11px]">
            <thead>
              <tr className="bg-[#F0F2F5] text-[#1A202C]">
                <th className="px-3 py-2 text-left font-semibold">Indicador</th>
                <th className="px-3 py-2 text-right font-semibold">{hbarComp.yrPrev2}</th>
                <th className="px-3 py-2 text-right font-semibold">{hbarComp.yrPrev1}</th>
                <th className="px-3 py-2 text-right font-semibold">{hbarComp.yrCurr} <span className="font-normal text-[#6B7280]">(parcial)</span></th>
                <th className="px-3 py-2 text-right font-semibold">Cobertura {hbarComp.yrCurr}</th>
              </tr>
            </thead>
            <tbody>
              {hbarData.map((r, i) => {
                const nombre = r.nombre as string
                const v_prev2 = r[hbarComp.yrPrev2] as number
                const v_prev1 = r[hbarComp.yrPrev1] as number
                const v_curr  = r[hbarComp.yrCurr]  as number
                const nota = r._nota_curr as string
                const fmtB = (v: number) => v >= 1000 ? `${(v/1000).toFixed(2)} B` : `${v.toFixed(0)} M`
                return (
                  <tr key={i} className="border-t border-[#F0F2F5]">
                    <td className="px-3 py-2 text-[#1A202C] font-medium">{nombre}</td>
                    <td className="px-3 py-2 text-right tabular-nums">{fmtB(v_prev2)}</td>
                    <td className="px-3 py-2 text-right tabular-nums font-semibold">{fmtB(v_prev1)}</td>
                    <td className="px-3 py-2 text-right tabular-nums text-[#1B3A5C] font-semibold">{fmtB(v_curr)}</td>
                    <td className="px-3 py-2 text-right text-[10px] text-[#6B7280] italic">{nota || '—'}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <p className="text-[10px] text-[#9CA3AF] italic mt-3">
          Exportaciones: trimestral exp_nom (BCRD) convertido a USD via TCN venta promedio del año ·
          Remesas: rem_fam (BCRD, mensual) · RIN: rin último valor del año (stock)
        </p>
      </div>

      {/* G7 PIB por países */}
      <ChartWrapper title="Crecimiento del PIB por País / Región"
        subtitle={(() => {
          if (gdpData.length === 0) return 'Último año disponible — Banco Mundial'
          const years = [...new Set(gdpData.map(d => d.anio))].sort()
          const yr = years.length === 1 ? years[0] : `${years[0]}–${years[years.length - 1]}`
          return `Último año disponible: ${yr} — Banco Mundial`
        })()}
        hideRange isLoading={loading} downloadName="pib-paises">
        <BarChartVert
          data={gdpData.map(d => ({ fecha: `${d.country} (${d.anio})`, valor: d.valor }))}
          color={C.blue} unit="%"
          xFormatter={(v) => v}
          yFormatter={(v) => `${v.toFixed(1)}%`}
          label="Crecimiento PIB"
        />
      </ChartWrapper>

      {/* G8 RIN dual axis */}
      <ChartWrapper title="Reservas Internacionales Netas"
        subtitle="Nivel (MM US$, eje izq.) y % del PIB (eje der.)"
        from={r1[0]} to={r1[1]} onRangeChange={onR1}
        isLoading={loading} downloadName="rin-nivel-pib">
        <ComboChartDual
          data={rinDual.filter(d => d.fecha >= r1[0] && d.fecha <= r1[1])}
          barKey="rin" barLabel="RIN (MM US$)" barColor={C.blue}
          lineKey="pct" lineLabel="% del PIB" lineColor={C.red}
          yLeftFormatter={(v) => `${v.toFixed(0)}M`}
          yRightFormatter={(v) => `${v.toFixed(1)}%`}
          xFormatter={xFmtMonth}
        />
      </ChartWrapper>

      {/* G9 RIN comparativo 2 años */}
      <ChartWrapper title="Reservas Internacionales — Comparación Últimos 2 Años"
        subtitle="Nivel (MM US$) y % del PIB"
        hideRange isLoading={loading} downloadName="rin-comparacion">
        {(() => {
          const annual = aggregateAnnual(series.rin ?? [], 'last')
          const pctAnnual = aggregateAnnual(rinPct, 'last')
          const yr1 = annual[annual.length - 2]?.fecha?.slice(0, 4) ?? 'Año-1'
          const yr2 = annual[annual.length - 1]?.fecha?.slice(0, 4) ?? 'Año'
          const data = [
            { nombre: 'Nivel (MM US$)', [yr1]: annual[annual.length - 2]?.valor ?? 0, [yr2]: annual[annual.length - 1]?.valor ?? 0 },
            { nombre: '% del PIB',      [yr1]: pctAnnual[pctAnnual.length - 2]?.valor ?? 0, [yr2]: pctAnnual[pctAnnual.length - 1]?.valor ?? 0 },
          ]
          const s: HBarSeries[] = [{ key: yr1, label: yr1, color: C.blue }, { key: yr2, label: yr2, color: C.lightBlue }]
          return <BarChartHoriz data={data} series={s} />
        })()}
      </ChartWrapper>

      {/* G10 EMBI histórico — Global, LATAM y RD */}
      <ChartWrapper title="EMBI — Serie Histórica" subtitle="Riesgo soberano (último valor del mes)"
        from={r2[0]} to={r2[1]} onRangeChange={onR2}
        isLoading={loading}
        downloadName="embi-historico"
        fullWidth>
        <LineChartSimple
          data={embiMerged.filter(d => d.fecha >= r2[0] && d.fecha <= r2[1])}
          series={[
            { key: 'embi_global', label: 'EMBI Global', color: C.gray,  strokeWidth: 2 },
            { key: 'embi_latam',  label: 'EMBI LATAM',  color: C.amber, strokeWidth: 2 },
            { key: 'embi_rd',     label: 'EMBI RD',     color: C.red,   strokeWidth: 2.5 },
          ]}
          unit=""
          yFormatter={(v) => v.toFixed(2)}
        />
      </ChartWrapper>

      {/* Tabla 1 — Identidad de Balanza de Pagos (BoP cierra a ~0 vía MBP6) */}
      <div className="col-span-full bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-4">
        <h3 className="text-[13px] font-semibold text-[#1A202C] mb-1">
          Tabla 1 — Identidad de la Balanza de Pagos (MM US$)
        </h3>
        <p className="text-[10px] text-[#6B7280] mb-3 font-mono">
          Cuenta Corriente + Cuenta Capital + Cuenta Financiera (entrada neta) + Errores y Omisiones − Δ Reservas ≡ 0
        </p>
        {(() => {
          const sumByYear = (arr?: DataPoint[]) => {
            if (!arr) return {} as Record<string, number>
            const m: Record<string, number> = {}
            for (const d of arr) {
              if (!isFinite(d.valor)) continue
              const y = d.fecha.slice(0, 4)
              m[y] = (m[y] ?? 0) + d.valor
            }
            return m
          }
          const cc        = sumByYear(series.saldo_cc_bp)
          const balB      = sumByYear(series.bal_bienes_bp)
          const balS      = sumByYear(series.bal_serv_bp)
          const ingrPrim  = sumByYear(series.ingr_prim_bp)
          const ingrSec   = sumByYear(series.ingr_sec_bp)
          const ka        = sumByYear(series.cta_cap_bp)
          const fa        = sumByYear(series.cta_fin_bp)   // ya flipped (+ = entrada)
          const ied       = sumByYear(series.ied_bp)
          const invCart   = sumByYear(series.inv_cart_bp)
          const eo        = sumByYear(series.eyo_bp)
          const dRes      = sumByYear(series.act_res_bp)

          const years = [...new Set([
            ...Object.keys(cc), ...Object.keys(fa), ...Object.keys(dRes)
          ])].sort()
          const yr1 = years[years.length - 2]
          const yr2 = years[years.length - 1]
          if (!yr1 || !yr2) {
            return <p className="text-[11px] text-[#9CA3AF] italic">Sin datos suficientes.</p>
          }
          const fmt = (n: number | undefined) =>
            n == null || !isFinite(n) ? '—' : `${n >= 0 ? '+' : ''}${n.toFixed(0)}`

          const otraInvFA1 = (fa[yr1] ?? 0) - (ied[yr1] ?? 0) - (invCart[yr1] ?? 0)
          const otraInvFA2 = (fa[yr2] ?? 0) - (ied[yr2] ?? 0) - (invCart[yr2] ?? 0)

          // Identidad: CC + KA + FA + EO − ΔRes
          const check1 = (cc[yr1] ?? 0) + (ka[yr1] ?? 0) + (fa[yr1] ?? 0) + (eo[yr1] ?? 0) - (dRes[yr1] ?? 0)
          const check2 = (cc[yr2] ?? 0) + (ka[yr2] ?? 0) + (fa[yr2] ?? 0) + (eo[yr2] ?? 0) - (dRes[yr2] ?? 0)

          type Row = { label: string; subtotal?: boolean; bold?: boolean; y1?: number; y2?: number; }
          const rows: Row[] = [
            { label: '1. CUENTA CORRIENTE',                   subtotal: true, y1: cc[yr1], y2: cc[yr2] },
            { label: '  Balanza de bienes (X−M)',             y1: balB[yr1], y2: balB[yr2] },
            { label: '  Balanza de servicios (turismo, etc.)', y1: balS[yr1], y2: balS[yr2] },
            { label: '  Ingreso primario (rentas, neto)',     y1: ingrPrim[yr1], y2: ingrPrim[yr2] },
            { label: '  Ingreso secundario (remesas, transf.)', y1: ingrSec[yr1], y2: ingrSec[yr2] },
            { label: '2. CUENTA DE CAPITAL',                  subtotal: true, y1: ka[yr1], y2: ka[yr2] },
            { label: '3. CUENTA FINANCIERA (entrada neta)',   subtotal: true, y1: fa[yr1], y2: fa[yr2] },
            { label: '  IED (Inversión Extranjera Directa)',  y1: ied[yr1], y2: ied[yr2] },
            { label: '  Inversión de cartera',                y1: invCart[yr1], y2: invCart[yr2] },
            { label: '  Otra inversión (deuda + dep.)',       y1: otraInvFA1, y2: otraInvFA2 },
            { label: '4. ERRORES Y OMISIONES',                subtotal: true, y1: eo[yr1], y2: eo[yr2] },
            { label: '5. − Δ RESERVAS (acumulación)',         subtotal: true, y1: -(dRes[yr1] ?? 0), y2: -(dRes[yr2] ?? 0) },
            { label: 'SUMA IDENTIDAD (1+2+3+4+5)',            bold: true, y1: check1, y2: check2 },
          ]
          return (
            <div className="overflow-x-auto">
              <table className="w-full text-[11px]">
                <thead>
                  <tr className="bg-[#F0F2F5] text-[#1A202C]">
                    <th className="px-2 py-1.5 text-left font-semibold">Concepto</th>
                    <th className="px-2 py-1.5 text-right font-semibold">{yr1}</th>
                    <th className="px-2 py-1.5 text-right font-semibold">{yr2}</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((r, i) => {
                    const cls = r.bold
                      ? 'border-t-2 border-[#1B3A5C] bg-[#EEF0F4] font-bold text-[#1B3A5C]'
                      : r.subtotal
                        ? 'border-t border-[#F0F2F5] bg-[#F8F9FB] font-semibold text-[#1B3A5C]'
                        : 'border-t border-[#F0F2F5]'
                    return (
                      <tr key={i} className={cls}>
                        <td className="px-2 py-1">{r.label}</td>
                        <td className="px-2 py-1 text-right tabular-nums">{fmt(r.y1)}</td>
                        <td className="px-2 py-1 text-right tabular-nums">{fmt(r.y2)}</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
              <p className="text-[10px] text-[#9CA3AF] italic mt-2">
                La suma debe ser ≈ 0 por construcción del MBP6 (FMI 6ª ed.). Residuos pequeños son por redondeo al sumar trimestres.
              </p>
            </div>
          )
        })()}
      </div>
    </div>
  )
}
