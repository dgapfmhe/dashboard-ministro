import { supabase } from './supabase'

/* ─── Tipos ──────────────────────────────────────────────────────────── */
export type Freq = 'D' | 'W' | 'M'
export type Universo = 'query' | 'amplio'

export type Agregado = {
  fecha: string; categoria_id: string; n: number
  n_pos: number; n_neu: number; n_neg: number; suma_pol: number
}
export type Latente = {
  fecha: string; categoria_id: string; observado: number | null; n: number
  filtrado: number; filtrado_se: number; suavizado: number; suavizado_se: number
}
export type LatenteParam = {
  freq: Freq; categoria_id: string; universo: Universo
  theta: number; q: number; pct_ruido: number; n_obs: number; n_mediana: number
}
export type Categoria = {
  id: string; nombre: string; nivel: number; padre: string | null; origen: string
  congelada: boolean; activa_desde: string; n_queries: number; palabras_clave: string[]
}
export type Modelo = {
  id: string; nombre: string; tipo: string; idiomas: string[]; activo: boolean
  principal: boolean; f1_oro: number | null; kappa_oro: number | null; n_oro: number | null
}
export type Noticia = {
  id: string; fecha: string; titulo: string; medio: string; url: string
  sectores: string[]; polaridad: number; etiqueta: string; base: string
}

/* ─── Lectura paginada genérica (Supabase corta en 1000 filas) ─────── */
type Filtro = [col: string, op: 'eq' | 'in' | 'gte' | 'lte', val: unknown]

async function leerTodo<T>(tabla: string, cols: string, filtros: Filtro[], orden = 'fecha'): Promise<T[]> {
  const out: T[] = []
  const PAGE = 1000
  for (let off = 0; off < 500_000; off += PAGE) {
    let q = supabase.from(tabla).select(cols)
    for (const [c, op, v] of filtros) {
      if (op === 'eq') q = q.eq(c, v as string)
      else if (op === 'in') q = q.in(c, v as string[])
      else if (op === 'gte') q = q.gte(c, v as string)
      else q = q.lte(c, v as string)
    }
    const { data, error } = await q.order(orden, { ascending: true }).range(off, off + PAGE - 1)
    if (error) throw new Error(`${tabla}: ${error.message}`)
    if (!data?.length) break
    out.push(...(data as T[]))
    if (data.length < PAGE) break
  }
  return out
}

export const fetchCategorias = () =>
  leerTodo<Categoria>('sent_categorias', '*', [], 'id')

export const fetchModelos = () =>
  leerTodo<Modelo>('sent_modelos', '*', [], 'id')

export const fetchAgregado = (freq: Freq, cats: string[], uni: Universo, modelo: string, desde = '2016-01-01') =>
  leerTodo<Agregado>('sent_agregado', 'fecha,categoria_id,n,n_pos,n_neu,n_neg,suma_pol',
    [['freq', 'eq', freq], ['categoria_id', 'in', cats], ['universo', 'eq', uni],
     ['modelo_id', 'eq', modelo], ['fecha', 'gte', desde]])

export const fetchLatente = (freq: Freq, cats: string[], uni: Universo, modelo: string, desde = '2016-01-01') =>
  leerTodo<Latente>('sent_latente',
    'fecha,categoria_id,observado,n,filtrado,filtrado_se,suavizado,suavizado_se',
    [['freq', 'eq', freq], ['categoria_id', 'in', cats], ['universo', 'eq', uni],
     ['modelo_id', 'eq', modelo], ['fecha', 'gte', desde]])

export const fetchLatenteParams = (modelo: string) =>
  leerTodo<LatenteParam>('sent_latente_param', 'freq,categoria_id,universo,theta,q,pct_ruido,n_obs,n_mediana',
    [['modelo_id', 'eq', modelo]], 'categoria_id')

export const fetchMarkov = (freq: Freq, cat: string, uni: Universo, modelo: string) =>
  leerTodo<{ fecha: string; p_estres: number }>('sent_markov', 'fecha,p_estres',
    [['freq', 'eq', freq], ['categoria_id', 'eq', cat], ['universo', 'eq', uni], ['modelo_id', 'eq', modelo]])

export async function fetchNoticias(modelo: string, sector: string | null, limite = 60): Promise<Noticia[]> {
  let q = supabase.from('sent_noticias')
    .select('id,fecha,titulo,medio,url,sectores,polaridad,etiqueta,base')
    .eq('modelo_id', modelo)
  if (sector && sector !== 'TODO') q = q.contains('sectores', [sector])
  const { data, error } = await q.order('fecha', { ascending: false }).limit(limite)
  if (error) throw new Error(error.message)
  return (data ?? []) as Noticia[]
}

/* ─── Rejilla de períodos completa (períodos sin noticias = n 0) ───── */
const iso = (d: Date) => d.toISOString().slice(0, 10)
function siguiente(fecha: string, f: Freq): string {
  const d = new Date(fecha + 'T00:00:00Z')
  if (f === 'D') d.setUTCDate(d.getUTCDate() + 1)
  else if (f === 'W') d.setUTCDate(d.getUTCDate() + 7)
  else d.setUTCMonth(d.getUTCMonth() + 1)
  return iso(d)
}
export function rejilla(desde: string, hasta: string, f: Freq): string[] {
  const out: string[] = []
  for (let x = desde; x <= hasta && out.length < 20_000; x = siguiente(x, f)) out.push(x)
  return out
}

