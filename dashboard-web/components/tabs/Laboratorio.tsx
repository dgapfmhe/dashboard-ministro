'use client'
import { useEffect, useMemo, useState } from 'react'
import {
  ComposedChart, Line, Area, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  ResponsiveContainer, ReferenceLine, Scatter,
} from 'recharts'
import { type CatalogVariable } from '@/lib/queries'
import { C, PALETTE } from '@/lib/colors'
import { xFmtMonth, xFmtQuarter } from '@/lib/utils'
import { fetchCategorias, fetchModelos, PESOS_BASE, type Categoria, type Pesos, type Universo } from '@/lib/sentimiento'
import {
  useMotorPython, serieDashboard, fetchCatalogoRapido, seriesSentimiento, fetchPredOficiales,
  NOMBRE_TRANSF, NOMBRE_TIPO, NOMBRE_SENT,
  type Transformacion, type Agregacion, type TipoModelo, type ModeloSpec, type ExogIn,
  type Payload, type Resultado, type ResultadoModelo, type Metricas, type FuenteSent,
  type PredOficial, type PredMetrica,
} from '@/lib/laboratorio'

/* Laboratorio de pronósticos t+1 con sentimiento de prensa.
 * Python (statsmodels) corre EN EL NAVEGADOR vía Pyodide → /lab/laboratorio.py,
 * el mismo motor que emite los pronósticos oficiales en GitHub Actions.
 * Siempre compara contra paseo aleatorio y AR (Diebold-Mariano). */

type OtraExog = { id: string; nombre: string; transformacion: Transformacion; rezago: number; agregacion: Agregacion }
let _uid = 0
const nuevoId = (t: string) => `${t}_${++_uid}`

const MODELOS_INICIALES: ModeloSpec[] = [
  { id: 'arima_1', tipo: 'arima', p: 1, d: 0, q: 1 },
  { id: 'sarimax_1', tipo: 'sarimax', p: 1, d: 0, q: 1, P: 0, D: 0, Q: 0, s: 12 },
  { id: 'arx_1', tipo: 'arx', p: 2 },
]

const f3 = (v: number | null | undefined, d = 3) => (v == null || !isFinite(v) ? '—' : v.toFixed(d))
const pct = (v: number | null | undefined) => (v == null || !isFinite(v) ? '—' : `${Math.round(v * 100)}%`)

