'use client'
import { useEffect, useMemo, useState } from 'react'
import {
  ComposedChart, Line, Area, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  ResponsiveContainer, ReferenceLine,
} from 'recharts'
import ChartWrapper from '@/components/charts/ChartWrapper'
import { C } from '@/lib/colors'
import { xFmtDay, xFmtMonth } from '@/lib/utils'
import {
  type Freq, type Universo, type Categoria, type Modelo, type Agregado, type Latente,
  type LatenteParam, type Noticia, type Pesos,
  fetchCategorias, fetchModelos, fetchAgregado, fetchLatente, fetchLatenteParams,
  fetchMarkov, fetchNoticias, calcularISEC, desdeDefecto, PESOS_BASE, NOMBRE_FREQ,
  ISSUE_NUEVA_CATEGORIA, rejilla,
} from '@/lib/sentimiento'

/* Pestaña de sentimiento de prensa:
 *   ISEC  = índice compuesto (pesos editables, se calcula aquí en el navegador)
 *   ISEP  = sentimiento latente sin ruido (Kalman, calculado en el pipeline)
 *   SPS   = sentimiento observado ("ISEP con ruido")
 * Datos: sent_* en Supabase (scraper diario de Google News → GitHub Actions). */

const xFmtFor = (f: Freq) => (v: string) =>
  f === 'D' ? xFmtDay(v) : f === 'W' ? xFmtDay(v) : xFmtMonth(v)
const r4 = (v: number | null | undefined) => (v == null || !isFinite(v) ? null : Math.round(v * 10000) / 10000)
const hoyMes = () => new Date().toISOString().slice(0, 7)

