'use client'
import { useCallback, useEffect, useRef, useState } from 'react'
import { supabase } from './supabase'
import { fetchSeries, type CatalogVariable } from './queries'
import {
  fetchAgregado, fetchLatente, calcularISEC, type Pesos, type Universo,
} from './sentimiento'

/* ─── Tipos del payload (espejo de public/lab/laboratorio.py) ──────── */
export type Transformacion = 'nivel' | 'log' | 'pct_mm' | 'pct_aa' | 'dif' | 'dif_aa' | 'logdif'
export type Agregacion = 'promedio' | 'ultimo' | 'suma'
export type TipoModelo = 'rw' | 'media' | 'ar' | 'arima' | 'sarimax' | 'arx' | 'var'
  | 'ridge' | 'lasso' | 'enet' | 'rf' | 'gbr' | 'svr' | 'knn' | 'mlp'

export type SerieIn = { fechas: string[]; valores: (number | null)[] }
export type ExogIn = SerieIn & {
  id: string; nombre: string; rezago: number; transformacion: Transformacion; agregacion: Agregacion
  estandarizar?: boolean
}
export type ModeloSpec = {
  id: string; tipo: TipoModelo
  [k: string]: unknown
}
export type Dummy = { tipo: 'impulso' | 'escalon' | 'rango' | 'tendencia'; nombre: string; desde?: string; hasta?: string }
export type Payload = {
  objetivo: SerieIn & { id: string; agregacion: Agregacion }
  frecuencia: 'M' | 'Q'
  transformacion: Transformacion
  desde: string
  escala_interanual: boolean
  exogenas: ExogIn[]
  dummies: { estacionales: boolean; lista: Dummy[] }
  modelos: ModeloSpec[]
  backtest: { esquema: 'expanding' | 'rolling'; ventana: number; min_train: number; reestimar_cada: number }
}

export type Metricas = {
  n: number; mae?: number; rmse?: number; sesgo?: number; acierto_dir?: number; cobertura95?: number
  rrmse_ar?: number; dm_ar?: number; p_dm_ar?: number; rrmse_rw?: number; dm_rw?: number; p_dm_rw?: number
}
export type Pronostico = {
  fecha: string; media: number | null; sd: number | null
  li80: number | null; ls80: number | null; li95: number | null; ls95: number | null; interanual?: number | null
}
export type ResultadoModelo = {
  id: string; tipo: TipoModelo; nombre: string; benchmark: boolean; error: string | null
  familia: 'referencia' | 'econometrico' | 'ml'; ecuacion?: string
  propiedades?: Record<string, unknown>; spec?: Record<string, unknown>
  pronostico?: Pronostico; usa_exog?: boolean
  coef?: { nombre: string; valor: number | null; ee: number | null; p: number | null }[]
  diagnostico?: { ljung_box_p?: number; jarque_bera_p?: number; arch_p?: number; media_residuos?: number; asimetria?: number; curtosis?: number }
  backtest?: { fechas: string[]; pred: (number | null)[]; real: (number | null)[]; sd: (number | null)[] }
  backtest_interanual?: { fechas: string[]; pred: (number | null)[]; real: (number | null)[] }
  metricas?: Metricas; metricas_interanual?: Metricas
}
export type Resultado = {
  fecha_pronostico: string
  muestra: { desde: string; hasta: string; n: number }
  serie: { fechas: string[]; y: (number | null)[] }
  exogenas: Record<string, (number | null)[]>
  exog_sig: Record<string, number | null>
  dummies: string[]
  modelos: ResultadoModelo[]
  avisos: string[]
  interanual: boolean
}

export const NOMBRE_TRANSF: Record<Transformacion, string> = {
  nivel: 'Nivel', log: 'Logaritmo', pct_mm: '% vs período anterior', pct_aa: '% interanual',
  dif: 'Diferencia', dif_aa: 'Diferencia interanual', logdif: 'Δ log ×100',
}
export const NOMBRE_TIPO: Record<TipoModelo, string> = {
  rw: 'Paseo aleatorio', media: 'Media histórica', ar: 'AR(p) automático', arima: 'ARIMA',
  sarimax: 'SARIMAX + exógenas', arx: 'ARX (MCO) + exógenas', var: 'VAR',
  ridge: 'Ridge', lasso: 'Lasso', enet: 'Elastic Net', rf: 'Random Forest', gbr: 'Gradient Boosting',
  svr: 'SVR', knn: 'K vecinos', mlp: 'Red neuronal (MLP)',
}

/* ─── Worker de Pyodide ─────────────────────────────────────────────── */
const VERSION_MOTOR = '2026-10-21c'

