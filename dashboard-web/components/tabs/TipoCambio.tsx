'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { merge, yoyGrowth, filterByRange, filterMergedByRange, momGrowth, dailyYoYGrowth, monthsAgo, xFmtMonth } from '@/lib/utils'
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
        downloadName="tcn-diario-depreciacion" fullWidth>
        <ComboChartDual
          data={tcnDeprDual.filter(d => d.fecha >= r1[0] && d.fecha <= r1[1])}
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
        downloadName="tcr-depreciacion">
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

      {/* G6 Card: Tipo de cambio peso/euro (cross con EUR/USD de Yahoo) */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-4 flex flex-col">
        <h3 className="text-[13px] font-semibold text-[#1A202C]">Tipo de Cambio Peso / Euro</h3>
        <p className="text-[10px] text-[#6B7280] mb-3">
          Cruce calculado: DOP/EUR = TCN venta (DOP/USD) × USD/EUR (Yahoo EURUSD=X)
        </p>
        {(() => {
          const tcnD = (series.tcn_venta ?? []).filter(d => isFinite(d.valor) && d.valor > 0)
          const eur = (series.eur_usd ?? []).filter(d => isFinite(d.valor) && d.valor > 0)
          if (tcnD.length === 0 || eur.length === 0) {
            return <p className="text-[11px] text-[#9CA3AF] italic">Datos no disponibles</p>
          }
          // Indexar por fecha YYYY-MM-DD para hacer match exacto
          const eurMap: Record<string, number> = {}
          for (const d of eur) eurMap[d.fecha.slice(0, 10)] = d.valor
          // Tomar los últimos N tcn que tengan match con EUR
          const matched: { fecha: string; dop_usd: number; usd_eur: number; dop_eur: number }[] = []
          for (let i = tcnD.length - 1; i >= 0 && matched.length < 30; i--) {
            const f = tcnD[i].fecha.slice(0, 10)
            const usd_eur = eurMap[f]
            if (usd_eur && isFinite(usd_eur)) {
              matched.unshift({
                fecha: f, dop_usd: tcnD[i].valor, usd_eur,
                dop_eur: tcnD[i].valor * usd_eur,
              })
            }
          }
          if (matched.length === 0) {
            return <p className="text-[11px] text-[#9CA3AF] italic">Sin overlap fechas TCN/EUR</p>
          }
          const last = matched[matched.length - 1]
          // Comparación vs hace ~30 días
          const prev = matched[0]
          const deltaPct = ((last.dop_eur - prev.dop_eur) / prev.dop_eur) * 100
          // 12-meses atrás
          const yearAgoDate = new Date(last.fecha)
          yearAgoDate.setFullYear(yearAgoDate.getFullYear() - 1)
          const yearAgoStr = yearAgoDate.toISOString().slice(0, 10)
          // Buscar el match más cercano hace un año
          let yearAgoVal: number | null = null
          for (const d of tcnD) {
            if (d.fecha.slice(0, 10) >= yearAgoStr) {
              const ue = eurMap[d.fecha.slice(0, 10)]
              if (ue) { yearAgoVal = d.valor * ue; break }
            }
          }
          const yoyPct = yearAgoVal ? ((last.dop_eur - yearAgoVal) / yearAgoVal) * 100 : null
          return (
            <div className="flex flex-col gap-4">
              <div className="flex items-baseline gap-2">
                <span className="text-[44px] font-bold text-[#1B3A5C] tabular-nums leading-none">
                  {last.dop_eur.toFixed(2)}
                </span>
                <span className="text-[14px] text-[#6B7280] font-medium">RD$/€</span>
              </div>
              <div className="text-[10px] text-[#9CA3AF]">
                Último: {last.fecha} · TCN venta {last.dop_usd.toFixed(2)} · USD/EUR {last.usd_eur.toFixed(4)}
              </div>
              <table className="w-full text-[11px] mt-1 border-t border-[#F0F2F5] pt-2">
                <tbody>
                  <tr>
                    <td className="py-1 text-[#6B7280]">Variación últimos 30 días</td>
                    <td className="py-1 text-right tabular-nums font-semibold"
                      style={{ color: deltaPct >= 0 ? '#8B2E2E' : '#2C7A7B' }}>
                      {deltaPct >= 0 ? '+' : ''}{deltaPct.toFixed(2)}%
                    </td>
                  </tr>
                  <tr>
                    <td className="py-1 text-[#6B7280]">Variación interanual</td>
                    <td className="py-1 text-right tabular-nums font-semibold"
                      style={{ color: yoyPct == null ? '#9CA3AF' : yoyPct >= 0 ? '#8B2E2E' : '#2C7A7B' }}>
                      {yoyPct == null ? '—' : (yoyPct >= 0 ? '+' : '') + yoyPct.toFixed(2) + '%'}
                    </td>
                  </tr>
                  {[7, 14, 30].map(n => {
                    const idx = Math.max(0, matched.length - 1 - n)
                    const ref = matched[idx]
                    if (!ref) return null
                    return (
                      <tr key={n} className="border-t border-[#F8F9FB]">
                        <td className="py-1 text-[#6B7280]">Hace {n} días</td>
                        <td className="py-1 text-right tabular-nums">{ref.dop_eur.toFixed(2)} RD$/€</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )
        })()}
      </div>

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
