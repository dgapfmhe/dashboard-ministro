import type { DataPoint, MergedPoint } from '@/types'

export function movingAverage(data: DataPoint[], window: number): DataPoint[] {
  return data.map((d, i) => {
    const start = Math.max(0, i - window + 1)
    const slice = data.slice(start, i + 1)
    const avg = slice.reduce((s, p) => s + p.valor, 0) / slice.length
    return { fecha: d.fecha, valor: Math.round(avg * 100) / 100 }
  })
}

export function yoyGrowth(data: DataPoint[]): DataPoint[] {
  return data
    .map((d, i) => {
      const prev = data[i - 12]
      if (!prev || prev.valor === 0) return null
      return { fecha: d.fecha, valor: Math.round(((d.valor / prev.valor - 1) * 100) * 100) / 100 }
    })
    .filter(Boolean) as DataPoint[]
}

export function dailyYoYGrowth(data: DataPoint[]): DataPoint[] {
  // Match each point to the closest data point ~365 days earlier (by date).
  const byDate: Record<string, number> = {}
  for (const d of data) byDate[d.fecha.slice(0, 10)] = d.valor
  return data
    .map((d) => {
      const dt = new Date(d.fecha + 'T00:00:00')
      dt.setFullYear(dt.getFullYear() - 1)
      const target = dt.toISOString().slice(0, 10)
      let prev: number | undefined = byDate[target]
      if (prev === undefined) {
        // Find the closest prior date within ±15 days
        for (let k = 1; k <= 15 && prev === undefined; k++) {
          const a = new Date(dt); a.setDate(a.getDate() - k)
          const b = new Date(dt); b.setDate(b.getDate() + k)
          prev = byDate[a.toISOString().slice(0, 10)] ?? byDate[b.toISOString().slice(0, 10)]
        }
      }
      if (prev === undefined || prev === 0) return null
      return { fecha: d.fecha, valor: Math.round(((d.valor / prev - 1) * 100) * 100) / 100 }
    })
    .filter(Boolean) as DataPoint[]
}

export function momGrowth(data: DataPoint[]): DataPoint[] {
  return data
    .map((d, i) => {
      const prev = data[i - 1]
      if (!prev || prev.valor === 0) return null
      return { fecha: d.fecha, valor: Math.round(((d.valor / prev.valor - 1) * 100) * 100) / 100 }
    })
    .filter(Boolean) as DataPoint[]
}

/**
 * PIB anual acumulado: suma de los 4 trimestres del año.
 * Devuelve un map `{ '2023': 5678.9, '2024': null, ... }` con valor solo
 * para años completos (4 trimestres presentes). Para años incompletos
 * (típicamente el año en curso), devuelve `null`.
 */
export function pibAnualPorAnio(trimestral: DataPoint[]): Record<string, number | null> {
  const byYear: Record<string, number[]> = {}
  for (const d of trimestral) {
    if (d.valor == null || !isFinite(d.valor)) continue
    const y = d.fecha.slice(0, 4)
    ;(byYear[y] ??= []).push(d.valor)
  }
  const out: Record<string, number | null> = {}
  for (const [y, vals] of Object.entries(byYear)) {
    out[y] = vals.length >= 4 ? vals.reduce((s, x) => s + x, 0) : null
  }
  return out
}

/**
 * PIB acumulado anual con TRAILING 4 trimestres a partir de una fecha-mes.
 * Para una fecha `2025-08`, devuelve la suma de los 4 trimestres más
 * recientes cuya fecha sea <= ese mes. Útil para calcular ratios mensuales
 * cuando el año en curso no está completo.
 */
export function pibTrailing4Q(trimestral: DataPoint[], hastaMes: string): number | null {
  const previos = trimestral
    .filter(d => d.valor != null && isFinite(d.valor) && d.fecha.slice(0, 7) <= hastaMes)
    .sort((a, b) => a.fecha.localeCompare(b.fecha))
  if (previos.length < 4) return null
  const last4 = previos.slice(-4)
  return last4.reduce((s, x) => s + x.valor, 0)
}

export function aggregateAnnual(
  data: DataPoint[],
  method: 'sum' | 'avg' | 'last' = 'sum',
): DataPoint[] {
  const byYear: Record<string, number[]> = {}
  for (const d of data) {
    const year = d.fecha.slice(0, 4)
    if (!byYear[year]) byYear[year] = []
    byYear[year].push(d.valor)
  }
  return Object.entries(byYear).map(([year, vals]) => {
    let valor = 0
    if (method === 'sum') valor = vals.reduce((a, b) => a + b, 0)
    else if (method === 'avg') valor = vals.reduce((a, b) => a + b, 0) / vals.length
    else valor = vals[vals.length - 1]
    return { fecha: `${year}-01-01`, valor: Math.round(valor * 100) / 100 }
  })
}

export function realIndex(
  data: DataPoint[],
  deflator: DataPoint[],
  base: string = '2010-01-01',
): DataPoint[] {
  const deflMap: Record<string, number> = {}
  for (const d of deflator) deflMap[d.fecha.slice(0, 7)] = d.valor
  const baseVal = deflMap[base.slice(0, 7)] || 1
  return data.map((d) => {
    const defl = deflMap[d.fecha.slice(0, 7)] || 1
    return { fecha: d.fecha, valor: Math.round((d.valor / defl) * baseVal * 100) / 100 }
  })
}

export function merge(
  series: Record<string, DataPoint[]>,
  keys: string[],
): MergedPoint[] {
  const allDates = [...new Set(keys.flatMap((k) => series[k]?.map((d) => d.fecha) ?? []))].sort()
  return allDates.map((fecha) => {
    const row: MergedPoint = { fecha }
    for (const k of keys) {
      const pt = series[k]?.find((d) => d.fecha === fecha)
      if (pt) row[k] = pt.valor
    }
    return row
  })
}

export function filterByRange(data: DataPoint[], from: string, to: string): DataPoint[] {
  return data.filter((d) => {
    const f = d.fecha.slice(0, 7)
    return f >= from && f <= to
  })
}

export function filterMergedByRange(data: MergedPoint[], from: string, to: string): MergedPoint[] {
  return data.filter((d) => {
    const f = d.fecha.slice(0, 7)
    return f >= from && f <= to
  })
}

export function fmtMillones(v: number): string {
  if (Math.abs(v) >= 1_000) return `${(v / 1_000).toFixed(1)}B`
  return `${v.toFixed(0)}M`
}

export function fmtPct(v: number): string {
  return `${v.toFixed(1)}%`
}

export function fmtDate(fecha: string): string {
  const d = new Date(fecha + 'T00:00:00')
  return d.toLocaleDateString('es-DO', { year: 'numeric', month: 'short' })
}

export function fmtYear(fecha: string): string {
  return fecha.slice(0, 4)
}

export function lastN(data: DataPoint[], n: number): DataPoint[] {
  return data.slice(-n)
}

export function todayMonth(): string {
  return new Date().toISOString().slice(0, 7)
}

export function monthsAgo(n: number): string {
  const d = new Date()
  d.setMonth(d.getMonth() - n)
  return d.toISOString().slice(0, 7)
}
