'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { merge, yoyGrowth, filterByRange, filterMergedByRange, momGrowth, dailyYoYGrowth, monthsAgo, xFmtMonth, ultimaObs } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import LineChartSimple from '@/components/charts/LineChartSimple'
import BarChartVert from '@/components/charts/BarChartVert'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { SeriesMap, DataPoint } from '@/types'
import { C } from '@/lib/colors'

const ALL_IDS = ['tcn_compra', 'tcn_venta', 'tcn_compra_m', 'tcn_venta_m', 'tcr_rd',
                 'ipc_rd', 'ipc_eeuu', 'cpi_usa', 'eur_usd']

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

export default function TipoCambio() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const today = new Date().toISOString().slice(0, 7)

  useEffect(() => {
    fetchSeries(ALL_IDS, '2000-01-01').then(setSeries).finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(24), today]
  const [r1, onR1] = useRange(def)
  const [r2, onR2] = useRange(def)
  const [r3, onR3] = useRange(def)
  const [r4, onR4] = useRange(def)
  const [r5, onR5] = useRange(def)

  /* Depreciación interanual diaria */
  const tcnVentaDiaria = series.tcn_venta ?? []
  const deprDiaria = useMemo(() => dailyYoYGrowth(tcnVentaDiaria), [tcnVentaDiaria])
  const tcnDeprDual = useMemo(() => {
    const dMap: Record<string, number> = {}
    for (const d of deprDiaria) dMap[d.fecha.slice(0, 10)] = d.valor
    return tcnVentaDiaria.map((d) => ({
      fecha: d.fecha.slice(0, 10),
      tcn: d.valor,
      depr: dMap[d.fecha.slice(0, 10)] ?? null,
    }))
  }, [tcnVentaDiaria, deprDiaria])

  /* Depreciación mensual */
  const tcnMensual = series.tcn_venta_m ?? []
  const deprMom = useMemo(() => momGrowth(tcnMensual), [tcnMensual])
  const tcnDeprMom = useMemo(() =>
    deprMom.map(d => ({ fecha: d.fecha.slice(0, 7), valor: d.valor })),
    [deprMom])

  /* TCN mensual + depreciación interanual */
  const deprYoYMens = useMemo(() => yoyGrowth(tcnMensual), [tcnMensual])
  const tcnYoYDual = useMemo(() => {
    const yoyMap: Record<string, number> = {}
    for (const d of deprYoYMens) yoyMap[d.fecha.slice(0, 7)] = d.valor
    return tcnMensual.map(d => ({
      fecha: d.fecha.slice(0, 7),
      tcn: d.valor,
      yoy: yoyMap[d.fecha.slice(0, 7)] ?? null,
    }))
  }, [tcnMensual, deprYoYMens])

  /* TCR calculado de la fórmula DGAPF:
   *   TCR = (TCN_venta_m / 1.358727436) × (CPI_USA / 218.076 × 100) / IPC_RD
   * donde:
   *   - 1.358727436 = coeficiente para llevar IPC nuevo base 2019-2020 al base 2010
   *   - 218.076 = promedio CPI USA en 2010 (base reset)
   *   - IPC_RD es el índice general dominicano (no la inflación %)
   *   - CPI_USA viene de FRED CPIAUCSL (mensual)
   * Si falta cualquiera de los 3 inputs para un mes, omitimos esa fecha. */
  const tcrCalc = useMemo(() => {
    const tcnM: Record<string, number> = {}
    for (const d of tcnMensual) if (isFinite(d.valor)) tcnM[d.fecha.slice(0, 7)] = d.valor
    const cpiM: Record<string, number> = {}
    const cpiSrc = (series.cpi_usa && series.cpi_usa.length) ? series.cpi_usa : (series.ipc_eeuu ?? [])
    for (const d of cpiSrc) if (isFinite(d.valor)) cpiM[d.fecha.slice(0, 7)] = d.valor
    const ipcM: Record<string, number> = {}
    for (const d of (series.ipc_rd ?? [])) if (isFinite(d.valor)) ipcM[d.fecha.slice(0, 7)] = d.valor

    const COEF_IPC_RD = 1.358727436   // factor enlace base 2010 → base 2019-2020
    const CPI_USA_2010 = 218.076       // promedio CPI USA 2010
    const out: { fecha: string; valor: number }[] = []
    const monthKeys = [...new Set([...Object.keys(tcnM), ...Object.keys(cpiM), ...Object.keys(ipcM)])].sort()
    for (const k of monthKeys) {
      const tcn = tcnM[k], cpi = cpiM[k], ipc = ipcM[k]
      if (tcn == null || cpi == null || ipc == null) continue
      if (!isFinite(tcn) || !isFinite(cpi) || !isFinite(ipc) || ipc === 0) continue
      const tcr = (tcn / COEF_IPC_RD) * (cpi / CPI_USA_2010 * 100) / ipc
      out.push({ fecha: k + '-01', valor: Math.round(tcr * 100) / 100 })
    }
    return out
  }, [tcnMensual, series.cpi_usa, series.ipc_eeuu, series.ipc_rd])

  /* Para retro-compatibilidad: si Supabase tiene tcr_rd cargado (de un proceso
   * externo) usamos eso; si no, usamos el calculado en vivo. */
  const tcrData = (series.tcr_rd && series.tcr_rd.length) ? series.tcr_rd : tcrCalc
  const tcrDepr = useMemo(() => yoyGrowth(tcrData), [tcrData])
  const tcrMerged = useMemo(() => {
    const deprMap: Record<string, number> = {}
    for (const d of tcrDepr) deprMap[d.fecha.slice(0, 7)] = d.valor
    return tcrData.map(d => ({
      fecha: d.fecha.slice(0, 7), tcr: d.valor, depr: deprMap[d.fecha.slice(0, 7)] ?? null,
    }))
  }, [tcrData, tcrDepr])

  const xFmtM = xFmtMonth

  /* ── Volatilidad TCN (metodología BCRD) ─────────────────────────────
   *   1. r_t = ln(P_t) − ln(P_{t−1})        ← log-returns diarios
   *   2. σ_t = std móvil 260 días de r_t    ← std de los últimos 260 días
   *   3. vol_t = σ_t × 2.33                  ← intervalo de confianza 99%
   * Output en % (multiplicado × 100 para visualización amigable). */
  const volatilidadTCN = useMemo(() => {
    const data = (series.tcn_venta ?? [])
      .filter(d => isFinite(d.valor) && d.valor > 0)
      .slice() // copia
      .sort((a, b) => a.fecha.localeCompare(b.fecha))
    const W = 260
    if (data.length < W + 1) return [] as { fecha: string; valor: number }[]

    // log-returns
    const r: { fecha: string; valor: number }[] = []
    for (let i = 1; i < data.length; i++) {
      r.push({ fecha: data[i].fecha, valor: Math.log(data[i].valor) - Math.log(data[i - 1].valor) })
    }

    // std móvil 260
    const out: { fecha: string; valor: number }[] = []
    for (let i = W - 1; i < r.length; i++) {
      let sum = 0, sumSq = 0
      for (let j = i - W + 1; j <= i; j++) {
        sum += r[j].valor
        sumSq += r[j].valor * r[j].valor
      }
      const mean = sum / W
      const variance = (sumSq - W * mean * mean) / (W - 1)  // sample std
      const std = Math.sqrt(Math.max(0, variance))
      out.push({
        fecha: r[i].fecha,
        valor: Math.round(std * 2.33 * 10000) / 100,  // × 100 para mostrar como %
      })
    }
    return out
  }, [series.tcn_venta])

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G1 TCN diario y depreciación interanual */}
      <ChartWrapper title="Tipo de Cambio Diario y Depreciación Interanual"
        subtitle="Venta (RD$/US$) y tasa de depreciación % — Frecuencia diaria"
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="tcn-diario-depreciacion" fullWidth
        lastValue={(() => { const l = ultimaObs(series.tcn_venta); return l ? { label: 'TCN Venta', value: l.valor, fecha: l.fecha.slice(0,10), unit: 'RD$/US$' } : undefined })()}>
        <ComboChartDual
          data={tcnDeprDual.filter(d => {
            // Comparar mes-a-mes (YYYY-MM) en vez de día-vs-mes para que
            // los últimos días del mes vigente NO queden excluidos.
            const m = d.fecha.slice(0, 7)
            return m >= r1[0] && m <= r1[1]
          })}
          barKey="tcn" barLabel="TCN Venta (RD$/US$)" barColor={C.blue}
          lineKey="depr" lineLabel="Depreciación interanual %" lineColor={C.red}
          yLeftFormatter={v => `${v.toFixed(1)}`}
          yRightFormatter={v => `${v?.toFixed(1)}%`}
          xFormatter={v => v.slice(0, 7)}
        />
      </ChartWrapper>

      {/* G2 Depreciación/apreciación mensual */}
      <ChartWrapper title="Depreciación / Apreciación Mensual del TC"
        subtitle="Variación % mensual del tipo de cambio"
        from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
        downloadName="depreciacion-mensual">
        <BarChartVert
          data={tcnDeprMom.filter(d => d.fecha >= r2[0] && d.fecha <= r2[1])}
          color={C.blue} unit="%"
          xFormatter={xFmtM}
          yFormatter={v => `${v.toFixed(2)}%`}
          label="Depreciación mensual"
        />
      </ChartWrapper>

      {/* G3 TCR calculado con CPI USA (FRED) + IPC RD */}
      <ChartWrapper title="Índice de Tipo de Cambio Real (TCR)"
        subtitle="Calculado: (TCN/1.3587) × (CPI_USA/218.076×100) / IPC_RD"
        from={r3[0]} to={r3[1]} isLoading={loading} onRangeChange={onR3}
        downloadName="tcr-depreciacion"
        lastValue={(() => { const l = ultimaObs(tcrData); return l ? { label: 'TCR', value: l.valor, fecha: xFmtM(l.fecha.slice(0,7)), unit: 'índice' } : undefined })()}>
        <ComboChartDual
          data={tcrMerged.filter(d => d.fecha >= r3[0] && d.fecha <= r3[1])}
          barKey="tcr" barLabel="TCR (Índice)" barColor={C.blue}
          lineKey="depr" lineLabel="Variación interanual %" lineColor={C.red}
          yLeftFormatter={v => `${v.toFixed(1)}`}
          yRightFormatter={v => `${v?.toFixed(1)}%`}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G4 TC promedio mensual + depreciación interanual */}
      <ChartWrapper title="Tipo de Cambio Promedio Mensual y Depreciación Interanual"
        subtitle="TCN venta promedio y variación interanual"
        from={r4[0]} to={r4[1]} isLoading={loading} onRangeChange={onR4}
        downloadName="tcn-mensual-yoy">
        <ComboChartDual
          data={tcnYoYDual.filter(d => d.fecha >= r4[0] && d.fecha <= r4[1])}
          barKey="tcn" barLabel="TCN Venta (RD$/US$)" barColor={C.blue}
          lineKey="yoy" lineLabel="Depreciación interanual %" lineColor={C.red}
          yLeftFormatter={v => `${v.toFixed(2)}`}
          yRightFormatter={v => `${v?.toFixed(1)}%`}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G6 Línea diaria: Tipo de cambio peso/euro (cross con EUR/USD de Yahoo) */}
      {(() => {
        const tcnD = (series.tcn_venta ?? []).filter(d => isFinite(d.valor) && d.valor > 0)
        const eur = (series.eur_usd ?? []).filter(d => isFinite(d.valor) && d.valor > 0)
        const eurMap: Record<string, number> = {}
        for (const d of eur) eurMap[d.fecha.slice(0, 10)] = d.valor
        const cruceEUR: { fecha: string; valor: number }[] = []
        for (const d of tcnD) {
          const ue = eurMap[d.fecha.slice(0, 10)]
          if (ue && isFinite(ue)) {
            cruceEUR.push({ fecha: d.fecha.slice(0, 10), valor: d.valor * ue })
          }
        }
        const last = cruceEUR[cruceEUR.length - 1]
        return (
          <ChartWrapper title="Tipo de Cambio Peso / Euro"
            subtitle="DOP/EUR diario = TCN venta (DOP/USD) × USD/EUR (Yahoo EURUSD=X)"
            from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
            downloadName="tcn-peso-euro"
            lastValue={last
              ? { label: 'Último', value: last.valor, fecha: last.fecha, unit: 'RD$/€',
                  valueFormatter: v => v.toFixed(2) }
              : undefined}>
            <LineChartSimple
              data={cruceEUR.filter(d => d.fecha.slice(0, 7) >= r2[0] && d.fecha.slice(0, 7) <= r2[1])}
              series={[{ key: 'valor', label: 'DOP/EUR', color: C.purple ?? '#9C27B0', strokeWidth: 2 }]}
              unit="RD$/€" yFormatter={v => v.toFixed(2)}
              xFormatter={xFmtM}
            />
          </ChartWrapper>
        )
      })()}

      {/* G5 Volatilidad TCN — metodología BCRD */}
      <ChartWrapper
        title="Volatilidad del Tipo de Cambio (metodología BCRD)"
        subtitle="σ móvil 260 días de ln(P_t) − ln(P_{t−1}), × 2.33 (intervalo confianza 99%)"
        from={r5[0]} to={r5[1]} isLoading={loading} onRangeChange={onR5}
        downloadName="volatilidad-tcn" fullWidth>
        <LineChartSimple
          data={volatilidadTCN
            .filter(d => d.fecha.slice(0, 7) >= r5[0] && d.fecha.slice(0, 7) <= r5[1])
            .map(d => ({ fecha: d.fecha.slice(0, 10), volatilidad: d.valor }))}
          series={[{ key: 'volatilidad', label: 'Volatilidad TCN (%)', color: C.red, strokeWidth: 2 }]}
          unit="%" yFormatter={v => `${v.toFixed(2)}%`}
          xFormatter={v => { const [y, m] = v.split('-'); return `${['E','F','M','A','M','J','J','A','S','O','N','D'][+m-1]}'${y.slice(2)}` }}
        />
      </ChartWrapper>
    </div>
  )
}