export default function Laboratorio() {
  const motor = useMotorPython()
  const [catalogo, setCatalogo] = useState<CatalogVariable[]>([])
  const [cats, setCats] = useState<Categoria[]>([])
  const [modeloSent, setModeloSent] = useState('pysentimiento_es')

  /* ── configuración ── */
  const [objetivo, setObjetivo] = useState('ipc_rd')
  const [transf, setTransf] = useState<Transformacion>('pct_mm')
  const [freq, setFreq] = useState<'M' | 'Q'>('M')
  const [agreg, setAgreg] = useState<Agregacion>('promedio')
  const [desde, setDesde] = useState('2017-01')
  const [interanual, setInteranual] = useState(true)

  const [sentSel, setSentSel] = useState<Record<FuenteSent, boolean>>({ isec: true, isep: false, sps: false })
  const [sentCat, setSentCat] = useState('GEN')
  const [sentUni, setSentUni] = useState<Universo>('query')
  const [sentRezago, setSentRezago] = useState(0)
  const [pesos, setPesos] = useState<Pesos>(PESOS_BASE)

  const [otras, setOtras] = useState<OtraExog[]>([])
  const [nuevaExog, setNuevaExog] = useState('')
  const [modelos, setModelos] = useState<ModeloSpec[]>(MODELOS_INICIALES)
  const [esquema, setEsquema] = useState<'expanding' | 'rolling'>('expanding')
  const [ventana, setVentana] = useState(60)
  const [minTrain, setMinTrain] = useState(36)
  const [reest, setReest] = useState(12)

  /* ── resultados ── */
  const [res, setRes] = useState<Resultado | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [selModelo, setSelModelo] = useState<string>('')
  const [verIA, setVerIA] = useState(false)
  const [oficiales, setOficiales] = useState<{ nowcast: PredOficial[]; vintages: PredOficial[]; metricas: PredMetrica[]; error: string | null } | null>(null)

  useEffect(() => {
    fetchCatalogoRapido().then(setCatalogo).catch(() => {})
    fetchCategorias().then(setCats).catch(() => {})
    fetchModelos().then(m => { const p = m.find(x => x.principal); if (p) setModeloSent(p.id) }).catch(() => {})
    fetchPredOficiales().then(setOficiales).catch(() => {})
    motor.precargar()   // empieza a bajar Python en segundo plano
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const varObj = catalogo.find(v => v.id === objetivo)
  const grupos = useMemo(() => {
    const g: Record<string, CatalogVariable[]> = {}
    for (const v of catalogo) if (v.frecuencia !== 'anual') (g[v.modulo] ??= []).push(v)
    for (const k of Object.keys(g)) g[k].sort((a, b) => a.nombre.localeCompare(b.nombre))
    return g
  }, [catalogo])
  const sectores = cats.filter(c => c.nivel === 1).sort((a, b) => a.nombre.localeCompare(b.nombre))
  const sentActivas = (Object.keys(sentSel) as FuenteSent[]).filter(k => sentSel[k])

  const correr = async () => {
    setError(null)
    try {
      const [obj, sent, ...otrasS] = await Promise.all([
        serieDashboard(objetivo),
        sentActivas.length ? seriesSentimiento(sentCat, sentUni, modeloSent, pesos) : Promise.resolve(null),
        ...otras.map(o => serieDashboard(o.id)),
      ])
      const exogenas: ExogIn[] = []
      if (sent) for (const k of sentActivas) {
        exogenas.push({ id: `${k}_${sentCat}`, nombre: `${NOMBRE_SENT[k]} ${sentCat}`, ...sent[k],
                        rezago: sentRezago, transformacion: 'nivel', agregacion: 'promedio' })
      }
      otras.forEach((o, i) => exogenas.push({ ...o, ...otrasS[i] }))
      const payload: Payload = {
        objetivo: { id: objetivo, ...obj, agregacion: agreg },
        frecuencia: freq, transformacion: transf, desde: `${desde}-01`,
        escala_interanual: interanual && transf === 'pct_mm',
        exogenas, modelos,
        backtest: { esquema, ventana, min_train: minTrain, reestimar_cada: reest },
      }
      const r = await motor.correr(payload)
      setRes(r)
      const mejor = mejorModelo(r)
      setSelModelo(mejor?.id ?? r.modelos[0]?.id ?? '')
      setVerIA(r.interanual)
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    }
  }

  const ocupado = motor.estado === 'corriendo'
  const xFmt = freq === 'Q' ? xFmtQuarter : xFmtMonth

  return (
    <div className="grid grid-cols-1 xl:grid-cols-[380px_1fr] gap-4 items-start">
      {/* ═════════════ PANEL DE CONFIGURACIÓN ═════════════ */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] p-4 space-y-4 text-[11px] xl:sticky xl:top-16 xl:max-h-[calc(100vh-5rem)] xl:overflow-y-auto">
        <Seccion titulo="1 · Variable a pronosticar">
          <select value={objetivo} onChange={e => setObjetivo(e.target.value)} className={inp + ' w-full'}>
            {Object.entries(grupos).map(([mod, vs]) => (
              <optgroup key={mod} label={mod}>
                {vs.map(v => <option key={v.id} value={v.id}>{v.nombre} ({v.frecuencia})</option>)}
              </optgroup>
            ))}
          </select>
          <div className="grid grid-cols-2 gap-2">
            <Campo label="Transformación">
              <select value={transf} onChange={e => setTransf(e.target.value as Transformacion)} className={inp}>
                {(Object.keys(NOMBRE_TRANSF) as Transformacion[]).map(t => <option key={t} value={t}>{NOMBRE_TRANSF[t]}</option>)}
              </select>
            </Campo>
            <Campo label="Frecuencia de trabajo">
              <select value={freq} onChange={e => setFreq(e.target.value as 'M' | 'Q')} className={inp}>
                <option value="M">Mensual</option><option value="Q">Trimestral</option>
              </select>
            </Campo>
            <Campo label={`Agregación${varObj ? ` (origen ${varObj.frecuencia})` : ''}`}>
              <select value={agreg} onChange={e => setAgreg(e.target.value as Agregacion)} className={inp}>
                <option value="promedio">Promedio</option><option value="ultimo">Último</option><option value="suma">Suma</option>
              </select>
            </Campo>
            <Campo label="Muestra desde">
              <input type="month" value={desde} onChange={e => setDesde(e.target.value)} className={inp} />
            </Campo>
          </div>
          {transf === 'pct_mm' && (
            <label className="flex items-center gap-2"><input type="checkbox" checked={interanual} onChange={e => setInteranual(e.target.checked)} />
              Evaluar también en escala interanual (como el notebook)</label>
          )}
        </Seccion>

        <Seccion titulo="2 · Sentimiento como regresor">
          <div className="flex flex-wrap gap-3">
            {(Object.keys(NOMBRE_SENT) as FuenteSent[]).map(k => (
              <label key={k} className="flex items-center gap-1.5">
                <input type="checkbox" checked={sentSel[k]} onChange={e => setSentSel(s => ({ ...s, [k]: e.target.checked }))} />{NOMBRE_SENT[k]}
              </label>
            ))}
          </div>
          <div className="grid grid-cols-2 gap-2">
            <Campo label="Categoría">
              <select value={sentCat} onChange={e => setSentCat(e.target.value)} className={inp}>
                <option value="TODO">Todas las noticias</option>
                {sectores.map(s => <option key={s.id} value={s.id}>{s.nombre}</option>)}
              </select>
            </Campo>
            <Campo label="Universo">
              <select value={sentUni} onChange={e => setSentUni(e.target.value as Universo)} className={inp}>
                <option value="query">Búsqueda (paper)</option><option value="amplio">Amplio</option>
              </select>
            </Campo>
            <Campo label="Rezago del sentimiento">
              <select value={sentRezago} onChange={e => setSentRezago(Number(e.target.value))} className={inp}>
                <option value={0}>t (mismo período — ya se conoce)</option>
                <option value={1}>t-1</option><option value={2}>t-2</option><option value={3}>t-3</option>
              </select>
            </Campo>
          </div>
          {sentSel.isec && (
            <div className="grid grid-cols-4 gap-1">
              {(['sps', 'atm', 'idm', 'vs'] as (keyof Pesos)[]).map(k => (
                <Campo key={k} label={`w ${k.toUpperCase()}`}>
                  <input type="number" step={0.05} min={0} max={1} value={pesos[k]}
                         onChange={e => setPesos(p => ({ ...p, [k]: Number(e.target.value) }))} className={inp} />
                </Campo>
              ))}
            </div>
          )}
          <p className="text-[10px] text-[#9CA3AF]">Con rezago t, el sentimiento del mes a pronosticar ya está completo cuando sale el dato oficial (la ventaja del nowcast). El ISEP suavizado no se ofrece: usa información futura.</p>
        </Seccion>

        <Seccion titulo="3 · Otras exógenas del dashboard">
          {otras.map((o, i) => (
            <div key={o.id + i} className="flex items-center gap-1">
              <span className="flex-1 truncate" title={o.nombre}>{o.nombre}</span>
              <select value={o.transformacion} onChange={e => setOtras(xs => xs.map((x, j) => j === i ? { ...x, transformacion: e.target.value as Transformacion } : x))} className={inp + ' w-24'}>
                {(Object.keys(NOMBRE_TRANSF) as Transformacion[]).map(t => <option key={t} value={t}>{NOMBRE_TRANSF[t]}</option>)}
              </select>
              <select value={o.rezago} onChange={e => setOtras(xs => xs.map((x, j) => j === i ? { ...x, rezago: Number(e.target.value) } : x))} className={inp + ' w-14'}>
                {[0, 1, 2, 3, 6, 12].map(r => <option key={r} value={r}>t-{r}</option>)}
              </select>
              <button onClick={() => setOtras(xs => xs.filter((_, j) => j !== i))} className="px-1.5 text-red-700">×</button>
            </div>
          ))}
          <div className="flex gap-1">
            <select value={nuevaExog} onChange={e => setNuevaExog(e.target.value)} className={inp + ' flex-1'}>
              <option value="">Agregar variable…</option>
              {Object.entries(grupos).map(([mod, vs]) => (
                <optgroup key={mod} label={mod}>{vs.map(v => <option key={v.id} value={v.id}>{v.nombre}</option>)}</optgroup>
              ))}
            </select>
            <button disabled={!nuevaExog} onClick={() => {
              const v = catalogo.find(x => x.id === nuevaExog)
              if (v) setOtras(xs => [...xs, { id: v.id, nombre: v.nombre, transformacion: 'pct_mm', rezago: 1, agregacion: 'promedio' }])
              setNuevaExog('')
            }} className="px-2 rounded-md border border-[#D1D9E0] disabled:opacity-40">+</button>
          </div>
          <p className="text-[10px] text-[#9CA3AF]">Rezago ≥1 por defecto: los datos macro se publican con retraso (con t podrías usar información que no existía al pronosticar).</p>
        </Seccion>

        <Seccion titulo="4 · Modelos">
          <p className="text-[10px] text-[#6B7280]">Siempre se incluyen como referencia: <b>paseo aleatorio</b> y <b>AR(p) automático</b>.</p>
          {modelos.map((m, i) => (
            <EditorModelo key={m.id} m={m} onChange={nm => setModelos(xs => xs.map((x, j) => j === i ? nm : x))}
                          onRemove={() => setModelos(xs => xs.filter((_, j) => j !== i))} />
          ))}
          <select value="" onChange={e => {
            const t = e.target.value as TipoModelo
            if (!t) return
            const base: ModeloSpec = { id: nuevoId(t), tipo: t }
            if (t === 'arima' || t === 'sarimax') Object.assign(base, { p: 1, d: 0, q: 1, P: 0, D: 0, Q: 0, s: 12 })
            if (t === 'arx') base.p = 2
            if (t === 'var') { base.p = 'auto'; base.pmax = 4 }
            setModelos(xs => [...xs, base])
          }} className={inp + ' w-full'}>
            <option value="">+ Agregar modelo…</option>
            {(['arima', 'sarimax', 'arx', 'var', 'media'] as TipoModelo[]).map(t => <option key={t} value={t}>{NOMBRE_TIPO[t]}</option>)}
          </select>
        </Seccion>

        <Seccion titulo="5 · Evaluación fuera de muestra (t+1)">
          <div className="grid grid-cols-2 gap-2">
            <Campo label="Esquema">
              <select value={esquema} onChange={e => setEsquema(e.target.value as 'expanding' | 'rolling')} className={inp}>
                <option value="expanding">Ventana creciente</option><option value="rolling">Ventana móvil</option>
              </select>
            </Campo>
            {esquema === 'rolling' && <Campo label="Tamaño ventana"><input type="number" min={24} value={ventana} onChange={e => setVentana(Number(e.target.value))} className={inp} /></Campo>}
            <Campo label="Mín. entrenamiento"><input type="number" min={12} value={minTrain} onChange={e => setMinTrain(Number(e.target.value))} className={inp} /></Campo>
            <Campo label="Re-estimar cada (períodos)"><input type="number" min={1} value={reest} onChange={e => setReest(Number(e.target.value))} className={inp} /></Campo>
          </div>
        </Seccion>

        <button onClick={correr} disabled={ocupado}
                className="w-full py-2.5 rounded-lg bg-[#1B3A5C] text-white text-[12px] font-semibold hover:bg-[#2D6A9F] disabled:opacity-60">
          {ocupado ? 'Calculando…' : 'Correr laboratorio'}
        </button>
        <EstadoMotor estado={motor.estado} texto={motor.texto} progreso={motor.progreso} />
      </div>

      {/* ═════════════ RESULTADOS ═════════════ */}
      <div className="space-y-4 min-w-0">
        {error && <div className="bg-red-50 border border-red-200 text-red-700 text-[12px] rounded-lg p-3">{error}</div>}
        {!res && !error && (
          <div className="bg-white rounded-xl border border-[#D1D9E0] p-6 text-[12px] text-[#4A5568] space-y-2">
            <p className="font-semibold text-[#1A202C] text-[14px]">Laboratorio de pronósticos de corto plazo (t+1)</p>
            <p>Elige la variable, cómo entra el sentimiento (ISEC, ISEP filtrado o SPS con ruido) y los modelos. Cada modelo se evalúa fuera de muestra re-estimando paso a paso y se compara contra un paseo aleatorio y un AR con la prueba de Diebold-Mariano.</p>
            <p>Python corre en tu navegador: la primera vez tarda ~20-40 s en cargar.</p>
            <p className="text-[#9CA3AF]">Referencia de la investigación: el ISEC general no mejoró al AR para inflación e IMAE agregados (DM no significativo). Usa este laboratorio para verificarlo con los datos nuevos, por sector y con texto completo.</p>
          </div>
        )}
        {res && <Resultados res={res} sel={selModelo} setSel={setSelModelo} verIA={verIA} setVerIA={setVerIA} xFmt={xFmt} transf={transf} />}
        <Oficiales datos={oficiales} />
      </div>
    </div>
  )
}

/* ─── Resultados ────────────────────────────────────────────────────── */
function mejorModelo(r: Resultado): ResultadoModelo | undefined {
  return [...r.modelos].filter(m => !m.error && m.metricas?.rmse != null)
    .sort((a, b) => (a.metricas!.rmse! - b.metricas!.rmse!))[0]
}

function Resultados({ res, sel, setSel, verIA, setVerIA, xFmt, transf }: {
  res: Resultado; sel: string; setSel: (s: string) => void; verIA: boolean; setVerIA: (b: boolean) => void
  xFmt: (v: string) => string; transf: Transformacion
}) {
  const ok = res.modelos.filter(m => !m.error)
  const m = ok.find(x => x.id === sel) ?? ok[0]
  const mejor = mejorModelo(res)
  const unidad = transf === 'nivel' || transf === 'dif' || transf === 'dif_aa' ? '' : '%'

  /* abanico: últimos 36 períodos + t+1 del modelo elegido */
  const abanico = useMemo(() => {
    const n = res.serie.fechas.length
    const pts: Record<string, unknown>[] = res.serie.fechas.slice(Math.max(0, n - 36)).map((f, i, arr) => ({
      fecha: f, real: res.serie.y[n - arr.length + i],
    }))
    const last = pts[pts.length - 1]
    const p = m?.pronostico
    if (p && p.media != null && last) {
      const y0 = last.real as number
      last.b95 = [y0, y0]; last.b80 = [y0, y0]; last.pron = y0
      pts.push({ fecha: p.fecha, pron: p.media, b95: [p.li95, p.ls95], b80: [p.li80, p.ls80] })
    }
    return pts
  }, [res, m])

  /* backtest: real vs modelos */
  const bt = useMemo(() => {
    const filas: Record<string, Record<string, unknown>> = {}
    for (const mo of ok) {
      const b = verIA && mo.backtest_interanual ? mo.backtest_interanual : mo.backtest
      if (!b) continue
      b.fechas.forEach((f, i) => {
        const r = (filas[f] ??= { fecha: f })
        r.real = b.real[i]; r[mo.id] = b.pred[i]
      })
    }
    return Object.values(filas).sort((a, b) => String(a.fecha).localeCompare(String(b.fecha)))
  }, [ok, verIA])

  const met = (x: ResultadoModelo): Metricas | undefined => (verIA ? x.metricas_interanual : x.metricas)

  return (
    <>
      {res.avisos.length > 0 && (
        <div className="bg-amber-50 border border-amber-200 text-amber-800 text-[11px] rounded-lg p-3 space-y-0.5">
          {res.avisos.map((a, i) => <p key={i}>⚠ {a}</p>)}
        </div>
      )}

      {/* tarjetas t+1 */}
      <div className="bg-white rounded-xl border border-[#D1D9E0] p-4">
        <div className="flex flex-wrap items-baseline gap-2 mb-3">
          <h3 className="text-[14px] font-semibold text-[#1A202C]">Pronóstico para {xFmt(res.fecha_pronostico)}</h3>
          <span className="text-[10px] text-[#9CA3AF]">muestra {xFmt(res.muestra.desde)} – {xFmt(res.muestra.hasta)} · {res.muestra.n} períodos
            {Object.keys(res.exog_sig).length > 0 && ` · exógenas en t+1: ${Object.entries(res.exog_sig).map(([k, v]) => `${k} = ${f3(v)}`).join(', ')}`}</span>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 2xl:grid-cols-4 gap-2">
          {res.modelos.map(x => (
            <button key={x.id} onClick={() => !x.error && setSel(x.id)}
                    className={`text-left rounded-lg border p-2.5 ${x.id === m?.id ? 'border-[#1B3A5C] bg-[#F4F7FB]' : 'border-[#E2E8F0] hover:bg-[#F7F8FA]'}`}>
              <div className="flex items-center gap-1 text-[10px] text-[#6B7280]">
                <span className="truncate">{x.nombre}</span>
                {x.benchmark && <span className="px-1 rounded bg-[#EEF0F4]">referencia</span>}
                {mejor?.id === x.id && <span className="px-1 rounded bg-green-100 text-green-800">menor RMSE</span>}
              </div>
              {x.error ? <p className="text-[10px] text-red-700 mt-1">{x.error}</p> : (
                <>
                  <p className="text-[18px] font-semibold text-[#1A202C] tabular-nums">{f3(x.pronostico?.media)}{unidad}</p>
                  <p className="text-[10px] text-[#6B7280] tabular-nums">95%: [{f3(x.pronostico?.li95, 2)} ; {f3(x.pronostico?.ls95, 2)}]
                    {x.pronostico?.interanual != null && <> · interanual <b>{f3(x.pronostico.interanual, 2)}%</b></>}</p>
                  <p className="text-[10px] tabular-nums mt-0.5">
                    <span className={(met(x)?.rrmse_ar ?? 1) < 1 ? 'text-green-700' : 'text-[#6B7280]'}>RMSE/AR {f3(met(x)?.rrmse_ar, 2)}</span>
                    {met(x)?.p_dm_ar != null && <span className={(met(x)!.p_dm_ar! < 0.1) ? 'text-green-700 font-semibold' : 'text-[#9CA3AF]'}> · DM p={f3(met(x)?.p_dm_ar, 2)}</span>}
                  </p>
                </>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* abanico */}
      <Tarjeta titulo={`Abanico · ${m?.nombre ?? ''}`} sub="Últimos 36 períodos observados y pronóstico t+1 con bandas de 80% y 95%">
        <ResponsiveContainer width="100%" height={280}>
          <ComposedChart data={abanico} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
            <CartesianGrid stroke={C.gridStroke} vertical={false} />
            <XAxis dataKey="fecha" tickFormatter={xFmt} tick={{ fontSize: 10, fill: C.axisStroke }} minTickGap={30} />
            <YAxis tick={{ fontSize: 10, fill: C.axisStroke }} width={44} domain={['auto', 'auto']} tickFormatter={v => Number(v).toFixed(2)} />
            <Tooltip labelFormatter={l => xFmt(String(l))} formatter={(v) => Array.isArray(v) ? v.map(x => f3(Number(x), 2)).join(' – ') : f3(Number(v))} />
            <Area dataKey="b95" name="95%" stroke="none" fill={C.red} fillOpacity={0.12} isAnimationActive={false} />
            <Area dataKey="b80" name="80%" stroke="none" fill={C.red} fillOpacity={0.22} isAnimationActive={false} />
            <Line dataKey="real" name="Observado" stroke={C.blue} strokeWidth={2} dot={false} isAnimationActive={false} />
            <Line dataKey="pron" name="Pronóstico" stroke={C.red} strokeWidth={2} strokeDasharray="4 3" dot={{ r: 3 }} isAnimationActive={false} />
          </ComposedChart>
        </ResponsiveContainer>
      </Tarjeta>

      {/* backtest */}
      <Tarjeta titulo="Evaluación fuera de muestra (1 paso adelante)" sub="Cada punto se pronosticó solo con información disponible hasta el período anterior"
               extra={res.interanual ? <Seg opts={[['no', 'Escala del modelo'], ['si', 'Escala interanual']]} val={verIA ? 'si' : 'no'} on={v => setVerIA(v === 'si')} /> : null}>
        <ResponsiveContainer width="100%" height={300}>
          <ComposedChart data={bt} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
            <CartesianGrid stroke={C.gridStroke} vertical={false} />
            <XAxis dataKey="fecha" tickFormatter={xFmt} tick={{ fontSize: 10, fill: C.axisStroke }} minTickGap={30} />
            <YAxis tick={{ fontSize: 10, fill: C.axisStroke }} width={44} domain={['auto', 'auto']} tickFormatter={v => Number(v).toFixed(2)} />
            <Tooltip labelFormatter={l => xFmt(String(l))} formatter={(v) => f3(Number(v))} />
            <Legend wrapperStyle={{ fontSize: 10 }} />
            <ReferenceLine y={0} stroke="#CBD5E0" />
            <Scatter dataKey="real" name="Observado" fill="#1A202C" isAnimationActive={false} />
            {ok.map((x, i) => (
              <Line key={x.id} dataKey={x.id} name={x.nombre} stroke={PALETTE[(i + 1) % PALETTE.length]}
                    strokeWidth={x.id === m?.id ? 2.2 : 1} strokeDasharray={x.benchmark ? '3 3' : undefined}
                    dot={false} isAnimationActive={false} connectNulls />
            ))}
          </ComposedChart>
        </ResponsiveContainer>
      </Tarjeta>

      {/* métricas */}
      <Tarjeta titulo={`Métricas${verIA ? ' (escala interanual)' : ''}`}
               sub="RMSE/AR < 1 = mejor que el AR. DM p = prueba de Diebold-Mariano (HLN), H1: el modelo tiene menor error que el AR; p < 0.10 en verde.">
        <div className="overflow-x-auto">
          <table className="w-full text-[11px] tabular-nums">
            <thead><tr className="text-[#6B7280] border-b border-[#E2E8F0]">
              {['Modelo', 'n', 'MAE', 'RMSE', 'RMSE/AR', 'DM p vs AR', 'RMSE/PA', 'DM p vs PA', 'Acierto dirección', 'Cobertura 95%', 'Sesgo'].map(h =>
                <th key={h} className="text-right first:text-left font-medium py-1.5 px-2 whitespace-nowrap">{h}</th>)}
            </tr></thead>
            <tbody>
              {res.modelos.map(x => {
                const q = met(x)
                return (
                  <tr key={x.id} className={`border-b border-[#F1F3F6] ${x.id === m?.id ? 'bg-[#F4F7FB]' : ''}`}>
                    <td className="py-1.5 px-2 text-left whitespace-nowrap">{x.nombre}{x.benchmark ? ' ·ref' : ''}</td>
                    <td className="px-2 text-right">{q?.n ?? '—'}</td>
                    <td className="px-2 text-right">{f3(q?.mae)}</td>
                    <td className="px-2 text-right">{f3(q?.rmse)}</td>
                    <td className={`px-2 text-right ${(q?.rrmse_ar ?? 9) < 1 ? 'text-green-700 font-semibold' : ''}`}>{f3(q?.rrmse_ar, 2)}</td>
                    <td className={`px-2 text-right ${(q?.p_dm_ar ?? 1) < 0.1 ? 'text-green-700 font-semibold' : ''}`}>{f3(q?.p_dm_ar, 2)}</td>
                    <td className="px-2 text-right">{f3(q?.rrmse_rw, 2)}</td>
                    <td className="px-2 text-right">{f3(q?.p_dm_rw, 2)}</td>
                    <td className="px-2 text-right">{pct(q?.acierto_dir)}</td>
                    <td className="px-2 text-right">{pct(q?.cobertura95)}</td>
                    <td className="px-2 text-right">{f3(q?.sesgo)}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <p className="text-[10px] text-amber-700 mt-2">Exige ganarle a AMBAS referencias. En series muy persistentes (p. ej. IMAE interanual) el paseo aleatorio suele ser mejor que el AR: superar solo al AR no prueba que el sentimiento aporte (una variable de puro ruido puede lograrlo).</p>
        <p className="text-[10px] text-[#9CA3AF] mt-1">PA = paseo aleatorio. Acierto de dirección = % de veces que el modelo acertó si el valor sube o baja respecto al período anterior. Cobertura 95% ideal ≈ 95%.</p>
      </Tarjeta>

      {/* coeficientes y diagnóstico */}
      {m && (
        <Tarjeta titulo={`Estimación con toda la muestra · ${m.nombre}`} sub="Coeficientes (p < 0.05 en negrita) y pruebas sobre los residuos">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <table className="text-[11px] tabular-nums w-full">
              <thead><tr className="text-[#6B7280] border-b border-[#E2E8F0]">
                <th className="text-left py-1 font-medium">Parámetro</th><th className="text-right font-medium">Valor</th>
                <th className="text-right font-medium">E.E.</th><th className="text-right font-medium">p</th></tr></thead>
              <tbody>
                {(m.coef ?? []).map((c, i) => (
                  <tr key={i} className={`border-b border-[#F1F3F6] ${(c.p ?? 1) < 0.05 ? 'font-semibold' : ''}`}>
                    <td className="py-1">{c.nombre}</td><td className="text-right">{f3(c.valor, 4)}</td>
                    <td className="text-right">{f3(c.ee, 4)}</td><td className="text-right">{f3(c.p, 3)}</td>
                  </tr>
                ))}
                {!m.coef?.length && <tr><td className="py-2 text-[#9CA3AF]" colSpan={4}>Sin parámetros estimados (modelo de referencia).</td></tr>}
              </tbody>
            </table>
            <div className="text-[11px] space-y-1.5">
              <Diag nombre="Ljung-Box (autocorrelación)" p={m.diagnostico?.ljung_box_p} bueno="residuos sin autocorrelación" />
              <Diag nombre="Jarque-Bera (normalidad)" p={m.diagnostico?.jarque_bera_p} bueno="residuos normales" />
              <Diag nombre="ARCH (heterocedasticidad)" p={m.diagnostico?.arch_p} bueno="varianza constante" />
              <p className="text-[10px] text-[#9CA3AF] pt-1">p &gt; 0.05 = no se rechaza la hipótesis "buena" (verde).</p>
            </div>
          </div>
        </Tarjeta>
      )}
    </>
  )
}

/* ─── Pronósticos oficiales + historial de aciertos ─────────────────── */
function Oficiales({ datos }: { datos: { nowcast: PredOficial[]; vintages: PredOficial[]; metricas: PredMetrica[]; error: string | null } | null }) {
  if (!datos) return null
  const specs = [...new Set(datos.nowcast.map(n => n.spec_id))]
  return (
    <Tarjeta titulo="Pronósticos oficiales e historial de aciertos"
             sub="Emitidos automáticamente cada día por GitHub Actions con especificaciones fijas (config/pronosticos.yaml). El primer pronóstico emitido tras cerrar el mes queda congelado y se compara con el dato real cuando se publica.">
      {datos.error && <p className="text-[11px] text-amber-700">Aún no hay tablas de pronósticos oficiales ({datos.error}).</p>}
      {!datos.error && specs.length === 0 && <p className="text-[11px] text-[#9CA3AF]">Todavía no se han emitido pronósticos oficiales (requieren historia de sentimiento suficiente).</p>}
      <div className="space-y-4">
        {specs.map(s => {
          const now = datos.nowcast.filter(n => n.spec_id === s)
          const vin = datos.vintages.filter(v => v.spec_id === s)
          const met = datos.metricas.filter(x => x.spec_id === s)
          return (
            <div key={s}>
              <p className="text-[12px] font-semibold text-[#1A202C]">{now[0]?.descripcion ?? s}</p>
              <div className="overflow-x-auto">
                <table className="w-full text-[11px] tabular-nums mt-1">
                  <thead><tr className="text-[#6B7280] border-b border-[#E2E8F0]">
                    {['Modelo', 'Nowcast (en curso)', 'IC 95%', 'RMSE/AR (backtest)', 'DM p', 'Pronósticos congelados', 'Error medio abs. real'].map(h =>
                      <th key={h} className="text-right first:text-left font-medium py-1 px-2 whitespace-nowrap">{h}</th>)}
                  </tr></thead>
                  <tbody>
                    {now.map(n => {
                      const mm = met.find(x => x.modelo_id === n.modelo_id)
                      const vv = vin.filter(v => v.modelo_id === n.modelo_id && v.real != null && v.media != null)
                      const mae = vv.length ? vv.reduce((a, v) => a + Math.abs(v.real! - v.media!), 0) / vv.length : null
                      return (
                        <tr key={n.modelo_id} className="border-b border-[#F1F3F6]">
                          <td className="py-1 px-2 text-left">{n.modelo_nombre}</td>
                          <td className="px-2 text-right">{xFmtMonth(n.fecha_objetivo)}: <b>{f3(n.media)}</b>{n.interanual != null && ` (${f3(n.interanual, 2)}% a/a)`}</td>
                          <td className="px-2 text-right">[{f3(n.li95, 2)} ; {f3(n.ls95, 2)}]</td>
                          <td className={`px-2 text-right ${(mm?.rrmse_ar ?? 9) < 1 ? 'text-green-700' : ''}`}>{f3(mm?.rrmse_ar, 2)}</td>
                          <td className={`px-2 text-right ${(mm?.p_dm_ar ?? 1) < 0.1 ? 'text-green-700 font-semibold' : ''}`}>{f3(mm?.p_dm_ar, 2)}</td>
                          <td className="px-2 text-right">{vin.filter(v => v.modelo_id === n.modelo_id).length}</td>
                          <td className="px-2 text-right">{mae == null ? 'sin datos reales aún' : f3(mae)}</td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )
        })}
      </div>
    </Tarjeta>
  )
}

/* ─── piezas ────────────────────────────────────────────────────────── */
const inp = 'border border-[#D1D9E0] rounded-md px-2 py-1.5 bg-white text-[11px] min-w-0'

function EditorModelo({ m, onChange, onRemove }: { m: ModeloSpec; onChange: (m: ModeloSpec) => void; onRemove: () => void }) {
  const num = (k: keyof ModeloSpec, min = 0, max = 6) => (
    <input type="number" min={min} max={max} value={m[k] as number}
           onChange={e => onChange({ ...m, [k]: Number(e.target.value) })} className={inp + ' w-11 px-1'} title={String(k)} />
  )
  return (
    <div className="border border-[#E2E8F0] rounded-lg p-2 space-y-1.5">
      <div className="flex items-center gap-2">
        <span className="font-medium flex-1">{NOMBRE_TIPO[m.tipo]}</span>
        <button onClick={onRemove} className="text-red-700 px-1" title="Quitar">×</button>
      </div>
      {(m.tipo === 'arima' || m.tipo === 'sarimax') && (
        <div className="flex flex-wrap items-center gap-1 text-[10px] text-[#6B7280]">
          (p,d,q) {num('p')}{num('d', 0, 2)}{num('q')}
          {m.tipo === 'sarimax' && <>&nbsp;estacional (P,D,Q) {num('P', 0, 2)}{num('D', 0, 1)}{num('Q', 0, 2)} s {num('s', 1, 12)}</>}
        </div>
      )}
      {m.tipo === 'arx' && <div className="flex items-center gap-1 text-[10px] text-[#6B7280]">rezagos de y (p) {num('p', 0, 12)}</div>}
      {m.tipo === 'var' && (
        <div className="flex items-center gap-2 text-[10px] text-[#6B7280]">
          p <select value={String(m.p)} onChange={e => onChange({ ...m, p: e.target.value === 'auto' ? 'auto' : Number(e.target.value) })} className={inp}>
            <option value="auto">auto (AIC)</option>{[1, 2, 3, 4, 6].map(k => <option key={k} value={k}>{k}</option>)}
          </select>
          <span>usa objetivo + exógenas como endógenas (solo rezagos)</span>
        </div>
      )}
    </div>
  )
}

function EstadoMotor({ estado, texto, progreso }: { estado: string; texto: string; progreso: { f: number; nombre: string } | null }) {
  if (estado === 'cargando') return <p className="text-[10px] text-[#6B7280] flex items-center gap-2"><Spin />{texto || 'Cargando Python…'}</p>
  if (estado === 'corriendo') return (
    <div className="space-y-1">
      <div className="h-1.5 bg-[#EEF0F4] rounded"><div className="h-1.5 bg-[#2D6A9F] rounded transition-all" style={{ width: `${Math.round((progreso?.f ?? 0) * 100)}%` }} /></div>
      <p className="text-[10px] text-[#6B7280]">Evaluando: {progreso?.nombre ?? '…'}</p>
    </div>
  )
  if (estado === 'listo') return <p className="text-[10px] text-green-700">Python listo (statsmodels en el navegador).</p>
  return null
}
const Spin = () => <span className="w-3 h-3 border-2 border-[#CBD5E0] border-t-[#1B3A5C] rounded-full animate-spin inline-block" />

function Diag({ nombre, p, bueno }: { nombre: string; p?: number; bueno: string }) {
  const okp = p != null && p > 0.05
  return (
    <div className="flex items-center justify-between gap-2">
      <span>{nombre}</span>
      <span className={p == null ? 'text-[#9CA3AF]' : okp ? 'text-green-700' : 'text-amber-700'}>
        {p == null ? '—' : `p = ${p.toFixed(3)} · ${okp ? bueno : 'se rechaza'}`}</span>
    </div>
  )
}
function Seccion({ titulo, children }: { titulo: string; children: React.ReactNode }) {
  return <div className="space-y-2"><p className="text-[12px] font-semibold text-[#1B3A5C]">{titulo}</p>{children}</div>
}
function Campo({ label, children }: { label: string; children: React.ReactNode }) {
  return <label className="flex flex-col gap-0.5 min-w-0"><span className="text-[10px] text-[#6B7280]">{label}</span>{children}</label>
}
function Tarjeta({ titulo, sub, extra, children }: { titulo: string; sub?: string; extra?: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-xl border border-[#D1D9E0] p-4">
      <div className="flex flex-wrap items-start gap-2 mb-2">
        <div className="flex-1 min-w-0"><h3 className="text-[13px] font-semibold text-[#1A202C]">{titulo}</h3>
          {sub && <p className="text-[10px] text-[#9CA3AF]">{sub}</p>}</div>
        {extra}
      </div>
      {children}
    </div>
  )
}
function Seg({ opts, val, on }: { opts: [string, string][]; val: string; on: (v: string) => void }) {
  return (
    <div className="inline-flex rounded-md border border-[#D1D9E0] overflow-hidden">
      {opts.map(([v, l]) => (
        <button key={v} onClick={() => on(v)} className={`px-2.5 py-1 text-[11px] ${val === v ? 'bg-[#1B3A5C] text-white' : 'bg-white text-[#4A5568]'}`}>{l}</button>
      ))}
    </div>
  )
}
