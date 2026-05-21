import { supabase } from './supabase'
import type { DataPoint, SeriesMap } from '@/types'

export async function fetchSeries(variableIds: string[], from = '2000-01-01'): Promise<SeriesMap> {
  // Supabase REST corta a 1000 filas por defecto. Cuando se piden muchas variables
  // (ej: 36 vars × 74 meses = 2664 filas) el resultado se trunca silenciosamente,
  // dejando los meses recientes fuera. Paginamos via .range() para traer todo.
  const result: SeriesMap = {}
  for (const id of variableIds) result[id] = []
  if (variableIds.length === 0) return result

  const PAGE = 1000
  for (let offset = 0; offset < 200_000; offset += PAGE) {
    const { data, error } = await supabase
      .from('series_datos')
      .select('variable_id, fecha, valor')
      .in('variable_id', variableIds)
      .gte('fecha', from)
      .order('variable_id', { ascending: true })
      .order('fecha', { ascending: true })
      .range(offset, offset + PAGE - 1)
    if (error) throw new Error(error.message)
    if (!data || data.length === 0) break
    for (const row of data) {
      ;(result[row.variable_id] ??= []).push({ fecha: row.fecha, valor: Number(row.valor) })
    }
    if (data.length < PAGE) break
  }
  return result
}

export async function fetchSingle(variableId: string, from = '2000-01-01'): Promise<DataPoint[]> {
  const map = await fetchSeries([variableId], from)
  return map[variableId] ?? []
}

export type CatalogVariable = {
  id: string
  nombre: string
  modulo: string
  submodulo?: string | null
  frecuencia: 'diaria' | 'semanal' | 'mensual' | 'trimestral' | 'anual'
  unidad: string
  escala?: string | null
  fuente: string
  tipo?: 'directa' | 'derivada'
}

async function fetchVariableIdsWithData(): Promise<Set<string>> {
  // Supabase REST cuts at 1000 rows by default — paginate via .range() until all 91k+ rows are scanned.
  const ids = new Set<string>()
  const PAGE = 1000
  for (let from = 0; from < 200_000; from += PAGE) {
    const { data, error } = await supabase
      .from('series_datos')
      .select('variable_id')
      .range(from, from + PAGE - 1)
    if (error) throw new Error(error.message)
    if (!data || data.length === 0) break
    for (const r of data as { variable_id: string }[]) ids.add(r.variable_id)
    if (data.length < PAGE) break
  }
  return ids
}

export async function fetchCatalogWithData(): Promise<CatalogVariable[]> {
  const [{ data: vars, error: e1 }, withData] = await Promise.all([
    supabase
      .from('variables')
      .select('id,nombre,modulo,submodulo,frecuencia,unidad,escala,fuente,tipo')
      .order('modulo'),
    fetchVariableIdsWithData(),
  ])
  if (e1) throw new Error(e1.message)
  return (vars ?? []).filter((v: CatalogVariable) => withData.has(v.id))
}

export async function fetchLastValue(variableId: string): Promise<DataPoint | null> {
  const { data } = await supabase
    .from('series_datos')
    .select('fecha, valor')
    .eq('variable_id', variableId)
    .order('fecha', { ascending: false })
    .limit(1)
  return data?.[0] ? { fecha: data[0].fecha, valor: Number(data[0].valor) } : null
}

/**
 * Resumen por variable: fecha_max, ultimo_valor, n_obs.
 * Pensado para alimentar la grilla del "banco" (Personalizado) sin cargar
 * todas las series. Usa una sola query (RPC server-side aggregation no
 * está expuesta; fallback: traer todo y reducir client-side por chunks).
 */
export type VariableSummary = {
  variable_id: string
  fecha_max: string
  ultimo_valor: number
  n_obs: number
}

export async function fetchVariableSummaries(): Promise<Record<string, VariableSummary>> {
  const out: Record<string, VariableSummary> = {}
  const PAGE = 1000
  for (let from = 0; from < 200_000; from += PAGE) {
    const { data, error } = await supabase
      .from('series_datos')
      .select('variable_id,fecha,valor')
      .range(from, from + PAGE - 1)
    if (error) throw new Error(error.message)
    if (!data || data.length === 0) break
    for (const r of data as { variable_id: string; fecha: string; valor: number }[]) {
      const cur = out[r.variable_id]
      const v = Number(r.valor)
      if (!cur) {
        out[r.variable_id] = { variable_id: r.variable_id, fecha_max: r.fecha, ultimo_valor: v, n_obs: 1 }
      } else {
        cur.n_obs += 1
        if (r.fecha > cur.fecha_max) {
          cur.fecha_max = r.fecha
          cur.ultimo_valor = v
        }
      }
    }
    if (data.length < PAGE) break
  }
  return out
}

export async function fetchWorldBankGDP(): Promise<{ country: string; code: string; valor: number; anio: string }[]> {
  const countries = [
    { code: 'DO', label: 'RD' },
    { code: 'CN', label: 'China' },
    { code: '1W', label: 'Mundial' },
    { code: 'US', label: 'EE.UU.' },
    { code: 'XJ', label: 'LATAM' },
    { code: 'CA', label: 'Canadá' },
    { code: 'GB', label: 'Reino Unido' },
    { code: 'Z4', label: 'Zona Euro' },
    { code: 'JP', label: 'Japón' },
  ]

  const results: { country: string; code: string; valor: number; anio: string }[] = []
  await Promise.allSettled(
    countries.map(async ({ code, label }) => {
      // mrv=5: traer hasta 5 años; algunos países publican antes que otros.
      const url = `https://api.worldbank.org/v2/country/${code}/indicator/NY.GDP.MKTP.KD.ZG?format=json&mrv=5&per_page=5`
      const res = await fetch(url, { next: { revalidate: 86400 } })
      const json = await res.json()
      // Buscar el año más reciente con valor no-null
      const entry = json?.[1]?.find((e: { value: number | null; date: string }) => e.value !== null)
      if (entry) {
        results.push({
          country: label,
          code,
          valor: Number(entry.value.toFixed(2)),
          anio: entry.date,
        })
      }
    }),
  )
  return results.sort((a, b) => b.valor - a.valor)
}
