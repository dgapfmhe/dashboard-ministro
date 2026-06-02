'use client'
import { useEffect, useMemo, useState } from 'react'
import {
  fetchCatalogWithData, fetchSeries, fetchVariableSummaries,
  type CatalogVariable, type VariableSummary,
} from '@/lib/queries'
import {
  aggregateAnnual, filterMergedByRange, merge,
  movingAverage, yoyGrowth, momGrowth, dailyYoYGrowth,
} from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import LineChartSimple from '@/components/charts/LineChartSimple'
import BarChartVert from '@/components/charts/BarChartVert'
import { PALETTE } from '@/lib/colors'
import type { DataPoint, MergedPoint, SeriesMap } from '@/types'

/* ─── Tipos UI ──────────────────────────────────────────────── */
type ChartKind = 'line' | 'bar' | 'area'
type FreqAgg = 'auto' | 'mensual' | 'trimestral' | 'anual'
type Transform = 'nivel' | 'yoy' | 'mom' | 'ma3' | 'ma6' | 'ma12'

/* ─── Helpers ─────────────────────────────────────────────── */
const today = () => new Date().toISOString().slice(0, 7)
const monthsAgo = (n: number) => {
  const d = new Date(); d.setMonth(d.getMonth() - n)
  return d.toISOString().slice(0, 7)
}

function detectFreq(data: DataPoint[]): 'diaria' | 'mensual' | 'anual' {
  if (data.length < 2) return 'mensual'
  const a = new Date(data[0].fecha + 'T00:00:00')
  const b = new Date(data[1].fecha + 'T00:00:00')
  const days = Math.abs((b.getTime() - a.getTime()) / 86400000)
  if (days <= 7) return 'diaria'
  if (days <= 90) return 'mensual'
  return 'anual'
}

function applyTransform(data: DataPoint[], t: Transform): DataPoint[] {
  if (data.length === 0 || t === 'nivel') return data
  const f = detectFreq(data)
  switch (t) {
    case 'yoy': return f === 'diaria' ? dailyYoYGrowth(data) : yoyGrowth(data)
    case 'mom': return momGrowth(data)
    case 'ma3': return movingAverage(data, 3)
    case 'ma6': return movingAverage(data, 6)
    case 'ma12': return movingAverage(data, 12)
    default: return data
  }
}

function aggregateByFreq(data: DataPoint[], freq: FreqAgg): DataPoint[] {
  if (freq === 'auto') return data
  if (freq === 'anual') return aggregateAnnual(data, 'avg')
  if (freq === 'trimestral') {
    const byQ: Record<string, number[]> = {}
    for (const d of data) {
      const dt = new Date(d.fecha + 'T00:00:00')
      const q = Math.floor(dt.getUTCMonth() / 3)
      const key = `${dt.getUTCFullYear()}-${String(q * 3 + 1).padStart(2, '0')}-01`
      ;(byQ[key] ??= []).push(d.valor)
    }
    return Object.entries(byQ).sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => ({ fecha: k, valor: v.reduce((s, x) => s + x, 0) / v.length }))
  }
  // mensual
  const byM: Record<string, number[]> = {}
  for (const d of data) {
    const k = d.fecha.slice(0, 7) + '-01'
    ;(byM[k] ??= []).push(d.valor)
  }
  return Object.entries(byM).sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => ({ fecha: k, valor: v[v.length - 1] }))
}

function fmtValue(v: number | null | undefined): string {
  if (v == null || !isFinite(v)) return '—'
  const abs = Math.abs(v)
  if (abs >= 1e9) return `${(v / 1e9).toFixed(2)}B`
  if (abs >= 1e6) return `${(v / 1e6).toFixed(2)}M`
  if (abs >= 1e3) return `${(v / 1e3).toFixed(1)}k`
  if (abs >= 1)   return v.toFixed(2)
  return v.toFixed(3)
}

function fmtDate(s: string): string {
  if (!s || s.length < 7) return s
  const [y, m, d] = s.split('-')
  return `${d ?? '01'}/${m}/${y.slice(2)}`
}