export function useMotorPython() {
  const w = useRef<Worker | null>(null)
  const pendientes = useRef(new Map<number, { ok: (r: Resultado) => void; ko: (e: Error) => void }>())
  const [estado, setEstado] = useState<'apagado' | 'cargando' | 'listo' | 'corriendo'>('apagado')
  const [texto, setTexto] = useState('')
  const [progreso, setProgreso] = useState<{ f: number; nombre: string } | null>(null)
  const seq = useRef(0)

  const asegurar = useCallback(() => {
    if (w.current) return w.current
    const worker = new Worker('/lab/pyodide-worker.js')
    worker.onmessage = (ev: MessageEvent) => {
      const m = ev.data
      if (m.tipo === 'estado') { setEstado(e => (e === 'corriendo' ? e : 'cargando')); setTexto(m.texto) }
      else if (m.tipo === 'listo') { setEstado(e => (e === 'corriendo' ? e : 'listo')); setTexto('') }
      else if (m.tipo === 'progreso') setProgreso({ f: m.f, nombre: m.nombre })
      else if (m.tipo === 'resultado' || m.tipo === 'error') {
        const p = pendientes.current.get(m.id)
        pendientes.current.delete(m.id)
        setEstado('listo'); setProgreso(null)
        if (p && m.tipo === 'resultado') p.ok(m.data)
        else if (p) p.ko(new Error(m.mensaje))
      }
    }
    worker.postMessage({ tipo: 'iniciar', version: VERSION_MOTOR })
    setEstado('cargando')
    w.current = worker
    return worker
  }, [])

  const correr = useCallback((payload: Payload) => {
    const worker = asegurar()
    const id = ++seq.current
    setEstado('corriendo'); setProgreso({ f: 0, nombre: 'preparando' })
    return new Promise<Resultado>((ok, ko) => {
      pendientes.current.set(id, { ok, ko })
      worker.postMessage({ tipo: 'correr', id, payload, version: VERSION_MOTOR })
    })
  }, [asegurar])

  useEffect(() => () => {
    w.current?.terminate()
    w.current = null
    for (const p of pendientes.current.values()) p.ko(new Error('cancelado'))
    pendientes.current.clear()
  }, [])
  return { estado, texto, progreso, correr, precargar: asegurar }
}

/* ─── Catálogo rápido (tabla variables; ~540 filas) ────────────────── */
export async function fetchCatalogoRapido(): Promise<CatalogVariable[]> {
  const out: CatalogVariable[] = []
  for (let off = 0; off < 5000; off += 1000) {
    const { data, error } = await supabase.from('variables')
      .select('id,nombre,modulo,submodulo,frecuencia,unidad,escala,fuente,tipo')
      .order('modulo').order('nombre').range(off, off + 999)
    if (error) throw new Error(error.message)
    out.push(...((data ?? []) as CatalogVariable[]))
    if (!data || data.length < 1000) break
  }
  return out
}

/* ─── Series de entrada ─────────────────────────────────────────────── */
export async function serieDashboard(id: string): Promise<SerieIn> {
  const m = await fetchSeries([id], '1990-01-01')
  const s = m[id] ?? []
  return { fechas: s.map(d => d.fecha), valores: s.map(d => (isFinite(d.valor) ? d.valor : null)) }
}

export type FuenteSent = 'isec' | 'isep' | 'sps'
export const NOMBRE_SENT: Record<FuenteSent, string> = {
  isec: 'ISEC', isep: 'ISEP filtrado', sps: 'SPS (con ruido)',
}

/** Series mensuales de sentimiento (ISEC con los pesos dados, ISEP filtrado, SPS). */
export async function seriesSentimiento(cat: string, uni: Universo, modelo: string, pesos: Pesos,
                                        freq: 'M' | 'W' = 'M'): Promise<Record<FuenteSent, SerieIn>> {
  const [ag, lat] = await Promise.all([fetchAgregado(freq, [cat], uni, modelo), fetchLatente(freq, [cat], uni, modelo)])
  const is = calcularISEC(ag, freq, pesos)
  return {
    isec: { fechas: is.map(p => p.fecha), valores: is.map(p => p.isec) },
    sps: { fechas: is.map(p => p.fecha), valores: is.map(p => p.sps) },
    isep: { fechas: lat.map(l => l.fecha.slice(0, 10)), valores: lat.map(l => l.filtrado) },
  }
}

/* ─── Pronósticos oficiales (GitHub Actions) ───────────────────────── */
export type PredOficial = {
  spec_id: string; modelo_id: string; modelo_nombre: string; objetivo: string; descripcion: string
  fecha_objetivo: string; emitido: string; media: number | null; li95: number | null; ls95: number | null
  interanual: number | null; real: number | null; real_interanual: number | null
}
export type PredMetrica = {
  spec_id: string; modelo_id: string; modelo_nombre: string; descripcion: string
  n: number; rmse: number | null; rrmse_ar: number | null; p_dm_ar: number | null; acierto_dir: number | null
  actualizado: string
}

export async function fetchPredOficiales() {
  const [now, vin, met] = await Promise.all([
    supabase.from('pred_nowcast').select('*').order('spec_id'),
    supabase.from('pred_vintage').select('*').order('fecha_objetivo', { ascending: false }).limit(500),
    supabase.from('pred_metricas').select('*').order('spec_id'),
  ])
  return {
    nowcast: (now.data ?? []) as PredOficial[],
    vintages: (vin.data ?? []) as PredOficial[],
    metricas: (met.data ?? []) as PredMetrica[],
    error: now.error?.message ?? vin.error?.message ?? met.error?.message ?? null,
  }
}
