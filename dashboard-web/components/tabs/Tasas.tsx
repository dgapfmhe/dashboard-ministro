'use client'
import { useEffect, useState, useMemo } from 'react'
import { fetchSeries } from '@/lib/queries'
import { merge, yoyGrowth, filterMergedByRange, monthsAgo, xFmtMonth, ultimaObs } from '@/lib/utils'
import ChartWrapper from '@/components/charts/ChartWrapper'
import LineChartSimple from '@/components/charts/LineChartSimple'
import type { SeriesMap } from '@/types'
import { C } from '@/lib/colors'

const ALL_IDS = ['tpm', 'tib_rd', 'ti_fond_fed', 'tia_prom_pond', 'tip_prom_pond', 'ipc_yoy', 'ipc_sub', 'ipc_rd', 'imae']

function useRange(def: [string, string]) {
  const [r, setR] = useState<[string, string]>(def)
  return [r, (f: string, t: string) => setR([f, t])] as const
}

/* Taylor Rule calculation */
function calcTaylor(params: { rNeutral: number; piMeta: number; pibPot: number; alpha: number; beta: number },
  ipcYoY: { fecha: string; valor: number }[], imaeYoY: { fecha: string; valor: number }[]) {
  const imaeMap: Record<string, number> = {}
  for (const d of imaeYoY) imaeMap[d.fecha] = d.valor
  return ipcYoY.map(d => {
    const gap = (imaeMap[d.fecha] ?? params.pibPot) - params.pibPot
    const val = params.rNeutral + params.piMeta
      + params.alpha * (d.valor - params.piMeta)
      + params.beta * gap
    return { fecha: d.fecha, valor: Math.round(val * 100) / 100 }
  })
}

