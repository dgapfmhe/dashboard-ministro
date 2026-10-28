/* Reporte PDF del Laboratorio de Pronósticos (se genera en el navegador). */
import type { Resultado, ResultadoModelo } from './laboratorio'
import type { Juicio, PuntoFinal } from './juicio'
import { NOMBRE_MODO, NOMBRE_RIESGO } from './juicio'

export type ConfigReporte = {
  variable: string            // nombre legible
  transformacion: string      // legible
  unidad: string              // '%' o ''
  frecuencia: string
  muestraDesde: string
  exogenas: { nombre: string; detalle: string }[]
  dummies: string[]
  backtest: string
  nivel: number
  base: ResultadoModelo
  final: PuntoFinal[]
  juicio: Juicio
  fmtFecha: (f: string) => string
}

/* jsPDF con fuentes estándar solo cubre Latin-1: se traducen símbolos matemáticos. */
const MAPA: Record<string, string> = {
  'ŷ': 'y^', 'σ': 'sigma', 'Σ': 'Sum', '≥': '>=', '≤': '<=', '→': '->', '—': '-', '–': '-', 'φ': 'phi',
  'θ': 'theta', 'Φ': 'Phi', 'Θ': 'Theta', 'β': 'b', 'ε': 'e', 'ψ': 'psi', 'λ': 'lambda', '≈': '~', '±': '+/-',
  '·': '·', '′': "'", '…': '...', 'ᵢ': 'i', 'ₘ': 'm', '₁': '1', '₂': '2', 'ˢ': '^s', '²': '²', '√': 'raiz',
  '“': '"', '”': '"', '‘': "'", '’': "'", '•': '-', '⚠': '!', '×': 'x', '∝': 'prop. a', 'μ': 'mu',
}
export function txt(s: unknown): string {
  return String(s ?? '').replace(/[^\u0000-ÿ]/g, ch => MAPA[ch] ?? '')
}
const n3 = (v: number | null | undefined, d = 3) => (v == null || !isFinite(v) ? '-' : v.toFixed(d))
const pct = (v: number | null | undefined) => (v == null || !isFinite(v) ? '-' : `${Math.round(v * 100)}%`)

type RGB = [number, number, number]
type SerieG = { nombre: string; vals: (number | null)[]; color: RGB; ancho?: number; guiones?: boolean; puntos?: boolean }
type BandaG = { lo: (number | null)[]; hi: (number | null)[]; color: RGB; opacidad?: number }

/* Gráfico de líneas vectorial dibujado con jsPDF (no depende de capturar la pantalla). */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function grafico(doc: any, x0: number, y0: number, w: number, h: number, etiquetas: string[],
                 series: SerieG[], bandas: BandaG[] = [], corte?: number) {
  const valores = [...series.flatMap(s => s.vals), ...bandas.flatMap(b => [...b.lo, ...b.hi])]
    .filter((v): v is number => v != null && isFinite(v))
  if (!valores.length || etiquetas.length < 2) return
  let lo = Math.min(...valores), hi = Math.max(...valores)
  const pad = (hi - lo) * 0.08 || 1
  lo -= pad; hi += pad
  const izq = 12, abajo = 7, arriba = 7
  const px = (i: number) => x0 + izq + (w - izq - 2) * i / (etiquetas.length - 1)
  const py = (v: number) => y0 + arriba + (h - arriba - abajo) * (1 - (v - lo) / (hi - lo))
  // ejes y rejilla
  doc.setDrawColor(226, 232, 240); doc.setLineWidth(0.2); doc.setFontSize(6.5); doc.setTextColor(120, 120, 120)
  for (let k = 0; k <= 4; k++) {
    const v = lo + (hi - lo) * k / 4
    doc.line(x0 + izq, py(v), x0 + w - 2, py(v))
    doc.text(v.toFixed(Math.abs(hi - lo) < 5 ? 2 : 1), x0 + izq - 1, py(v) + 1, { align: 'right' })
  }
  const paso = Math.max(1, Math.ceil(etiquetas.length / 8))
  etiquetas.forEach((e, i) => { if (i % paso === 0 || i === etiquetas.length - 1) doc.text(txt(e), px(i), y0 + h - 1.5, { align: 'center' }) })
  if (corte != null) {
    doc.setDrawColor(160, 160, 160); doc.setLineDashPattern([0.8, 0.8], 0)
    doc.line(px(corte), y0 + arriba, px(corte), y0 + h - abajo); doc.setLineDashPattern([], 0)
  }
  // bandas (polígono lo → hi invertido)
  for (const b of bandas) {
    const idx = b.lo.map((v, i) => (v != null && b.hi[i] != null ? i : -1)).filter(i => i >= 0)
    if (idx.length < 2) continue
    const pts = [...idx.map(i => [px(i), py(b.lo[i]!)]), ...idx.slice().reverse().map(i => [px(i), py(b.hi[i]!)])]
    const rel = pts.slice(1).map((p, k) => [p[0] - pts[k][0], p[1] - pts[k][1]])
    doc.setGState(new doc.GState({ opacity: b.opacidad ?? 0.18 }))
    doc.setFillColor(...b.color)
    doc.lines(rel, pts[0][0], pts[0][1], [1, 1], 'F', true)
    doc.setGState(new doc.GState({ opacity: 1 }))
  }
  // series
  for (const s of series) {
    doc.setDrawColor(...s.color); doc.setLineWidth(s.ancho ?? 0.5)
    if (s.guiones) doc.setLineDashPattern([1.2, 0.9], 0)
    let prev: [number, number] | null = null
    s.vals.forEach((v, i) => {
      if (v == null || !isFinite(v)) { prev = null; return }
      const p: [number, number] = [px(i), py(v)]
      if (s.puntos) { doc.setFillColor(...s.color); doc.circle(p[0], p[1], 0.45, 'F') }
      else if (prev) doc.line(prev[0], prev[1], p[0], p[1])
      prev = p
    })
    doc.setLineDashPattern([], 0)
  }
  // leyenda
  let lx = x0 + izq
  doc.setFontSize(6.8)
  for (const s of series) {
    doc.setDrawColor(...s.color); doc.setLineWidth(0.8); doc.line(lx, y0 + 3, lx + 5, y0 + 3)
    doc.setTextColor(60, 60, 60); doc.text(txt(s.nombre), lx + 6, y0 + 4)
    lx += 9 + doc.getTextWidth(txt(s.nombre))
  }
}