export default function Sentimiento() {
  /* ── controles ─────────────────────────────────────────────────── */
  const [freq, setFreq] = useState<Freq>('W')
  const [uni, setUni] = useState<Universo>('query')
  const [cat, setCat] = useState('GEN')
  const [modelo, setModelo] = useState('pysentimiento_es')
  const [variante, setVariante] = useState<'filtrado' | 'suavizado'>('filtrado')
  const [pesos, setPesos] = useState<Pesos>(PESOS_BASE)
  const [rango, setRango] = useState<[string, string]>([desdeDefecto('W'), hoyMes()])

  /* ── datos ─────────────────────────────────────────────────────── */
  const [cats, setCats] = useState<Categoria[]>([])
  const [modelos, setModelos] = useState<Modelo[]>([])
  const [ag, setAg] = useState<Agregado[]>([])
  const [lat, setLat] = useState<Latente[]>([])
  const [mk, setMk] = useState<{ fecha: string; p_estres: number }[]>([])
  const [params, setParams] = useState<LatenteParam[]>([])
  const [noticias, setNoticias] = useState<Noticia[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([fetchCategorias(), fetchModelos()])
      .then(([c, m]) => {
        setCats(c); setModelos(m)
        const p = m.find(x => x.principal) ?? m[0]
        if (p) setModelo(p.id)
      })
      .catch(e => setError(String(e.message ?? e)))
  }, [])

  useEffect(() => {
    setLoading(true); setError(null)
    Promise.all([
      fetchAgregado(freq, [cat], uni, modelo),
      fetchLatente(freq, [cat], uni, modelo),
      freq !== 'D' && (cat === 'GEN' || cat === 'TODO') ? fetchMarkov(freq, cat, uni, modelo) : Promise.resolve([]),
      fetchLatenteParams(modelo),
    ])
      .then(([a, l, m, p]) => { setAg(a); setLat(l); setMk(m); setParams(p) })
      .catch(e => setError(String(e.message ?? e)))
      .finally(() => setLoading(false))
  }, [freq, cat, uni, modelo])

  useEffect(() => {
    fetchNoticias(modelo, cat).then(setNoticias).catch(() => setNoticias([]))
  }, [modelo, cat])

  const cambiarFreq = (f: Freq) => { setFreq(f); setRango([desdeDefecto(f), hoyMes()]) }

  const sectores = useMemo(() => cats.filter(c => c.nivel === 1).sort((a, b) => a.nombre.localeCompare(b.nombre)), [cats])
  const nombreCat = (id: string) => id === 'TODO' ? 'Todas las noticias' : (cats.find(c => c.id === id)?.nombre ?? id)
  const modeloSel = modelos.find(m => m.id === modelo)

  /* ── serie principal: ISEC + ISEP + SPS ────────────────────────── */
  const isec = useMemo(() => calcularISEC(ag, freq, pesos), [ag, freq, pesos])
  const serie = useMemo(() => {
    const L = new Map(lat.map(l => [l.fecha.slice(0, 10), l]))
    const M = new Map(mk.map(m => [m.fecha.slice(0, 10), m.p_estres]))
    return isec
      .filter(p => p.fecha.slice(0, 7) >= rango[0] && p.fecha.slice(0, 7) <= rango[1])
      .map(p => {
        const l = L.get(p.fecha)
        const v = l ? (variante === 'filtrado' ? l.filtrado : l.suavizado) : null
        const se = l ? (variante === 'filtrado' ? l.filtrado_se : l.suavizado_se) : null
        return {
          fecha: p.fecha,
          isec: r4(p.isec),
          isep: r4(v),
          banda: v != null && se != null ? [r4(v - 1.96 * se), r4(v + 1.96 * se)] : null,
          sps: r4(p.sps),
          n: p.n,
          p_estres: M.has(p.fecha) ? r4(M.get(p.fecha)!) : null,
        }
      })
  }, [isec, lat, mk, rango, variante])

  const ultimo = useMemo(() => {
    for (let i = serie.length - 1; i >= 0; i--) if (serie[i].isep != null || serie[i].isec != null) return serie[i]
    return null
  }, [serie])
  const pCat = params.find(p => p.categoria_id === cat && p.freq === freq && p.universo === uni)
  const sumaPesos = pesos.sps + pesos.atm + pesos.idm + pesos.vs
  const xFmt = xFmtFor(freq)
  const dataMin = ag[0]?.fecha.slice(0, 7) ?? '2016-01'

  return (
    <div className="space-y-4">
      {/* ── barra de controles ── */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] p-3 flex flex-wrap items-end gap-3 text-[11px]">
        <Ctrl label="Frecuencia">
          <Seg opts={(['D', 'W', 'M'] as Freq[]).map(f => [f, NOMBRE_FREQ[f]])} val={freq} on={v => cambiarFreq(v as Freq)} />
        </Ctrl>
        <Ctrl label="Categoría">
          <select value={cat} onChange={e => setCat(e.target.value)} className="border border-[#D1D9E0] rounded-md px-2 py-1.5 bg-white">
            <option value="TODO">Todas las noticias (barrido completo)</option>
            {sectores.map(s => <option key={s.id} value={s.id}>{s.nombre}{s.origen === 'usuario' ? ' ★' : ''}</option>)}
          </select>
        </Ctrl>
        <Ctrl label="Universo de noticias">
          <Seg opts={[['query', 'Búsqueda (set del paper)'], ['amplio', 'Amplio (+ palabras clave)']]} val={uni} on={v => setUni(v as Universo)} />
        </Ctrl>
        <Ctrl label="Modelo de sentimiento">
          <select value={modelo} onChange={e => setModelo(e.target.value)} className="border border-[#D1D9E0] rounded-md px-2 py-1.5 bg-white">
            {modelos.filter(m => m.activo).map(m => <option key={m.id} value={m.id}>{m.nombre}</option>)}
          </select>
        </Ctrl>
        <Ctrl label="ISEP">
          <Seg opts={[['filtrado', 'Filtrado (tiempo real)'], ['suavizado', 'Suavizado (histórico)']]} val={variante} on={v => setVariante(v as 'filtrado' | 'suavizado')} />
        </Ctrl>
        <a href={ISSUE_NUEVA_CATEGORIA} target="_blank" rel="noreferrer"
           className="ml-auto px-3 py-1.5 rounded-md bg-[#1B3A5C] text-white hover:bg-[#2D6A9F]">
          + Agregar categoría
        </a>
      </div>

      {error && <div className="bg-red-50 border border-red-200 text-red-700 text-[12px] rounded-lg p-3">
        No se pudieron leer los datos de sentimiento: {error}. ¿Se ejecutó <code>sql/noticias_schema.sql</code> en Supabase?
      </div>}

      {/* ── pesos del ISEC ── */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] p-3">
        <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-[11px]">
          <span className="font-semibold text-[#1B3A5C]">Pesos del ISEC</span>
          {([['sps', 'SPS (tono)'], ['atm', 'ln ATM (atención)'], ['idm', 'IDM (divergencia)'], ['vs', 'VS (volatilidad)']] as [keyof Pesos, string][]).map(([k, lab]) => (
            <label key={k} className="flex items-center gap-2">
              <span className="w-28 text-[#4A5568]">{lab}</span>
              <input type="range" min={0} max={1} step={0.05} value={pesos[k]}
                     onChange={e => setPesos(p => ({ ...p, [k]: Number(e.target.value) }))} className="w-28 accent-[#1B3A5C]" />
              <span className="w-8 tabular-nums">{pesos[k].toFixed(2)}</span>
            </label>
          ))}
          <span className={Math.abs(sumaPesos - 1) > 1e-9 ? 'text-amber-700' : 'text-[#9CA3AF]'}>suma {sumaPesos.toFixed(2)}</span>
          <button onClick={() => setPesos(PESOS_BASE)} className="px-2 py-1 rounded border border-[#D1D9E0] hover:bg-[#F7F8FA]">Restablecer 0.7/0.1/0.1/0.1</button>
        </div>
        <p className="text-[10px] text-[#9CA3AF] mt-1.5">
          ISEC = w₁·SPS + w₂·ln(ATM)·sign(SPS) + w₃·IDM·(−sign(SPS)) + w₄·VS ·
          ATM = N / mediana móvil 12m · IDM = min(Pos,Neg)/N · VS = −desv. est. móvil 12m del SPS
        </p>
      </div>

      {/* ── gráfico principal ── */}
      <ChartWrapper
        title={`Sentimiento de prensa · ${nombreCat(cat)}`}
        subtitle={`${NOMBRE_FREQ[freq]} · ISEC (compuesto) vs ISEP (latente, Kalman ${variante}) vs SPS observado`}
        from={rango[0]} to={rango[1]} dataMin={dataMin}
        onRangeChange={(f, t) => setRango([f, t])}
        downloadName={`sentimiento_${cat}_${freq}`} isLoading={loading} fullWidth height={360}
        lastValue={ultimo ? { label: `ISEP ${xFmt(ultimo.fecha)}`, value: ultimo.isep, valueFormatter: v => v.toFixed(3) } : undefined}
        note={pCat ? `Señal/ruido del SPS (${NOMBRE_FREQ[freq].toLowerCase()}): ${pCat.pct_ruido.toFixed(0)}% ruido · persistencia θ=${pCat.theta.toFixed(2)} · ${pCat.n_obs} períodos. Banda = ISEP ±1.96 e.e.` : undefined}
      >
        <ResponsiveContainer width="100%" height="100%">
          <ComposedChart data={serie} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
            <CartesianGrid stroke={C.gridStroke} vertical={false} />
            <XAxis dataKey="fecha" tickFormatter={xFmt} tick={{ fontSize: 10, fill: C.axisStroke }} minTickGap={40} />
            <YAxis tick={{ fontSize: 10, fill: C.axisStroke }} width={48} domain={['auto', 'auto']} tickFormatter={v => Number(v).toFixed(2)} />
            <Tooltip content={<TipSent fmt={xFmt} />} />
            <Legend wrapperStyle={{ fontSize: 11 }} />
            <ReferenceLine y={0} stroke="#CBD5E0" />
            <Area dataKey="banda" name="Banda 95% ISEP" stroke="none" fill={C.red} fillOpacity={0.12} isAnimationActive={false} connectNulls />
            <Line dataKey="sps" name="SPS observado (con ruido)" stroke="#A0AEC0" strokeWidth={freq === 'D' ? 0.6 : 1} dot={false} isAnimationActive={false} connectNulls={false} />
            <Line dataKey="isec" name="ISEC (compuesto)" stroke={C.blue} strokeWidth={1.8} dot={false} isAnimationActive={false} />
            <Line dataKey="isep" name="ISEP (latente)" stroke={C.red} strokeWidth={2} dot={false} isAnimationActive={false} />
          </ComposedChart>
        </ResponsiveContainer>
      </ChartWrapper>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* ── volumen ── */}
        <ChartWrapper title="Volumen de noticias" subtitle={`${nombreCat(cat)} · noticias por período (base de ATM)`}
                      from={rango[0]} to={rango[1]} dataMin={dataMin} onRangeChange={(f, t) => setRango([f, t])}
                      isLoading={loading} height={240} downloadName={`volumen_${cat}_${freq}`}>
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart data={serie} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
              <CartesianGrid stroke={C.gridStroke} vertical={false} />
              <XAxis dataKey="fecha" tickFormatter={xFmt} tick={{ fontSize: 10, fill: C.axisStroke }} minTickGap={40} />
              <YAxis tick={{ fontSize: 10, fill: C.axisStroke }} width={44} />
              <Tooltip labelFormatter={l => xFmt(String(l))} />
              <Bar dataKey="n" name="Noticias" fill={C.lightBlue} isAnimationActive={false} />
            </ComposedChart>
          </ResponsiveContainer>
        </ChartWrapper>

        {/* ── Markov ── */}
        <ChartWrapper title="Probabilidad de régimen de estrés"
                      subtitle={freq === 'D' ? 'Disponible en frecuencia semanal o mensual' :
                        (cat === 'GEN' || cat === 'TODO') ? 'Markov-switching 2 regímenes sobre el ISEP suavizado' : 'Disponible para General y Todas las noticias'}
                      from={rango[0]} to={rango[1]} dataMin={dataMin} onRangeChange={(f, t) => setRango([f, t])}
                      isLoading={loading} height={240} downloadName={`markov_${cat}_${freq}`}
                      note="Probabilidades suavizadas: usan toda la muestra, el último tramo puede revisarse.">
          <ResponsiveContainer width="100%" height="100%">
            <ComposedChart data={serie} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
              <CartesianGrid stroke={C.gridStroke} vertical={false} />
              <XAxis dataKey="fecha" tickFormatter={xFmt} tick={{ fontSize: 10, fill: C.axisStroke }} minTickGap={40} />
              <YAxis domain={[0, 1]} tick={{ fontSize: 10, fill: C.axisStroke }} width={36} tickFormatter={v => `${Math.round(v * 100)}%`} />
              <Tooltip labelFormatter={l => xFmt(String(l))} formatter={(v) => `${Math.round(Number(v) * 100)}%`} />
              <ReferenceLine y={0.7} stroke={C.red} strokeDasharray="4 3" />
              <Area dataKey="p_estres" name="P(estrés)" stroke={C.red} fill={C.red} fillOpacity={0.35} isAnimationActive={false} />
            </ComposedChart>
          </ResponsiveContainer>
        </ChartWrapper>
      </div>

      {/* ── mapa de calor ── */}
      <MapaCalor sectores={sectores} uni={uni} modelo={modelo} pesos={pesos} params={params}
                 onSelect={setCat} seleccion={cat} />

      {/* ── noticias + modelo ── */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">
        <div className="xl:col-span-2 bg-white rounded-xl border border-[#D1D9E0] p-4">
          <h3 className="text-[13px] font-semibold text-[#1A202C]">Últimas noticias · {nombreCat(cat)}</h3>
          <p className="text-[10px] text-[#9CA3AF] mb-2">Titular, medio y enlace a la fuente. El texto completo se guarda en el repositorio privado (no se publica).</p>
          <div className="max-h-[420px] overflow-y-auto divide-y divide-[#EEF0F4]">
            {noticias.length === 0 && <p className="text-[11px] text-[#9CA3AF] py-4">Sin noticias recientes para esta categoría.</p>}
            {noticias.map(n => (
              <div key={n.id} className="py-2 flex items-start gap-3 text-[11px]">
                <Pol v={n.polaridad} />
                <div className="min-w-0 flex-1">
                  <a href={n.url} target="_blank" rel="noreferrer" className="text-[#1A202C] hover:text-[#2D6A9F] font-medium">{n.titulo}</a>
                  <div className="text-[10px] text-[#9CA3AF] mt-0.5 flex flex-wrap gap-x-2">
                    <span>{xFmtDay(n.fecha)}</span><span>{n.medio}</span>
                    <span>{n.base === 'texto' ? 'texto completo' : 'solo titular'}</span>
                    {n.sectores.slice(0, 4).map(s => <span key={s} className="px-1 rounded bg-[#EEF0F4] text-[#4A5568]">{s}</span>)}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-xl border border-[#D1D9E0] p-4 text-[11px] space-y-3">
          <h3 className="text-[13px] font-semibold text-[#1A202C]">Modelo y categorías</h3>
          {modeloSel && (
            <div>
              <p className="font-medium">{modeloSel.nombre}</p>
              <p className="text-[#4A5568]">
                Validación vs set-oro ({modeloSel.n_oro ?? '—'} titulares etiquetados a mano):
                F1 macro <b>{modeloSel.f1_oro?.toFixed(2) ?? '—'}</b> · kappa <b>{modeloSel.kappa_oro?.toFixed(2) ?? '—'}</b>
              </p>
              {modeloSel.f1_oro != null && modeloSel.f1_oro < 0.75 &&
                <p className="text-amber-700 mt-1">F1 bajo la meta de 0.75: el modelo sub-detecta lo positivo. Leer el nivel con cautela; la dinámica es más confiable que el nivel.</p>}
            </div>
          )}
          <div>
            <p className="font-medium mb-1">{sectores.length} sectores · {cats.filter(c => c.nivel === 2).length} subcategorías</p>
            <p className="text-[#4A5568]">Universo <b>búsqueda</b>: noticias traídas por las 130 búsquedas de la investigación (comparable con el paper). <b>Amplio</b>: además, toda nota del barrido general que contenga las palabras clave de la categoría.</p>
            {cats.filter(c => c.origen === 'usuario').length > 0 && (
              <p className="mt-1 text-[#4A5568]">Categorías agregadas: {cats.filter(c => c.origen === 'usuario').map(c => `${c.nombre} (desde ${c.activa_desde})`).join(', ')}</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

/* ─── Mapa de calor por sector ──────────────────────────────────────── */
function MapaCalor({ sectores, uni, modelo, pesos, params, onSelect, seleccion }: {
  sectores: Categoria[]; uni: Universo; modelo: string; pesos: Pesos; params: LatenteParam[]
  onSelect: (id: string) => void; seleccion: string
}) {
  const [freq, setFreq] = useState<'W' | 'M'>('M')
  const [metrica, setMetrica] = useState<'isep' | 'isec' | 'sps'>('isep')
  const [modo, setModo] = useState<'z' | 'nivel'>('z')
  const [ag, setAg] = useState<Agregado[]>([])
  const [lat, setLat] = useState<Latente[]>([])
  const [loading, setLoading] = useState(false)
  const ids = useMemo(() => sectores.map(s => s.id), [sectores])

  useEffect(() => {
    if (!ids.length) return
    setLoading(true)
    Promise.all([fetchAgregado(freq, ids, uni, modelo), fetchLatente(freq, ids, uni, modelo)])
      .then(([a, l]) => { setAg(a); setLat(l) })
      .finally(() => setLoading(false))
  }, [ids, freq, uni, modelo])

  const nCols = freq === 'M' ? 24 : 26
  const { cols, filas } = useMemo(() => {
    const ultima = [...ag.map(a => a.fecha.slice(0, 10))].sort().pop()
    if (!ultima) return { cols: [] as string[], filas: [] as { id: string; nombre: string; vals: (number | null)[]; ns: number[]; z: (number | null)[] }[] }
    const todas = rejilla(freq === 'M' ? '2016-01-01' : '2016-01-04', ultima, freq)
    const cols = todas.slice(-nCols)
    const filas = sectores.map(s => {
      const a = ag.filter(x => x.categoria_id === s.id)
      const serie: Record<string, number | null> = {}
      const nmap: Record<string, number> = {}
      for (const x of a) nmap[x.fecha.slice(0, 10)] = x.n
      if (metrica === 'isep') {
        for (const l of lat) if (l.categoria_id === s.id) serie[l.fecha.slice(0, 10)] = l.filtrado
      } else {
        const isec = calcularISEC(a, freq, pesos, ultima)
        for (const p of isec) serie[p.fecha] = metrica === 'isec' ? p.isec : p.sps
      }
      const hist = Object.values(serie).filter((v): v is number => v != null && isFinite(v))
      const mu = hist.reduce((x, y) => x + y, 0) / Math.max(1, hist.length)
      const sd = Math.sqrt(hist.reduce((x, y) => x + (y - mu) ** 2, 0) / Math.max(1, hist.length - 1)) || 1
      const vals = cols.map(c => serie[c] ?? null)
      return { id: s.id, nombre: s.nombre, vals, ns: cols.map(c => nmap[c] ?? 0), z: vals.map(v => v == null ? null : (v - mu) / sd) }
    })
    return { cols, filas }
  }, [ag, lat, sectores, freq, metrica, pesos, nCols])

  const escalaNivel = useMemo(() => {
    const all = filas.flatMap(f => f.vals).filter((v): v is number => v != null)
    return Math.max(0.05, ...all.map(Math.abs))
  }, [filas])

  const color = (v: number | null, z: number | null) => {
    const x = modo === 'z' ? (z == null ? null : Math.max(-2.5, Math.min(2.5, z)) / 2.5) : (v == null ? null : v / escalaNivel)
    if (x == null) return '#F7F8FA'
    // rojo (negativo) ↔ blanco ↔ verde (positivo)
    const a = Math.min(1, Math.abs(x))
    return x < 0 ? `rgba(139,46,46,${0.08 + 0.85 * a})` : `rgba(39,103,73,${0.08 + 0.85 * a})`
  }
  const ruido = (id: string) => params.find(p => p.categoria_id === id && p.freq === freq && p.universo === uni)?.pct_ruido

  return (
    <div className="bg-white rounded-xl border border-[#D1D9E0] p-4">
      <div className="flex flex-wrap items-end gap-3 mb-3 text-[11px]">
        <div>
          <h3 className="text-[13px] font-semibold text-[#1A202C]">Mapa de calor por sector</h3>
          <p className="text-[10px] text-[#9CA3AF]">
            {modo === 'z' ? 'Desviación respecto de la media histórica de cada sector (z). Verde = mejor clima que lo usual.' :
              'Nivel absoluto. La prensa es mayormente negativa: el nivel tiende a rojo.'} Clic en un sector para verlo arriba.
          </p>
        </div>
        <div className="ml-auto flex flex-wrap gap-2">
          <Seg opts={[['M', 'Mensual'], ['W', 'Semanal']]} val={freq} on={v => setFreq(v as 'W' | 'M')} />
          <Seg opts={[['isep', 'ISEP'], ['isec', 'ISEC'], ['sps', 'SPS']]} val={metrica} on={v => setMetrica(v as 'isep' | 'isec' | 'sps')} />
          <Seg opts={[['z', 'Desviación'], ['nivel', 'Nivel']]} val={modo} on={v => setModo(v as 'z' | 'nivel')} />
        </div>
      </div>
      {loading ? <p className="text-[11px] text-[#9CA3AF] py-8 text-center">Cargando…</p> : (
        <div className="overflow-x-auto">
          <table className="border-separate text-[10px]" style={{ borderSpacing: 2 }}>
            <thead>
              <tr>
                <th className="text-left font-medium text-[#6B7280] pr-2 sticky left-0 bg-white">Sector</th>
                <th className="font-medium text-[#6B7280] px-1" title="% del SPS que es ruido según el filtro de Kalman">% ruido</th>
                {cols.map((c, i) => (
                  <th key={c} className="font-normal text-[#9CA3AF] w-7" style={{ writingMode: 'vertical-rl', transform: 'rotate(180deg)', height: 44 }}>
                    {i % (freq === 'M' ? 3 : 4) === 0 || i === cols.length - 1 ? (freq === 'M' ? xFmtMonth(c) : xFmtDay(c)) : ''}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filas.map(f => {
                const r = ruido(f.id)
                return (
                  <tr key={f.id} className={f.id === seleccion ? 'outline outline-1 outline-[#1B3A5C]' : ''}>
                    <td className="pr-2 whitespace-nowrap sticky left-0 bg-white">
                      <button onClick={() => onSelect(f.id)} className="hover:text-[#2D6A9F] text-left">{f.nombre}</button>
                    </td>
                    <td className={`px-1 text-center tabular-nums ${r != null && r > 85 ? 'text-amber-700' : 'text-[#4A5568]'}`}>{r != null ? `${r.toFixed(0)}%` : '—'}</td>
                    {f.vals.map((v, i) => (
                      <td key={cols[i]} className="w-7 h-5 rounded-sm" style={{ background: color(v, f.z[i]) }}
                          title={`${f.nombre} · ${freq === 'M' ? xFmtMonth(cols[i]) : xFmtDay(cols[i])}\n${metrica.toUpperCase()}: ${v == null ? '—' : v.toFixed(3)}${f.z[i] != null ? `  (z ${f.z[i]!.toFixed(2)})` : ''}\nnoticias: ${f.ns[i]}`} />
                    ))}
                  </tr>
                )
              })}
            </tbody>
          </table>
          <p className="text-[10px] text-[#9CA3AF] mt-2">% ruido &gt; 85 (ámbar): la señal sectorial es casi toda ruido a esta frecuencia; interpretar con cautela (investigación §2).</p>
        </div>
      )}
    </div>
  )
}

/* ─── piezas pequeñas ───────────────────────────────────────────────── */
function Ctrl({ label, children }: { label: string; children: React.ReactNode }) {
  return <div className="flex flex-col gap-1"><span className="text-[10px] text-[#6B7280]">{label}</span>{children}</div>
}
function Seg({ opts, val, on }: { opts: [string, string][]; val: string; on: (v: string) => void }) {
  return (
    <div className="inline-flex rounded-md border border-[#D1D9E0] overflow-hidden">
      {opts.map(([v, l]) => (
        <button key={v} onClick={() => on(v)}
                className={`px-2.5 py-1.5 text-[11px] ${val === v ? 'bg-[#1B3A5C] text-white' : 'bg-white text-[#4A5568] hover:bg-[#F7F8FA]'}`}>{l}</button>
      ))}
    </div>
  )
}
function Pol({ v }: { v: number }) {
  const c = v > 0.15 ? C.green : v < -0.15 ? C.red : C.gray
  return <span className="shrink-0 w-12 text-right tabular-nums font-semibold" style={{ color: c }}>{v > 0 ? '+' : ''}{v.toFixed(2)}</span>
}
function TipSent({ active, payload, label, fmt }: {
  active?: boolean; payload?: { name: string; value: number | number[]; color: string; dataKey: string }[]; label?: string; fmt: (v: string) => string
}) {
  if (!active || !payload?.length) return null
  const n = (payload[0] as unknown as { payload: { n: number } }).payload?.n
  return (
    <div className="bg-[#1A202C] text-white text-[11px] px-3 py-2 rounded-lg shadow-lg">
      <p className="font-medium mb-1">{fmt(String(label))} · {n ?? 0} noticias</p>
      {payload.filter(p => p.dataKey !== 'banda' && p.value != null).map(p => (
        <p key={p.dataKey} style={{ color: p.color === '#A0AEC0' ? '#CBD5E0' : p.color }}>
          {p.name}: {(p.value as number).toFixed(3)}
        </p>
      ))}
    </div>
  )
}