export default function Tasas() {
  const [series, setSeries] = useState<SeriesMap>({})
  const [loading, setLoading] = useState(true)
  const today = new Date().toISOString().slice(0, 7)

  /* Taylor Rule - Escenario 1 (Base) */
  const [s1, setS1] = useState({ rNeutral: 2.25, piMeta: 4.0, pibPot: 5.0, alpha: 0.5, beta: 0.5 })
  /* Taylor Rule - Escenario 2 (Alternativo) */
  const [s2, setS2] = useState({ rNeutral: 2.75, piMeta: 3.5, pibPot: 5.0, alpha: 0.6, beta: 0.5 })

  useEffect(() => {
    fetchSeries(ALL_IDS, '2005-01-01').then(setSeries).finally(() => setLoading(false))
  }, [])

  const def: [string, string] = [monthsAgo(24), today]
  const [r1, onR1] = useRange(def)
  const [r2, onR2] = useRange(def)
  const [r3, onR3] = useRange(def)
  const [r4, onR4] = useRange(def)
  const [r5, onR5] = useRange(def)

  const ipcYoY = series.ipc_yoy ?? []
  const ipcSubYoY = useMemo(() => yoyGrowth(series.ipc_sub ?? []), [series.ipc_sub])

  /* TPM real = tpm - ipc_yoy. Si falta TPM o IPC para ese mes, omitir
   * la observación (evita caídas a 0 en el gráfico cuando los datos
   * tienen distinta cobertura temporal). */
  const tpmRealGen = useMemo(() => {
    const ipcMap: Record<string, number> = {}
    for (const d of ipcYoY) if (isFinite(d.valor)) ipcMap[d.fecha.slice(0, 7)] = d.valor
    const out: { fecha: string; valor: number }[] = []
    for (const d of series.tpm ?? []) {
      if (!isFinite(d.valor)) continue
      const ipc = ipcMap[d.fecha.slice(0, 7)]
      if (ipc == null || !isFinite(ipc)) continue   // falta IPC → skip
      out.push({ fecha: d.fecha.slice(0, 7), valor: Math.round((d.valor - ipc) * 100) / 100 })
    }
    return out
  }, [series.tpm, ipcYoY])

  const tpmRealSub = useMemo(() => {
    const subMap: Record<string, number> = {}
    for (const d of ipcSubYoY) if (isFinite(d.valor)) subMap[d.fecha.slice(0, 7)] = d.valor
    const out: { fecha: string; valor: number }[] = []
    for (const d of series.tpm ?? []) {
      if (!isFinite(d.valor)) continue
      const sub = subMap[d.fecha.slice(0, 7)]
      if (sub == null || !isFinite(sub)) continue
      out.push({ fecha: d.fecha.slice(0, 7), valor: Math.round((d.valor - sub) * 100) / 100 })
    }
    return out
  }, [series.tpm, ipcSubYoY])

  /* Corridor merged */
  const corredor = useMemo(() => merge({
    tpm: series.tpm ?? [], tia: series.tia_prom_pond ?? [], tip: series.tip_prom_pond ?? [],
  }, ['tpm', 'tia', 'tip']), [series.tpm, series.tia_prom_pond, series.tip_prom_pond])

  /* Tres tasas */
  const tresTasas = useMemo(() => merge({
    tpm: series.tpm ?? [], tib: series.tib_rd ?? [], ffr: series.ti_fond_fed ?? [],
  }, ['tpm', 'tib', 'ffr']), [series.tpm, series.tib_rd, series.ti_fond_fed])

  /* Brecha interbancaria - TPM */
  const brecha = useMemo(() => {
    const tpmMap: Record<string, number> = {}
    for (const d of series.tpm ?? []) tpmMap[d.fecha.slice(0, 7)] = d.valor
    return (series.tib_rd ?? []).map(d => ({
      fecha: d.fecha.slice(0, 7),
      valor: Math.round((d.valor - (tpmMap[d.fecha.slice(0, 7)] ?? 0)) * 100) / 100,
    }))
  }, [series.tib_rd, series.tpm])

  /* TPM real general vs subyacente merged */
  const tpmRealMerged = useMemo(() => {
    const gen: Record<string, number> = {}
    const sub: Record<string, number> = {}
    for (const d of tpmRealGen) gen[d.fecha] = d.valor
    for (const d of tpmRealSub) sub[d.fecha] = d.valor
    const keys = [...new Set([...Object.keys(gen), ...Object.keys(sub)])].sort()
    return keys.map(k => ({ fecha: k, gen: gen[k] ?? null, sub: sub[k] ?? null }))
  }, [tpmRealGen, tpmRealSub])

  /* Taylor rule: dos escenarios independientes */
  const imaeYoY = useMemo(() => yoyGrowth(series.imae ?? []), [series.imae])
  const ipcM = useMemo(() => ipcYoY.map(d => ({ ...d, fecha: d.fecha.slice(0,7) })), [ipcYoY])
  const imaeM = useMemo(() => imaeYoY.map(d => ({ ...d, fecha: d.fecha.slice(0,7) })), [imaeYoY])
  const taylorLine1 = useMemo(() => calcTaylor(s1, ipcM, imaeM), [ipcM, imaeM, s1])
  const taylorLine2 = useMemo(() => calcTaylor(s2, ipcM, imaeM), [ipcM, imaeM, s2])

  const taylorMerged = useMemo(() => {
    const tpmMap: Record<string, number> = {}
    for (const d of series.tpm ?? []) tpmMap[d.fecha.slice(0, 7)] = d.valor
    const t1Map: Record<string, number> = {}
    for (const d of taylorLine1) t1Map[d.fecha] = d.valor
    const t2Map: Record<string, number> = {}
    for (const d of taylorLine2) t2Map[d.fecha] = d.valor
    const keys = [...new Set([...Object.keys(tpmMap), ...Object.keys(t1Map)])].sort()
    return keys.map(k => ({ fecha: k, tpm: tpmMap[k] ?? null, taylor1: t1Map[k] ?? null, taylor2: t2Map[k] ?? null }))
  }, [series.tpm, taylorLine1, taylorLine2])

  const xFmt = xFmtMonth
  const pctFmt = (v: number) => `${v?.toFixed(2)}%`

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">

      {/* G1 Corredor de tasas */}
      <ChartWrapper title="Corredor de Tasas de Interés"
        subtitle="TPM, Tasa Activa y Tasa Pasiva — Promedio ponderado"
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="corredor-tasas"
        lastValue={(() => { const l = ultimaObs(series.tpm); return l ? { label: 'TPM', value: l.valor, fecha: xFmt(l.fecha.slice(0,7)), unit: '%' } : undefined })()}>
        <LineChartSimple
          data={filterMergedByRange(corredor, r1[0], r1[1])}
          series={[
            { key: 'tpm',  label: 'TPM',         color: C.blue, strokeWidth: 2.5 },
            { key: 'tia',  label: 'Tasa Activa',  color: C.red },
            { key: 'tip',  label: 'Tasa Pasiva',  color: C.green },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt}
        />
      </ChartWrapper>

      {/* G2 TPM real vs inflación subyacente */}
      <ChartWrapper title="TPM Real vs Inflación Subyacente"
        subtitle="TPM real (subyacente) e inflación subyacente interanual"
        from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
        downloadName="tpm-real-subyacente">
        <LineChartSimple
          data={(() => {
            const subMap: Record<string, number> = {}
            for (const d of ipcSubYoY) subMap[d.fecha.slice(0, 7)] = d.valor
            return tpmRealSub.filter(d => d.fecha >= r2[0] && d.fecha <= r2[1]).map(d => ({
              fecha: d.fecha, tpmRealSub: d.valor, ipcSub: subMap[d.fecha] ?? null,
            }))
          })()}
          series={[
            { key: 'tpmRealSub', label: 'TPM Real (Subyacente)', color: C.blue, strokeWidth: 2.5 },
            { key: 'ipcSub',     label: 'Inflación Subyacente', color: C.red, dashed: true },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt} refLine={0}
        />
      </ChartWrapper>

      {/* G3b TPM vs interbancaria vs FFR */}
      <ChartWrapper title="TPM, Tasa Interbancaria y Fed Funds Rate"
        subtitle="Tres tasas de referencia"
        from={r4[0]} to={r4[1]} isLoading={loading} onRangeChange={onR4}
        downloadName="tpm-interbancaria-ffr">
        <LineChartSimple
          data={filterMergedByRange(tresTasas, r4[0], r4[1])}
          series={[
            { key: 'tpm', label: 'TPM BCRD',        color: C.blue, strokeWidth: 2.5 },
            { key: 'tib', label: 'Interbancaria',    color: C.red },
            { key: 'ffr', label: 'Fed Funds Rate',   color: C.gray, dashed: true },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt}
        />
      </ChartWrapper>

      {/* G4 TPM vs interbancaria vs activa PP */}
      <ChartWrapper title="TPM, Interbancaria y Tasa Activa PP"
        subtitle="Tasas del sistema financiero dominicano"
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="tpm-interbancaria-activa">
        <LineChartSimple
          data={filterMergedByRange(
            merge({ tpm: series.tpm ?? [], tib: series.tib_rd ?? [], tia: series.tia_prom_pond ?? [] }, ['tpm','tib','tia']),
            r1[0], r1[1])}
          series={[
            { key: 'tpm', label: 'TPM',              color: C.blue, strokeWidth: 2.5 },
            { key: 'tib', label: 'Interbancaria',    color: C.red },
            { key: 'tia', label: 'Activa PP',        color: C.amber },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt}
        />
      </ChartWrapper>

      {/* G5 Brecha interbancaria - TPM */}
      <ChartWrapper title="Brecha: Interbancaria − TPM"
        subtitle="Diferencia en puntos porcentuales"
        from={r2[0]} to={r2[1]} isLoading={loading} onRangeChange={onR2}
        downloadName="brecha-interbancaria-tpm">
        <LineChartSimple
          data={brecha.filter(d => d.fecha >= r2[0] && d.fecha <= r2[1])}
          series={[{ key: 'valor', label: 'Brecha Interbancaria − TPM', color: C.blue }]}
          unit="pp" yFormatter={pctFmt} xFormatter={xFmt} refLine={0}
        />
      </ChartWrapper>

      {/* G7a TPM vs inflación interanual */}
      <ChartWrapper title="TPM vs Inflación Interanual"
        subtitle="Tasa de política y variación de precios"
        from={r1[0]} to={r1[1]} isLoading={loading} onRangeChange={onR1}
        downloadName="tpm-inflacion">
        <LineChartSimple
          data={filterMergedByRange(
            merge({ tpm: series.tpm ?? [], ipc: (series.ipc_yoy ?? []) }, ['tpm','ipc']),
            r1[0], r1[1])}
          series={[
            { key: 'tpm', label: 'TPM',            color: C.blue, strokeWidth: 2.5 },
            { key: 'ipc', label: 'Inflación IPC',  color: C.red, dashed: true },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt}
        />
      </ChartWrapper>

      {/* G7b TPM real general vs subyacente */}
      <ChartWrapper title="TPM Real: General vs Subyacente"
        subtitle="TPM deflactada por IPC general e IPC subyacente"
        from={r5[0]} to={r5[1]} isLoading={loading} onRangeChange={onR5}
        downloadName="tpm-real-gen-sub">
        <LineChartSimple
          data={tpmRealMerged.filter(d => d.fecha >= r5[0] && d.fecha <= r5[1])}
          series={[
            { key: 'gen', label: 'TPM Real (General)',     color: C.blue, strokeWidth: 2 },
            { key: 'sub', label: 'TPM Real (Subyacente)',  color: C.red, dashed: true },
          ]}
          unit="%" yFormatter={pctFmt} xFormatter={xFmt} refLine={0}
        />
      </ChartWrapper>

      {/* Taylor Rule: dos escenarios editables independientes */}
      <div className="col-span-full bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-5">
        <h3 className="text-[13px] font-semibold text-[#1A202C] mb-1">
          Regla de Taylor — Comparación de Escenarios
        </h3>
        <p className="text-[11px] text-[#6B7280] mb-4">
          i = r* + π* + α·(π − π*) + β·(y − ȳ)
        </p>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-5">
          {([
            { key: '1', label: 'Escenario 1 — Base',         state: s1, setState: setS1, color: C.red,   bg: 'bg-[#FFF5F5]' },
            { key: '2', label: 'Escenario 2 — Alternativo',  state: s2, setState: setS2, color: C.amber, bg: 'bg-[#FFFBEB]' },
          ] as const).map(({ key, label, state, setState, color, bg }) => (
            <div key={key} className={`${bg} border border-[#E5E7EB] rounded-lg p-3`}>
              <div className="flex items-center gap-2 mb-3">
                <span className="inline-block w-3 h-3 rounded-sm" style={{ background: color }} />
                <h4 className="text-[12px] font-semibold text-[#1A202C]">{label}</h4>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-5 gap-2">
                {([
                  { label: 'r* (real neutral)', field: 'rNeutral', step: 0.25 },
                  { label: 'π* (meta infl.)',    field: 'piMeta',   step: 0.25 },
                  { label: 'ȳ (PIB potencial)',  field: 'pibPot',   step: 0.5 },
                  { label: 'α (peso π)',         field: 'alpha',    step: 0.05 },
                  { label: 'β (peso brecha)',    field: 'beta',     step: 0.05 },
                ] as const).map(({ label: lab, field, step }) => (
                  <div key={field} className="flex flex-col gap-1">
                    <label className="text-[9px] text-[#6B7280] font-medium leading-tight">{lab}</label>
                    <div className="flex items-center gap-1">
                      <input
                        type="number" step={step} min={0}
                        value={state[field]}
                        onChange={e => setState({ ...state, [field]: parseFloat(e.target.value) || 0 })}
                        className="w-full text-[11px] font-semibold text-[#1A202C] border border-[#D1D9E0] rounded px-1.5 py-1 text-right bg-white"
                      />
                      <span className="text-[10px] text-[#9CA3AF]">%</span>
                    </div>
                  </div>
                ))}
              </div>
              <div className="mt-2 text-[10px] text-[#6B7280] font-mono">
                i = {state.rNeutral}% + {state.piMeta}% + {state.alpha}·(π − {state.piMeta}%) + {state.beta}·(y − {state.pibPot}%)
              </div>
            </div>
          ))}
        </div>

        <div style={{ height: 320 }}>
          <LineChartSimple
            data={taylorMerged.filter(d => d.fecha >= r4[0] && d.fecha <= r4[1])}
            series={[
              { key: 'tpm',     label: 'TPM BCRD (observada)',  color: C.blue, strokeWidth: 2.5 },
              { key: 'taylor1', label: 'Taylor — Escenario 1',   color: C.red, dashed: true, strokeWidth: 2 },
              { key: 'taylor2', label: 'Taylor — Escenario 2',   color: C.amber, dashed: true, strokeWidth: 2 },
            ]}
            unit="%" yFormatter={pctFmt} xFormatter={xFmt}
          />
        </div>
      </div>

      {/* Tabla 1 — Estructura de tasas */}
      <div className="col-span-full bg-white rounded-xl border border-[#D1D9E0] shadow-sm p-4">
        <h3 className="text-[13px] font-semibold text-[#1A202C] mb-3">
          Tabla 1 — Estructura de Tasas por Plazo
        </h3>
        <p className="text-[10px] text-[#9CA3AF] italic mb-3">
          ⚠ Pendiente: tasas a 3m, 6m, 1yr, 2yr+, 5yr de Hacienda/BCRD y notas BC (3yr, 5yr). Variables por agregar al pipeline.
        </p>
        <div className="overflow-x-auto">
          <table className="w-full text-[11px]">
            <thead>
              <tr className="bg-[#F0F2F5]">
                {['Instrumento','3 meses','6 meses','1 año','2 años+','5 años'].map(h => (
                  <th key={h} className="px-3 py-2 text-left text-[#1A202C] font-semibold">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {['TPM BCRD','Letras BCRD','Notas BCRD','Tesoros EE.UU.'].map(row => (
                <tr key={row} className="border-t border-[#F0F2F5]">
                  <td className="px-3 py-2 font-medium text-[#1A202C]">{row}</td>
                  {[0,1,2,3,4].map(i => (
                    <td key={i} className="px-3 py-2 text-[#9CA3AF]">—</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
