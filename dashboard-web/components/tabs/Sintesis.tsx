'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { yoyGrowth, dailyYoYGrowth, monthsAgo } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import LineChartSimple from '@/components/charts/LineChartSimple'
import ComboChartDual from '@/components/charts/ComboChartDual'
import type { SeriesMap, DataPoint } from '@/types'
import { C } from '@/lib/colors'

/* Pestaña-resumen con los 5 indicadores clave del país.
 * Cada chart muestra los últimos N meses según convenga al indicador. */
const ALL_IDS = [
  // IMAE
  'imae',
  // Inflación
  'ipc_yoy', 'ipc_sub',
  // Tasas
  'tpm', 'tia_prom_pond', 'tip_prom_pond',
  // Tipo de cambio (diario para depreciación YoY)
  'tcn_venta',
  // PIB y cuenta corriente
  'pib_nom', 'pib_nom_acum', 'saldo_cc_bp', 'tcn_venta_m',
]

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

const xFmtM = (v: string) => {
  if (!v || v.length < 7) return v
  const [y, m] = v.split('-')
  return `${['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'][+m - 1]}'${y.slice(2)}`
}

const META_INFLACION = 4
const META_BANDA = 1   // ±1 pp

export default function Sintesis() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const today = new Date().toISOString().slice(0, 7)

  useEffect(() => {
    fetchSeries(ALL_IDS, '2010-01-01').then(setSeries).finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(36), today]
  const [r1, onR1] = useRange(def)
  const [r2, onR2] = useRange(def)
  const [r3, onR3] = useRange(def)
  const [r5, onR5] = useRange([monthsAgo(60), today])

  /* ── 1. IMAE — crecimiento interanual ───────────────────────────── */
  const imaeYoY = useMemo(() => {
    const data = (series.imae ?? []).filter(d => isFinite(d.valor))
    return yoyGrowth(data).map(d => ({
      fecha: d.fecha.slice(0, 7),
      valor: Math.round(d.valor * 100) / 100,
    }))
  }, [series.imae])

  /* ── 2. Inflación: general + subyacente + meta 4±1 ──────────────── */
  const inflacionData = useMemo(() => {
    const gen: Record<string, number> = {}
    const sub: Record<string, number> = {}
    for (const d of (series.ipc_yoy ?? [])) if (isFinite(d.valor)) gen[d.fecha.slice(0, 7)] = d.valor
    for (const d of (series.ipc_sub ?? [])) {
      if (isFinite(d.valor)) {
        // ipc_sub puede venir como índice; el YoY se calcula si es índice
      }
    }
    // Calculo YoY de ipc_sub (índice) si no viene como YoY
    const subRaw = (series.ipc_sub ?? []).filter(d => isFinite(d.valor))
    // Detectar: si max(ipc_sub) > 20 es índice → calcular YoY
    const isIndex = subRaw.length > 0 && Math.max(...subRaw.map(d => d.valor)) > 20
    const subYoY = isIndex ? yoyGrowth(subRaw) : subRaw
    const subMap: Record<string, number> = {}
    for (const d of subYoY) subMap[d.fecha.slice(0, 7)] = d.valor

    const keys = [...new Set([...Object.keys(gen), ...Object.keys(subMap)])].sort()
    return keys.map(k => ({
      fecha: k,
      general: gen[k] ?? null,
      subyacente: subMap[k] ?? null,
      meta: META_INFLACION,
      meta_arriba: META_INFLACION + META_BANDA,
      meta_abajo: META_INFLACION - META_BANDA,
    }))
  }, [series.ipc_yoy, series.ipc_sub])

  /* ── 3. Corredor de tasas: TPM, Activa, Pasiva ───────────────────── */
  const corredorData = useMemo(() => {
    const tpmMap: Record<string, number> = {}
    const tiaMap: Record<string, number> = {}
    const tipMap: Record<string, number> = {}
    for (const d of (series.tpm ?? [])) if (isFinite(d.valor)) tpmMap[d.fecha.slice(0, 7)] = d.valor
    for (const d of (series.tia_prom_pond ?? [])) if (isFinite(d.valor)) tiaMap[d.fecha.slice(0, 7)] = d.valor
    for (const d of (series.tip_prom_pond ?? [])) if (isFinite(d.valor)) tipMap[d.fecha.slice(0, 7)] = d.valor
    const keys = [...new Set([...Object.keys(tpmMap), ...Object.keys(tiaMap), ...Object.keys(tipMap)])].sort()
    return keys.map(k => ({
      fecha: k,
      tpm: tpmMap[k] ?? null,
      activa: tiaMap[k] ?? null,
      pasiva: tipMap[k] ?? null,
    }))
  }, [series.tpm, series.tia_prom_pond, series.tip_prom_pond])

  /* ── 4. TCN depreciación interanual: año actual vs año anterior ─── */
  const tcnComparativo = useMemo(() => {
    const tcn = (series.tcn_venta ?? []).filter(d => isFinite(d.valor))
    const depr = dailyYoYGrowth(tcn).filter(d => isFinite(d.valor))
    if (depr.length === 0) return []

    // Tomar el último año disponible y el anterior
    const ultimaFecha = new Date(depr[depr.length - 1].fecha + 'T00:00:00')
    const anioFin = ultimaFecha.getFullYear()
    const anioInicio = anioFin - 1

    // Indexar por (month, day) → valor del año correspondiente
    // X-axis: día del año (1-365). Dos líneas: año actual y año anterior.
    type Punto = { md: string; anio_actual: number | null; anio_anterior: number | null }
    const byMD: Record<string, Punto> = {}
    for (const d of depr) {
      const dt = new Date(d.fecha + 'T00:00:00')
      const md = `${String(dt.getMonth() + 1).padStart(2, '0')}-${String(dt.getDate()).padStart(2, '0')}`
      if (!byMD[md]) byMD[md] = { md, anio_actual: null, anio_anterior: null }
      if (dt.getFullYear() === anioFin) byMD[md].anio_actual = d.valor
      else if (dt.getFullYear() === anioInicio) byMD[md].anio_anterior = d.valor
    }
    return Object.values(byMD).sort((a, b) => a.md.localeCompare(b.md))
  }, [series.tcn_venta])

  const tcnYears = useMemo(() => {
    const tcn = (series.tcn_venta ?? []).filter(d => isFinite(d.valor))
    if (tcn.length === 0) return { actual: '—', anterior: '—' }
    const ultimo = new Date(tcn[tcn.length - 1].fecha + 'T00:00:00')
    return { actual: String(ultimo.getFullYear()), anterior: String(ultimo.getFullYear() - 1) }
  }, [series.tcn_venta])

  /* ── 5. Cuenta corriente: nivel + % PIB ───────────────────────────── */
  const ccData = useMemo(() => {
    const cc = (series.saldo_cc_bp ?? []).filter(d => isFinite(d.valor))
    if (cc.length === 0) return []
    // % PIB anualizado (trailing 4 quarters)
    const pibQ = (series.pib_nom ?? []).filter(d => isFinite(d.valor))
      .sort((a, b) => a.fecha.localeCompare(b.fecha))
    const tcnM: Record<string, number> = {}
    for (const d of (series.tcn_venta_m ?? [])) if (isFinite(d.valor)) tcnM[d.fecha.slice(0, 7)] = d.valor

    // PIB anual trailing 4Q (en RD$M)
    const pibAnualUSD: Record<string, number> = {}
    for (let i = 3; i < pibQ.length; i++) {
      const f = pibQ[i].fecha.slice(0, 7)
      const sum4q = pibQ.slice(i - 3, i + 1).reduce((s, x) => s + x.valor, 0)
      // Convertir a USD: dividir por TCN promedio del año (aproximación: TCN del trimestre)
      const tcn = tcnM[f] ?? Object.values(tcnM).slice(-1)[0]
      if (tcn) pibAnualUSD[f] = sum4q / tcn
    }
    return cc.map(d => {
      const q = d.fecha.slice(0, 7)
      const pibUSD = pibAnualUSD[q]
      return {
        fecha: q,
        nivel: d.valor,    // MM US$
        pct_pib: pibUSD ? Math.round((d.valor / pibUSD) * 1000) / 10 : null,  // %
      }
    })
  }, [series.saldo_cc_bp, series.pib_nom, series.tcn_venta_m])

  const filtRange = <T extends { fecha: string }>(arr: T[], r: [string, string]) =>
    arr.filter(d => d.fecha >= r[0] && d.fecha <= r[1])

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G1 IMAE — crecimiento interanual */}
      <ChartWrapper title="IMAE — Crecimiento Interanual"
        subtitle="Índice Mensual de Actividad Económica (% YoY)"
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="imae-crecimiento">
        <LineChartSimple
          data={filtRange(imaeYoY, r1)}
          series={[{ key: 'valor', label: 'IMAE crecimiento %', color: C.blue, strokeWidth: 2.5 }]}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          xFormatter={xFmtM}
          refLine={0}
        />
      </ChartWrapper>

      {/* G2 Inflación con bandas de meta */}
      <ChartWrapper title="Inflación — General, Subyacente y Meta BCRD"
        subtitle={`Meta BCRD ${META_INFLACION}% ± ${META_BANDA}pp (bandas punteadas)`}
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="inflacion-meta">
        <LineChartSimple
          data={filtRange(inflacionData, r1)}
          series={[
            { key: 'general',     label: 'IPC General (% YoY)',   color: C.blue, strokeWidth: 2.5 },
            { key: 'subyacente',  label: 'IPC Subyacente (% YoY)',color: C.red,  strokeWidth: 2 },
            { key: 'meta',        label: `Meta ${META_INFLACION}%`, color: C.green, dashed: true, strokeWidth: 1.5 },
            { key: 'meta_arriba', label: `Meta + ${META_BANDA}pp`,  color: C.gray,  dashed: true, strokeWidth: 1 },
            { key: 'meta_abajo',  label: `Meta − ${META_BANDA}pp`,  color: C.gray,  dashed: true, strokeWidth: 1 },
          ]}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          xFormatter={xFmtM}
          refLine={0}
        />
      </ChartWrapper>

      {/* G3 Corredor de Tasas — TPM, Activa, Pasiva */}
      <ChartWrapper title="Corredor de Tasas de Interés"
        subtitle="TPM (política monetaria), Activa y Pasiva promedio ponderado"
        from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
        downloadName="corredor-tasas">
        <LineChartSimple
          data={filtRange(corredorData, r2)}
          series={[
            { key: 'activa', label: 'Tasa Activa promedio', color: C.red,   strokeWidth: 2 },
            { key: 'tpm',    label: 'TPM',                  color: C.blue,  strokeWidth: 2.5 },
            { key: 'pasiva', label: 'Tasa Pasiva promedio', color: C.green, strokeWidth: 2 },
          ]}
          unit="%" yFormatter={v => `${v.toFixed(2)}%`}
          xFormatter={xFmtM}
        />
      </ChartWrapper>

      {/* G4 TCN depreciación YoY — Año actual vs año anterior (mismo día del año) */}
      <ChartWrapper title={`TCN Depreciación Interanual — ${tcnYears.actual} vs ${tcnYears.anterior}`}
        subtitle="Comparación vis-a-vis del año en curso contra el anterior"
        hideRange isLoading={loading}
        downloadName="tcn-depreciacion-anio-vs-anio">
        <LineChartSimple
          data={tcnComparativo as unknown as Record<string, string | number>[]}
          xKey="md"
          series={[
            { key: 'anio_anterior', label: `${tcnYears.anterior}`, color: C.gray,  strokeWidth: 1.5, dashed: true },
            { key: 'anio_actual',   label: `${tcnYears.actual}`,   color: C.blue,  strokeWidth: 2.5 },
          ]}
          unit="%" yFormatter={v => `${v.toFixed(1)}%`}
          xFormatter={md => {
            // md = "MM-DD"; mostramos solo el mes
            const m = +md.slice(0, 2)
            const d = +md.slice(3, 5)
            const meses = ['E','F','M','A','M','J','J','A','S','O','N','D']
            return d === 1 ? meses[m - 1] : ''
          }}
          refLine={0}
        />
      </ChartWrapper>

      {/* G5 Cuenta Corriente: nivel + % PIB (combo) */}
      <ChartWrapper title="Cuenta Corriente — Nivel y % del PIB"
        subtitle="Saldo trimestral (MM US$, barras) y % del PIB anualizado (línea, eje der.)"
        from={r5[0]} to={r5[1]} isLoading={loading} onRangeChange={onR5}
        downloadName="cuenta-corriente" fullWidth>
        <ComboChartDual
          data={filtRange(ccData, r5) as unknown as Record<string, string | number>[]}
          barKey="nivel"   barLabel="Cuenta Corriente (MM US$)" barColor={C.blue}
          lineKey="pct_pib" lineLabel="% del PIB anualizado"     lineColor={C.red}
          yLeftFormatter={v => `${v.toFixed(0)}`}
          yRightFormatter={v => v != null ? `${v.toFixed(1)}%` : '—'}
          xFormatter={xFmtM}
        />
      </ChartWrapper>
    </div>
  )
}