/* ─── Componente principal ────────────────────────────────────────── */
export default function Personalizado() {
  /* Catálogo + summaries */
  const [catalog, setCatalog] = useState<CatalogVariable[]>([])
  const [summaries, setSummaries] = useState<Record<string, VariableSummary>>({})
  const [loadingCat, setLoadingCat] = useState(true)

  /* Filtros sidebar */
  const [search, setSearch] = useState('')
  const [moduloFilter, setModuloFilter] = useState('Todos')
  const [freqFilter, setFreqFilter] = useState('Todas')
  const [fuenteFilter, setFuenteFilter] = useState('Todas')

  /* Selección + data */
  const [selected, setSelected] = useState<string[]>([])
  const [seriesMap, setSeriesMap] = useState<SeriesMap>({})
  const [loadingSeries, setLoadingSeries] = useState(false)

  /* Controles del chart principal */
  const [chartKind, setChartKind] = useState<ChartKind>('line')
  const [freq, setFreq] = useState<FreqAgg>('auto')
  const [transform, setTransform] = useState<Transform>('nivel')
  const [range, setRange] = useState<[string, string]>([monthsAgo(60), today()])

  /* Paneles adicionales — snapshots independientes del panel principal.
   * Cada panel guarda su propia combinación de variables + tipo + transformación.
   * Permite comparar varios gráficos simultáneamente sin perder la selección. */
  type SavedPanel = {
    id: number
    title: string
    selected: string[]
    chartKind: ChartKind
    freq: FreqAgg
    transform: Transform
    range: [string, string]
  }
  const [savedPanels, setSavedPanels] = useState<SavedPanel[]>([])
  const saveCurrentAsPanel = () => {
    if (selected.length === 0) return
    const id = Date.now()
    const names = selected.map(s => catalog.find(c => c.id === s)?.nombre ?? s).slice(0, 2)
    const title = names.join(' + ') + (selected.length > 2 ? ` (+${selected.length - 2})` : '')
    setSavedPanels(prev => [...prev, {
      id, title, selected: [...selected],
      chartKind, freq, transform, range: [...range] as [string, string],
    }])
  }
  const removePanel = (id: number) =>
    setSavedPanels(prev => prev.filter(p => p.id !== id))

  /* Carga inicial: catálogo + summaries en paralelo */
  useEffect(() => {
    Promise.all([fetchCatalogWithData(), fetchVariableSummaries()])
      .then(([cat, sum]) => { setCatalog(cat); setSummaries(sum) })
      .finally(() => setLoadingCat(false))
  }, [])

  /* Fetch lazy de las series seleccionadas */
  useEffect(() => {
    const missing = selected.filter(id => !seriesMap[id])
    if (missing.length === 0) return
    setLoadingSeries(true)
    fetchSeries(missing, '1990-01-01')
      .then(m => setSeriesMap(prev => ({ ...prev, ...m })))
      .finally(() => setLoadingSeries(false))
  }, [selected, seriesMap])

  /* Opciones de filtros */
  const modulos = useMemo(
    () => ['Todos', ...Array.from(new Set(catalog.map(v => v.modulo))).sort()],
    [catalog])
  const frecuencias = ['Todas', 'diaria', 'mensual', 'trimestral', 'anual']
  const fuentes = useMemo(
    () => ['Todas', ...Array.from(new Set(catalog.map(v => v.fuente))).sort()],
    [catalog])

  /* Aplicar filtros */
  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase()
    return catalog.filter(v => {
      if (moduloFilter !== 'Todos' && v.modulo !== moduloFilter) return false
      if (freqFilter !== 'Todas' && v.frecuencia !== freqFilter) return false
      if (fuenteFilter !== 'Todas' && v.fuente !== fuenteFilter) return false
      if (!q) return true
      return v.id.toLowerCase().includes(q) ||
             v.nombre.toLowerCase().includes(q)
    })
  }, [catalog, search, moduloFilter, freqFilter, fuenteFilter])

  /* Agrupar por módulo para la lista */
  const grouped = useMemo(() => {
    const out: Record<string, CatalogVariable[]> = {}
    for (const v of filtered) {
      ;(out[v.modulo] ??= []).push(v)
    }
    return out
  }, [filtered])

  const toggle = (id: string) =>
    setSelected(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id])

  /* Detecta si la salida del transform/agregado es DIARIA (necesario para
   * que el tooltip muestre cada día y no colapse mes). */
  const isDailyOutput = useMemo(() => {
    if (freq === 'mensual' || freq === 'trimestral' || freq === 'anual') return false
    // freq === 'auto' (o 'diaria'): es diario si TODAS las series seleccionadas
    // tienen frecuencia diaria en el catálogo.
    if (selected.length === 0) return false
    return selected.every(id => {
      const v = catalog.find(c => c.id === id)
      return v?.frecuencia === 'diaria'
    })
  }, [freq, selected, catalog])

  /* Transform + merge. Excluye NaN/inválidos. El nivel de granularidad de la
   * fecha resultante depende de si todas las series son diarias:
   *   - Diaria → YYYY-MM-DD (cada tick visible en tooltip)
   *   - Mensual/Trim/Anual → YYYY-MM (un punto por mes) */
  const merged = useMemo<MergedPoint[]>(() => {
    if (selected.length === 0) return []
    const tr: Record<string, DataPoint[]> = {}
    const grain = isDailyOutput ? 10 : 7  // 10 = YYYY-MM-DD, 7 = YYYY-MM
    for (const id of selected) {
      let s = seriesMap[id] ?? []
      if (s.length === 0) continue
      s = s.filter(d => d.valor != null && isFinite(d.valor))
      if (s.length === 0) continue
      s = aggregateByFreq(s, freq)
      s = applyTransform(s, transform)
      s = s.filter(d => d.valor != null && isFinite(d.valor))
      tr[id] = s.map(d => ({ ...d, fecha: d.fecha.slice(0, grain) }))
    }
    const keys = Object.keys(tr)
    if (keys.length === 0) return []
    return merge(tr, keys).map(row => {
      const out: MergedPoint = { fecha: (row.fecha as string).slice(0, grain) }
      for (const k of keys) {
        const v = row[k]
        if (typeof v === 'number' && isFinite(v)) out[k] = v
      }
      return out
    })
  }, [selected, seriesMap, freq, transform, isDailyOutput])

  const filteredData = useMemo(
    () => filterMergedByRange(merged, range[0], range[1]),
    [merged, range[0], range[1]])

  const seriesDef = selected.map((id, i) => {
    const v = catalog.find(c => c.id === id)
    return {
      key: id,
      label: v ? `${v.nombre}` : id,
      color: PALETTE[i % PALETTE.length],
    }
  })

  const yFmt = (v: number) => {
    if (transform === 'yoy' || transform === 'mom') return `${v.toFixed(2)}%`
    return fmtValue(v)
  }
  const xFmt = (v: string) => {
    if (!v || v.length < 7) return v
    const [y, m, d] = v.split('-')
    const meses = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
    // Si es diario: mostrar "D MMM" (ej "15 May"); si es mensual: "M'YY"
    if (isDailyOutput && d) {
      return `${+d} ${meses[+m - 1]}`
    }
    return `${meses[+m - 1]}'${y.slice(2)}`
  }

  return (
    <div className="grid grid-cols-1 lg:grid-cols-[340px_1fr] gap-4">

      {/* ── Sidebar: explorador de variables ── */}
      <aside className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-3 flex flex-col gap-2 max-h-[calc(100vh-180px)]">
        <div>
          <h3 className="text-[13px] font-semibold text-[#1A202C]">Banco de Variables</h3>
          <p className="text-[11px] text-[#6B7280]">
            {loadingCat
              ? 'Cargando catálogo…'
              : `${filtered.length} de ${catalog.length} · ${selected.length} seleccionada${selected.length === 1 ? '' : 's'}`}
          </p>
        </div>
        <input
          type="text" placeholder="Buscar id o nombre…"
          value={search} onChange={e => setSearch(e.target.value)}
          className="text-[12px] border border-[#D1D9E0] rounded-md px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-[#1B3A5C]"/>
        <div className="grid grid-cols-1 gap-1.5">
          <select value={moduloFilter} onChange={e => setModuloFilter(e.target.value)}
            className="text-[11px] border border-[#D1D9E0] rounded px-2 py-1 bg-white">
            {modulos.map(m => <option key={m} value={m}>{m === 'Todos' ? 'Todos los módulos' : m}</option>)}
          </select>
          <div className="grid grid-cols-2 gap-1.5">
            <select value={freqFilter} onChange={e => setFreqFilter(e.target.value)}
              className="text-[11px] border border-[#D1D9E0] rounded px-2 py-1 bg-white">
              {frecuencias.map(f => <option key={f} value={f}>{f === 'Todas' ? 'Toda frec.' : f}</option>)}
            </select>
            <select value={fuenteFilter} onChange={e => setFuenteFilter(e.target.value)}
              className="text-[11px] border border-[#D1D9E0] rounded px-2 py-1 bg-white">
              {fuentes.map(f => <option key={f} value={f}>{f === 'Todas' ? 'Toda fuente' : f}</option>)}
            </select>
          </div>
        </div>
        {selected.length > 0 && (
          <button onClick={() => setSelected([])}
            className="text-[10px] self-start text-[#8B2E2E] hover:underline">
            Limpiar selección ({selected.length})
          </button>
        )}

        <div className="overflow-y-auto flex-1 -mx-1 px-1 mt-1">
          {Object.keys(grouped).sort().map(modulo => (
            <div key={modulo} className="mb-2">
              <p className="text-[10px] uppercase tracking-wider font-semibold text-[#6B7280] mb-0.5 sticky top-0 bg-white py-0.5">
                {modulo} <span className="text-[#B0B7BF] font-normal">({grouped[modulo].length})</span>
              </p>
              <div className="flex flex-col gap-0.5">
                {grouped[modulo].map(v => {
                  const active = selected.includes(v.id)
                  const sum = summaries[v.id]
                  return (
                    <button key={v.id} onClick={() => toggle(v.id)}
                      title={`${v.id} · ${v.frecuencia} · ${v.unidad} · ${v.fuente}`}
                      className={[
                        'text-left px-2 py-1 rounded text-[11px] transition-colors',
                        active ? 'bg-[#1B3A5C] text-white'
                               : 'hover:bg-[#EEF0F4] text-[#1A202C]',
                      ].join(' ')}>
                      <div className="flex items-center justify-between gap-1.5">
                        <div className="flex items-center gap-1.5 min-w-0">
                          <span className={active ? 'text-white' : 'text-[#1B3A5C]'}>{active ? '●' : '○'}</span>
                          <span className="font-medium truncate">{v.nombre}</span>
                        </div>
                        {sum && (
                          <span className={`text-[9px] tabular-nums shrink-0 ${active ? 'text-white/80' : 'text-[#6B7280]'}`}>
                            {fmtValue(sum.ultimo_valor)}
                          </span>
                        )}
                      </div>
                      <div className={`text-[9px] ml-3.5 flex items-center justify-between ${active ? 'text-white/70' : 'text-[#9CA3AF]'}`}>
                        <span>{v.id} · {v.frecuencia}</span>
                        {sum && <span className="tabular-nums">{fmtDate(sum.fecha_max)}</span>}
                      </div>
                    </button>
                  )
                })}
              </div>
            </div>
          ))}
          {filtered.length === 0 && !loadingCat && (
            <p className="text-[11px] text-[#9CA3AF] italic mt-2">Sin coincidencias para los filtros actuales.</p>
          )}
        </div>
      </aside>

      {/* ── Canvas: chart + controles ── */}
      <section className="flex flex-col gap-3">

        {/* Toolbar de controles */}
        <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-3">
          <div className="flex flex-wrap items-end gap-4">
            <div className="flex flex-col gap-1">
              <label className="text-[10px] uppercase tracking-wider font-semibold text-[#6B7280]">Tipo</label>
              <div className="flex gap-1">
                {([
                  { v: 'line', label: 'Líneas' },
                  { v: 'bar',  label: 'Barras' },
                  { v: 'area', label: 'Área' },
                ] as const).map(({ v, label }) => (
                  <button key={v} onClick={() => setChartKind(v)}
                    className={[
                      'text-[11px] px-3 py-1 rounded border transition-colors',
                      chartKind === v
                        ? 'bg-[#1B3A5C] text-white border-[#1B3A5C]'
                        : 'border-[#D1D9E0] text-[#6B7280] hover:bg-[#EEF0F4]',
                    ].join(' ')}>{label}</button>
                ))}
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-[10px] uppercase tracking-wider font-semibold text-[#6B7280]">Frecuencia</label>
              <select value={freq} onChange={e => setFreq(e.target.value as FreqAgg)}
                className="text-[11px] border border-[#D1D9E0] rounded px-2 py-1 bg-white">
                <option value="auto">Original</option>
                <option value="mensual">Mensual</option>
                <option value="trimestral">Trimestral</option>
                <option value="anual">Anual</option>
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-[10px] uppercase tracking-wider font-semibold text-[#6B7280]">Transformación</label>
              <select value={transform} onChange={e => setTransform(e.target.value as Transform)}
                className="text-[11px] border border-[#D1D9E0] rounded px-2 py-1 bg-white">
                <option value="nivel">Nivel</option>
                <option value="yoy">YoY %</option>
                <option value="mom">MoM %</option>
                <option value="ma3">Media móvil 3</option>
                <option value="ma6">Media móvil 6</option>
                <option value="ma12">Media móvil 12</option>
              </select>
            </div>
          </div>
        </div>

        {/* Botón guardar panel */}
        <div className="flex items-center justify-end -mb-1">
          <button
            type="button"
            disabled={selected.length === 0}
            onClick={saveCurrentAsPanel}
            className={[
              'text-[10px] px-3 py-1 rounded border transition-colors',
              selected.length === 0
                ? 'border-[#D1D9E0] text-[#9CA3AF] cursor-not-allowed'
                : 'border-[#1B3A5C] text-[#1B3A5C] hover:bg-[#1B3A5C] hover:text-white',
            ].join(' ')}
            title="Guarda el gráfico actual como un panel separado y libera la selección para crear otro"
          >📌 Guardar como panel</button>
        </div>

        <ChartWrapper
          title={selected.length === 1
            ? (catalog.find(c => c.id === selected[0])?.nombre ?? 'Variable')
            : selected.length === 0
              ? 'Banco de variables'
              : `${selected.length} variables`}
          subtitle={selected.length === 0
            ? 'Selecciona una o más variables del catálogo a la izquierda'
            : selected.length === 1
              ? (() => {
                  const v = catalog.find(c => c.id === selected[0])
                  return v ? `${v.id} · ${v.frecuencia} · ${v.unidad} · ${v.fuente}` : selected[0]
                })()
              : `Comparación · ${transform === 'nivel' ? 'nivel' : transform.toUpperCase()}`}
          isLoading={loadingSeries}
          from={range[0]} to={range[1]}
          onRangeChange={(f, t) => setRange([f, t])}
          downloadName={selected.length === 1 ? selected[0] : 'grafico-personalizado'}
          fullWidth height={460}>
          {selected.length === 0 ? (
            <div className="flex items-center justify-center h-full text-[#9CA3AF] text-sm">
              Click en una variable a la izquierda para verla
            </div>
          ) : chartKind === 'bar' && selected.length === 1 ? (
            <BarChartVert
              data={(filteredData as { fecha: string; [k: string]: number | string }[])
                .filter(d => {
                  const v = d[selected[0]]
                  return typeof v === 'number' && isFinite(v as number)
                })
                .map(d => ({ fecha: d.fecha, valor: Number(d[selected[0]]) }))}
              color={PALETTE[0]}
              xFormatter={xFmt} yFormatter={yFmt}
              label={catalog.find(c => c.id === selected[0])?.nombre ?? selected[0]}/>
          ) : (
            <LineChartSimple
              data={filteredData as Record<string, number | string>[]}
              series={seriesDef}
              xFormatter={xFmt} yFormatter={yFmt}
              unit={transform === 'yoy' || transform === 'mom' ? '%' : ''}/>
          )}
        </ChartWrapper>

        {selected.length > 0 && (
          <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-3">
            <h3 className="text-[12px] font-semibold text-[#1A202C] mb-2">
              Metadata de las variables seleccionadas
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full text-[11px]">
                <thead>
                  <tr className="bg-[#F0F2F5] text-[#1A202C]">
                    {['ID','Nombre','Módulo','Frec.','Unidad','Fuente','Último','Fecha'].map(h =>
                      <th key={h} className="px-2 py-1.5 text-left font-semibold">{h}</th>)}
                  </tr>
                </thead>
                <tbody>
                  {selected.map(id => {
                    const v = catalog.find(c => c.id === id); if (!v) return null
                    const s = summaries[id]
                    return (
                      <tr key={id} className="border-t border-[#F0F2F5]">
                        <td className="px-2 py-1 font-mono text-[#1B3A5C]">{v.id}</td>
                        <td className="px-2 py-1 text-[#1A202C]">{v.nombre}</td>
                        <td className="px-2 py-1 text-[#6B7280]">{v.modulo}</td>
                        <td className="px-2 py-1 text-[#6B7280]">{v.frecuencia}</td>
                        <td className="px-2 py-1 text-[#6B7280]">{v.unidad}</td>
                        <td className="px-2 py-1 text-[#6B7280]">{v.fuente}</td>
                        <td className="px-2 py-1 text-[#1A202C] tabular-nums">{s ? fmtValue(s.ultimo_valor) : '—'}</td>
                        <td className="px-2 py-1 text-[#6B7280] tabular-nums">{s ? fmtDate(s.fecha_max) : '—'}</td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Paneles guardados (multi-chart) */}
        {savedPanels.length > 0 && (
          <div className="mt-4 space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-[13px] font-semibold text-[#1A202C]">
                Paneles guardados ({savedPanels.length})
              </h3>
              <button
                onClick={() => setSavedPanels([])}
                className="text-[10px] text-[#8B2E2E] hover:underline">
                Limpiar todos
              </button>
            </div>
            <div className="grid grid-cols-1 xl:grid-cols-2 gap-3">
              {savedPanels.map(p => (
                <SavedPanelView
                  key={p.id} panel={p} catalog={catalog} seriesMap={seriesMap}
                  onRemove={() => removePanel(p.id)} />
              ))}
            </div>
          </div>
        )}
      </section>
    </div>
  )
}

/* ─── Componente del panel guardado (mini-chart independiente) ─── */
interface SavedPanelProps {
  panel: {
    id: number
    title: string
    selected: string[]
    chartKind: ChartKind
    freq: FreqAgg
    transform: Transform
    range: [string, string]
  }
  catalog: CatalogVariable[]
  seriesMap: SeriesMap
  onRemove: () => void
}

function SavedPanelView({ panel, catalog, seriesMap, onRemove }: SavedPanelProps) {
  const { selected, chartKind, freq, transform, range } = panel

  const isDaily = freq !== 'mensual' && freq !== 'trimestral' && freq !== 'anual' &&
    selected.every(id => catalog.find(c => c.id === id)?.frecuencia === 'diaria')

  const merged = useMemo<MergedPoint[]>(() => {
    if (selected.length === 0) return []
    const grain = isDaily ? 10 : 7
    const tr: Record<string, DataPoint[]> = {}
    for (const id of selected) {
      let s = seriesMap[id] ?? []
      if (s.length === 0) continue
      s = s.filter(d => d.valor != null && isFinite(d.valor))
      s = aggregateByFreq(s, freq)
      s = applyTransform(s, transform)
      s = s.filter(d => d.valor != null && isFinite(d.valor))
      tr[id] = s.map(d => ({ ...d, fecha: d.fecha.slice(0, grain) }))
    }
    const keys = Object.keys(tr)
    if (keys.length === 0) return []
    return merge(tr, keys).map(row => {
      const out: MergedPoint = { fecha: (row.fecha as string).slice(0, grain) }
      for (const k of keys) {
        const v = row[k]
        if (typeof v === 'number' && isFinite(v)) out[k] = v
      }
      return out
    })
  }, [selected, seriesMap, freq, transform, isDaily])

  const filtered = useMemo(
    () => filterMergedByRange(merged, range[0], range[1]),
    [merged, range])

  const seriesDef = selected.map((id, i) => {
    const v = catalog.find(c => c.id === id)
    return { key: id, label: v?.nombre ?? id, color: PALETTE[i % PALETTE.length] }
  })

  const yFmt = (v: number) => {
    if (transform === 'yoy' || transform === 'mom') return `${v.toFixed(2)}%`
    return fmtValue(v)
  }
  const xFmt = (v: string) => {
    if (!v || v.length < 7) return v
    const [y, m, d] = v.split('-')
    const meses = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
    if (isDaily && d) return `${+d} ${meses[+m - 1]}`
    return `${meses[+m - 1]}'${y.slice(2)}`
  }

  return (
    <div className="bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-3 relative">
      <div className="flex items-start justify-between mb-1">
        <div className="min-w-0">
          <h4 className="text-[12px] font-semibold text-[#1A202C] truncate">{panel.title}</h4>
          <p className="text-[10px] text-[#6B7280]">
            {chartKind} · {freq} · {transform === 'nivel' ? 'nivel' : transform.toUpperCase()}
          </p>
        </div>
        <button onClick={onRemove}
          title="Quitar panel"
          className="text-[10px] text-[#8B2E2E] hover:bg-[#FEE] rounded px-1.5 py-0.5">✕</button>
      </div>
      <div style={{ height: 240 }}>
        {chartKind === 'bar' && selected.length === 1 ? (
          <BarChartVert
            data={(filtered as { fecha: string; [k: string]: number | string }[])
              .filter(d => typeof d[selected[0]] === 'number' && isFinite(d[selected[0]] as number))
              .map(d => ({ fecha: d.fecha, valor: Number(d[selected[0]]) }))}
            color={PALETTE[0]} xFormatter={xFmt} yFormatter={yFmt}
            label={catalog.find(c => c.id === selected[0])?.nombre ?? selected[0]}/>
        ) : (
          <LineChartSimple
            data={filtered as Record<string, number | string>[]}
            series={seriesDef}
            xFormatter={xFmt} yFormatter={yFmt}
            unit={transform === 'yoy' || transform === 'mom' ? '%' : ''}/>
        )}
      </div>
    </div>
  )
}