export async function generarReportePDF(res: Resultado, cfg: ConfigReporte): Promise<void> {
  const { jsPDF } = await import('jspdf')
  const autoTable = (await import('jspdf-autotable')).default
  const doc = new jsPDF({ unit: 'mm', format: 'a4' })
  const W = 210, M = 14
  const AZUL: [number, number, number] = [27, 58, 92]
  const GRIS: [number, number, number] = [107, 114, 128]
  let y = 0
  const hoy = new Date()
  const emitido = hoy.toLocaleString('es-DO', { dateStyle: 'long', timeStyle: 'short' })
  const f1 = cfg.final[0]
  const j = cfg.juicio
  const u = cfg.unidad

  const titulo = (t: string) => {
    if (y > 260) { doc.addPage(); y = 18 }
    doc.setFont('helvetica', 'bold'); doc.setFontSize(12); doc.setTextColor(...AZUL)
    doc.text(txt(t), M, y); y += 2
    doc.setDrawColor(...AZUL); doc.setLineWidth(0.4); doc.line(M, y, W - M, y); y += 5
    doc.setTextColor(30, 30, 30)
  }
  const parrafo = (t: string, tam = 9.5, color: [number, number, number] = [40, 40, 40]) => {
    doc.setFont('helvetica', 'normal'); doc.setFontSize(tam); doc.setTextColor(...color)
    const lineas = doc.splitTextToSize(txt(t), W - 2 * M)
    for (const l of lineas) {
      if (y > 280) { doc.addPage(); y = 18 }
      doc.text(l, M, y); y += tam * 0.45
    }
    y += 1.5
  }
  const tabla = (head: string[], body: (string | number)[][], opts: Record<string, unknown> = {}) => {
    autoTable(doc, {
      startY: y, head: [head.map(txt)], body: body.map(r => r.map(c => txt(c))),
      margin: { left: M, right: M }, styles: { fontSize: 7.5, cellPadding: 1.4 },
      headStyles: { fillColor: AZUL, textColor: 255, fontStyle: 'bold' },
      alternateRowStyles: { fillColor: [245, 247, 250] }, ...opts,
    })
    // @ts-expect-error lastAutoTable lo agrega el plugin
    y = doc.lastAutoTable.finalY + 6
  }
  const figura = (dibujar: (x: number, y: number, w: number, h: number) => void, leyenda: string, alto = 78) => {
    if (y + alto > 280) { doc.addPage(); y = 18 }
    doc.setDrawColor(226, 232, 240); doc.setLineWidth(0.2); doc.rect(M, y, W - 2 * M, alto)
    dibujar(M + 1, y + 1, W - 2 * M - 2, alto - 2)
    y += alto + 2
    parrafo(leyenda, 8, GRIS)
  }
  const zN = ({ 50: 0.674, 68: 0.994, 80: 1.2816, 90: 1.6449, 95: 1.96 } as Record<number, number>)[cfg.nivel] ?? 1.96

  /* ── Portada / encabezado ── */
  doc.setFillColor(...AZUL); doc.rect(0, 0, W, 34, 'F')
  doc.setTextColor(255, 255, 255); doc.setFont('helvetica', 'bold'); doc.setFontSize(17)
  doc.text(txt('Reporte de pronóstico'), M, 15)
  doc.setFont('helvetica', 'normal'); doc.setFontSize(10.5)
  doc.text(txt(`${cfg.variable} · ${cfg.transformacion}`), M, 23)
  doc.setFontSize(8.5)
  doc.text(txt(`Dashboard Macro · Laboratorio de Pronósticos · emitido el ${emitido}`), M, 29.5)
  y = 44

  /* ── Resumen ejecutivo ── */
  titulo('1. Resumen ejecutivo')
  const ult = res.ultimo_real
  const final1 = f1?.final
  parrafo(`Pronóstico ${j.activo ? 'final (modelo + juicio experto)' : 'del modelo'} para ${cfg.fmtFecha(res.fecha_pronostico)}: ` +
    `${n3(final1)}${u} (intervalo ${cfg.nivel}%: ${n3(f1?.li, 2)} a ${n3(f1?.ls, 2)}${u}).` +
    (f1?.interanual_final != null ? ` Tasa interanual implícita: ${n3(f1.interanual_final, 2)}%.` : '') +
    ` Último dato observado (${cfg.fmtFecha(ult.fecha)}): ${n3(ult.valor)}${u}.`, 10.5, [20, 20, 20])
  parrafo(`Modelo base: ${cfg.base.nombre}. Su pronóstico puramente estadístico es ${n3(f1?.modelo)}${u}` +
    (j.activo && f1?.ajuste != null ? `; el juicio experto lo ajusta en ${f1.ajuste >= 0 ? '+' : ''}${n3(f1.ajuste)} (${NOMBRE_MODO[j.modo]}).` : '.'))
  const mb = cfg.base.metricas
  if (mb) {
    const ganaAR = (mb.rrmse_ar ?? 9) < 1, ganaPA = (mb.rrmse_rw ?? 9) < 1
    const sigAR = (mb.p_dm_ar ?? 1) < 0.1, sigPA = (mb.p_dm_rw ?? 1) < 0.1
    parrafo(`Desempeño fuera de muestra del modelo base (${mb.n} evaluaciones a 1 paso): RMSE ${n3(mb.rmse)}; ` +
      `RMSE relativo al AR ${n3(mb.rrmse_ar, 2)} (DM p=${n3(mb.p_dm_ar, 2)}) y al paseo aleatorio ${n3(mb.rrmse_rw, 2)} (DM p=${n3(mb.p_dm_rw, 2)}); ` +
      `acierto de dirección ${pct(mb.acierto_dir)}. ` +
      (ganaAR && ganaPA && sigAR && sigPA ? 'Supera de forma estadísticamente significativa a ambas referencias.'
        : ganaAR && ganaPA ? 'Mejora a ambas referencias, pero la diferencia no es estadísticamente significativa.'
          : 'No supera de forma consistente a las referencias simples: interpretar con cautela.'))
  }

  /* ── Trayectoria ── */
  titulo(`2. Trayectoria pronosticada (${cfg.final.length} ${cfg.final.length === 1 ? 'período' : 'períodos'})`)
  const conIA = cfg.final.some(p => p.interanual_modelo != null)
  tabla(['Período', 'Modelo', ...(j.activo ? ['Ajuste', 'Final'] : []), `Inferior ${cfg.nivel}%`, `Superior ${cfg.nivel}%`,
         ...(conIA ? ['Interanual modelo', ...(j.activo ? ['Interanual final'] : [])] : [])],
    cfg.final.map(p => [cfg.fmtFecha(p.fecha), n3(p.modelo), ...(j.activo ? [n3(p.ajuste), n3(p.final)] : []), n3(p.li, 2), n3(p.ls, 2),
      ...(conIA ? [n3(p.interanual_modelo, 2), ...(j.activo ? [n3(p.interanual_final, 2)] : [])] : [])]))
  {
    const n = res.serie.fechas.length, ini = Math.max(0, n - 36)
    const hist = res.serie.y.slice(ini), fh = res.serie.fechas.slice(ini)
    const tr = cfg.base.trayectoria ?? []
    const et = [...fh, ...tr.map(p => p.fecha)].map(cfg.fmtFecha)
    const vacio = (k: number) => Array(k).fill(null) as (number | null)[]
    const ult = hist[hist.length - 1]
    const modelo = [...vacio(hist.length - 1), ult, ...tr.map(p => p.media)]
    const fin = [...vacio(hist.length - 1), ult, ...cfg.final.map(p => p.final)]
    const lo = [...vacio(hist.length - 1), ult, ...cfg.final.map(p => p.li)]
    const hi = [...vacio(hist.length - 1), ult, ...cfg.final.map(p => p.ls)]
    figura((x, yy, w, h) => grafico(doc, x, yy, w, h, et, [
      { nombre: 'Observado', vals: [...hist, ...vacio(tr.length)], color: [27, 58, 92], ancho: 0.7 },
      { nombre: `Modelo (${cfg.base.nombre})`, vals: modelo, color: [139, 46, 46], guiones: true },
      ...(j.activo ? [{ nombre: 'Final con juicio', vals: fin, color: [39, 103, 73] as RGB, ancho: 0.8 }] : []),
    ], [{ lo, hi, color: j.activo ? [39, 103, 73] : [139, 46, 46] }], hist.length - 1),
    `Gráfico 1. Últimos 36 períodos observados y trayectoria pronosticada con banda de ${cfg.nivel}%${j.activo ? ' (línea verde: final con juicio experto)' : ''}.`)
  }

  /* ── Juicio experto ── */
  if (j.activo) {
    titulo('3. Juicio experto')
    tabla(['Elemento', 'Detalle'], [
      ['Modalidad', NOMBRE_MODO[j.modo] + (j.modo === 'mezcla' ? ` (lambda = ${j.peso})` : '')],
      ['Balance de riesgos', NOMBRE_RIESGO[j.riesgo] + (j.riesgo !== 'balanceado' ? ` (banda +${j.asimetria}% del lado del riesgo)` : '')],
      ['Valores por período', cfg.final.map((p, k) => `${cfg.fmtFecha(p.fecha)}: ${j.valores[k] ?? '-'}`).join(' · ')],
      ['Autor', j.autor || '-'], ['Última edición', j.actualizado ? new Date(j.actualizado).toLocaleString('es-DO') : '-'],
    ], { columnStyles: { 0: { cellWidth: 38, fontStyle: 'bold' } } })
    parrafo(`Justificación: ${j.justificacion || '(sin justificación registrada)'}`)
  }

  /* ── Comparación de modelos ── */
  titulo(`${j.activo ? 4 : 3}. Pronósticos y desempeño de todos los modelos`)
  tabla(['Modelo', 'Familia', 't+1', `IC ${cfg.nivel}%`, 'RMSE', 'RMSE/AR', 'DM p AR', 'RMSE/PA', 'DM p PA', 'Dirección', 'Cobert. 95%'],
    res.modelos.filter(m => !m.error).map(m => {
      const t = m.trayectoria?.[0]
      const zz = zN
      const mt = m.metricas
      return [m.nombre + (m.id === cfg.base.id ? ' *' : ''), m.familia, n3(t?.media),
        t?.media != null && t?.sd != null ? `${n3(t.media - zz * t.sd, 2)} a ${n3(t.media + zz * t.sd, 2)}` : '-',
        n3(mt?.rmse), n3(mt?.rrmse_ar, 2), n3(mt?.p_dm_ar, 2), n3(mt?.rrmse_rw, 2), n3(mt?.p_dm_rw, 2), pct(mt?.acierto_dir), pct(mt?.cobertura95)]
    }), { columnStyles: { 0: { cellWidth: 52 } } })
  parrafo('* Modelo base del pronóstico final. RMSE/AR y RMSE/PA < 1 = mejor que esa referencia; DM p = prueba de Diebold-Mariano ' +
    '(corrección HLN), hipótesis alternativa: el modelo tiene menor error. PA = paseo aleatorio.', 7.5, GRIS)
  {
    const bb = cfg.base.backtest
    const ar = res.modelos.find(x => x.id === 'ar')?.backtest, rw = res.modelos.find(x => x.id === 'rw')?.backtest
    if (bb && bb.fechas.length > 2) {
      const alinear = (b?: { fechas: string[]; pred: (number | null)[] }) => {
        const mp = new Map((b?.fechas ?? []).map((f, i) => [f, b!.pred[i]]))
        return bb.fechas.map(f => mp.get(f) ?? null)
      }
      figura((x, yy, w, h) => grafico(doc, x, yy, w, h, bb.fechas.map(cfg.fmtFecha), [
        { nombre: 'Observado', vals: bb.real, color: [26, 32, 44], puntos: true },
        { nombre: cfg.base.nombre, vals: bb.pred, color: [45, 106, 159], ancho: 0.7 },
        { nombre: 'AR', vals: alinear(ar), color: [113, 128, 150], guiones: true, ancho: 0.35 },
        { nombre: 'Paseo aleatorio', vals: alinear(rw), color: [183, 121, 31], guiones: true, ancho: 0.35 },
      ]),
      'Gráfico 2. Evaluación fuera de muestra: cada punto se pronosticó solo con información disponible hasta el período anterior.')
    }
  }

  /* ── Ficha del modelo base ── */
  titulo(`${j.activo ? 5 : 4}. Ficha del modelo base`)
  parrafo(`Especificación: ${cfg.base.ecuacion ?? '-'}`, 8.5)
  const props = Object.entries(cfg.base.propiedades ?? {}).filter(([k, v]) => !['importancias', 'hiperparametros', 'nota'].includes(k) && v != null)
  if (props.length) tabla(['Propiedad', 'Valor'], props.map(([k, v]) => [k.replace(/_/g, ' '), Array.isArray(v) ? v.slice(0, 12).join(', ') : typeof v === 'number' ? n3(v, 4) : String(v)]),
    { columnStyles: { 0: { cellWidth: 55 } } })
  if (cfg.base.coef?.length) tabla([cfg.base.familia === 'combinacion' ? 'Modelo combinado' : 'Parámetro', cfg.base.familia === 'combinacion' ? 'Peso' : 'Valor', 'E.E.', 'p'],
    cfg.base.coef.map(c => [c.nombre, n3(c.valor, 4), n3(c.ee, 4), n3(c.p, 3)]))
  const dg = cfg.base.diagnostico
  if (dg) parrafo(`Residuos: Ljung-Box p=${n3(dg.ljung_box_p)}, Jarque-Bera p=${n3(dg.jarque_bera_p)}, ARCH p=${n3(dg.arch_p)}.`, 8.5)

  /* ── Especificación ── */
  titulo(`${j.activo ? 6 : 5}. Especificación del ejercicio`)
  tabla(['Elemento', 'Detalle'], [
    ['Variable objetivo', `${cfg.variable} · ${cfg.transformacion} · frecuencia ${cfg.frecuencia}`],
    ['Muestra', `${cfg.fmtFecha(res.muestra.desde)} a ${cfg.fmtFecha(res.muestra.hasta)} (${res.muestra.n} períodos; desde ${cfg.muestraDesde})`],
    ['Exógenas', cfg.exogenas.length ? cfg.exogenas.map(e => `${e.nombre} [${e.detalle}]`).join(' · ') : 'ninguna'],
    ['Dummies', cfg.dummies.length ? cfg.dummies.join(', ') : 'ninguna'],
    ['Evaluación', cfg.backtest],
    ['Referencias', 'Paseo aleatorio y AR(p) automático (siempre incluidos)'],
  ], { columnStyles: { 0: { cellWidth: 38, fontStyle: 'bold' } } })
  if (res.avisos.length) parrafo('Avisos del cálculo: ' + res.avisos.join(' | '), 8, [146, 64, 14])

  /* ── Notas ── */
  titulo('Notas metodológicas')
  parrafo('Las exógenas de sentimiento provienen del scraper diario de prensa dominicana (Google News) y del modelo de ' +
    'sentimiento registrado en el dashboard. ISEC = índice compuesto de pesos editables; ISEP = sentimiento latente ' +
    'filtrado por Kalman (en tiempo real); SPS = sentimiento observado con ruido. Los intervalos más allá de t+1 ' +
    'suponen que las exógenas siguen el escenario indicado y no incorporan la incertidumbre de ese escenario. ' +
    'La investigación de referencia encontró que el ISEC general no mejora de forma significativa al AR para inflación e ' +
    'IMAE agregados: las conclusiones deben apoyarse en las pruebas fuera de muestra de este reporte.', 8, GRIS)

  const paginas = doc.getNumberOfPages()
  for (let i = 1; i <= paginas; i++) {
    doc.setPage(i); doc.setFontSize(7.5); doc.setTextColor(...GRIS)
    doc.text(txt(`Dashboard Macro · Reporte de pronóstico · ${cfg.variable}`), M, 291)
    doc.text(`${i} / ${paginas}`, W - M, 291, { align: 'right' })
  }
  const nombre = `pronostico_${cfg.variable.replace(/[^\w]+/g, '_').toLowerCase()}_${hoy.toISOString().slice(0, 10)}.pdf`
  doc.save(nombre)
}