/* ─── ISEC (pesos editables) ─────────────────────────────────────────
 * Metodología de la investigación (CLAUDE.md §4):
 *   SPS  = polaridad media del período
 *   ATM  = N / mediana móvil 12m de N        → ln(ATM)·sign(SPS)
 *   IDM  = min(Pos, Neg)/N                   → IDM·(−sign(SPS))
 *   VS   = −desv. est. móvil 12m de SPS
 *   ISEC = w1·SPS + w2·ln(ATM)·sign(SPS) + w3·IDM·(−sign(SPS)) + w4·VS
 * Ventana "12 meses" según frecuencia: D 365 · W 52 · M 12.
 */
export type Pesos = { sps: number; atm: number; idm: number; vs: number }
export const PESOS_BASE: Pesos = { sps: 0.7, atm: 0.1, idm: 0.1, vs: 0.1 }
export const VENTANA: Record<Freq, number> = { D: 365, W: 52, M: 12 }

export type PuntoISEC = {
  fecha: string; n: number; pos: number; neu: number; neg: number
  sps: number | null; lnatm: number | null
  idm: number | null; vs: number | null; isec: number | null
}

function mediana(xs: number[]): number {
  const s = [...xs].sort((a, b) => a - b)
  const m = s.length >> 1
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2
}
function desv(xs: number[]): number {
  const mu = xs.reduce((a, b) => a + b, 0) / xs.length
  return Math.sqrt(xs.reduce((a, b) => a + (b - mu) ** 2, 0) / Math.max(1, xs.length - 1))
}

export function calcularISEC(ag: Agregado[], f: Freq, w: Pesos, hasta?: string): PuntoISEC[] {
  if (!ag.length) return []
  const porFecha = new Map(ag.map(a => [a.fecha.slice(0, 10), a]))
  const fechas = rejilla(ag[0].fecha.slice(0, 10), hasta ?? ag[ag.length - 1].fecha.slice(0, 10), f)
  const L = VENTANA[f]
  const minObs = Math.ceil(L / 2)
  const ns: number[] = []
  const out: PuntoISEC[] = []
  for (const fe of fechas) {
    const a = porFecha.get(fe)
    const n = a?.n ?? 0
    ns.push(n)
    const sps = n > 0 ? a!.suma_pol / n : null
    const winN = ns.slice(-L)
    const med = winN.length >= minObs ? mediana(winN) : NaN
    const sg = sps === null ? 0 : Math.sign(sps)
    const lnatm = n > 0 && med > 0 ? Math.log(n / med) * sg : null
    const idm = n > 0 ? (Math.min(a!.n_pos, a!.n_neg) / n) * -sg : null
    // VS: desviación de los SPS observados dentro de la ventana de L períodos
    const winS = out.slice(-(L - 1)).map(p => p.sps).filter((x): x is number => x !== null)
    if (sps !== null) winS.push(sps)
    const vs = winS.length >= Math.max(3, Math.ceil(minObs / 2)) ? -desv(winS) : null
    const isec = sps !== null && lnatm !== null && idm !== null && vs !== null
      ? w.sps * sps + w.atm * lnatm + w.idm * idm + w.vs * vs : null
    out.push({ fecha: fe, n, pos: a?.n_pos ?? 0, neu: a?.n_neu ?? 0, neg: a?.n_neg ?? 0, sps, lnatm, idm, vs, isec })
  }
  return out
}

/* Fecha de inicio por defecto según frecuencia (vista inicial) */
export function desdeDefecto(f: Freq): string {
  const d = new Date()
  if (f === 'D') d.setMonth(d.getMonth() - 6)
  else if (f === 'W') d.setFullYear(d.getFullYear() - 3)
  else d.setFullYear(d.getFullYear() - 8)
  return iso(d).slice(0, 7)
}

export const NOMBRE_FREQ: Record<Freq, string> = { D: 'Diaria', W: 'Semanal', M: 'Mensual' }

const _DIAS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado']
const _MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre']
/** Etiqueta larga del período para el tooltip: "martes 14 de octubre de 2026", "semana del 13 al 19 oct 2026", "octubre 2026". */
export function fechaLarga(fecha: string, f: Freq): string {
  const d = new Date(fecha.slice(0, 10) + 'T00:00:00Z')
  if (isNaN(d.getTime())) return fecha
  const dia = d.getUTCDate(), mes = _MESES[d.getUTCMonth()], an = d.getUTCFullYear()
  if (f === 'D') return `${_DIAS[d.getUTCDay()]} ${dia} de ${mes} de ${an}`
  if (f === 'W') {
    const fin = new Date(d); fin.setUTCDate(fin.getUTCDate() + 6)
    return `semana del ${dia} ${mes.slice(0, 3)} al ${fin.getUTCDate()} ${_MESES[fin.getUTCMonth()].slice(0, 3)} ${fin.getUTCFullYear()}`
  }
  return `${mes} ${an}`
}

/** Tramos consecutivos sin noticias (n = 0) → para sombrearlos como "sin datos". */
export function tramosSinDatos(serie: { fecha: string; n: number }[]): [string, string][] {
  const out: [string, string][] = []
  let ini: string | null = null, prev: string | null = null
  for (const p of serie) {
    if (p.n === 0) { ini ??= p.fecha; prev = p.fecha }
    else if (ini) { out.push([ini, prev!]); ini = null }
  }
  if (ini) out.push([ini, prev!])
  return out
}
export const ISSUE_NUEVA_CATEGORIA =
  'https://github.com/dgapfmhe/dashboard-ministro/issues/new?template=nueva_categoria.yml'
