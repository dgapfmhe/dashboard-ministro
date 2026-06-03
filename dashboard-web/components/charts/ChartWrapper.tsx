'use client'
import { useRef, useState, useCallback } from 'react'
import { toPng } from 'html-to-image'

const PRESETS = [
  { label: '1A',  months: 12 },
  { label: '3A',  months: 36 },
  { label: '5A',  months: 60 },
  { label: '10A', months: 120 },
  { label: 'MAX', months: null },
] as const

interface ChartWrapperProps {
  title: string
  subtitle?: string
  note?: string
  /** Controlled range — when provided, the wrapper renders these and emits changes via onRangeChange. */
  from?: string
  to?: string
  /** Fallback if `from`/`to` are not provided. */
  defaultFrom?: string
  defaultTo?: string
  dataMin?: string
  onRangeChange?: (from: string, to: string) => void
  downloadName?: string
  isLoading?: boolean
  fullWidth?: boolean
  height?: number
  hideRange?: boolean
  /** Última observación a mostrar como badge dentro del gráfico (esquina sup. der.).
   * Si se da, aparece un card pequeño con label, valor y fecha. */
  lastValue?: {
    label?: string
    value: number | null | undefined
    fecha?: string
    unit?: string
    valueFormatter?: (v: number) => string
  }
  children: React.ReactNode
}

const todayMonth = () => new Date().toISOString().slice(0, 7)
const monthsAgo = (n: number) => {
  const d = new Date()
  d.setMonth(d.getMonth() - n)
  return d.toISOString().slice(0, 7)
}
const MESES_CORTO = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']
const fmtPeriod = (m: string) => {
  if (!m || m.length < 7) return m ?? ''
  const [y, mm] = m.split('-')
  return `${MESES_CORTO[parseInt(mm, 10) - 1]} ${y}`
}

export default function ChartWrapper(props: ChartWrapperProps) {
  const {
    title, subtitle, note,
    from: fromProp, to: toProp,
    defaultFrom, defaultTo,
    dataMin = '1990-01',
    onRangeChange, downloadName,
    isLoading = false, fullWidth = false, height = 320,
    hideRange = false, lastValue, children,
  } = props
  const cardRef = useRef<HTMLDivElement>(null)
  const [expanded, setExpanded] = useState(false)

  // Uncontrolled fallback state (used only when from/to are not supplied).
  const [uncFrom, setUncFrom] = useState(defaultFrom ?? '2020-01')
  const [uncTo, setUncTo] = useState(defaultTo ?? todayMonth())

  const isControlled = fromProp !== undefined && toProp !== undefined
  const from = isControlled ? (fromProp as string) : uncFrom
  const to = isControlled ? (toProp as string) : uncTo

  const apply = (f: string, t: string) => {
    if (!isControlled) {
      setUncFrom(f)
      setUncTo(t)
    }
    onRangeChange?.(f, t)
  }
  const handleFrom = (v: string) => apply(v, to)
  const handleTo   = (v: string) => apply(from, v)
  const handlePreset = (months: number | null) => {
    const t = todayMonth()
    const f = months === null ? dataMin : monthsAgo(months)
    apply(f, t)
  }

  const handleDownload = useCallback(async () => {
    if (!cardRef.current) return
    try {
      const png = await toPng(cardRef.current, {
        quality: 1, pixelRatio: 3, backgroundColor: '#ffffff',
      })
      const a = document.createElement('a')
      a.download = `${downloadName ?? title}.png`
      a.href = png; a.click()
    } catch { /* ignore */ }
  }, [downloadName, title])

  const colSpan = fullWidth ? 'col-span-full' : ''
  const isPresetActive = (months: number | null) => {
    const expectedFrom = months === null ? dataMin : monthsAgo(months)
    const expectedTo = todayMonth()
    return from === expectedFrom && to === expectedTo
  }

  return (
    <>
      <div className={`bg-white rounded-xl border border-[#D1D9E0] shadow-sm flex flex-col min-w-0 ${colSpan}`}>
        <div className="flex items-start justify-between gap-3 px-4 pt-4 pb-2">
          <div className="min-w-0">
            <h3 className="text-[13px] font-semibold text-[#1A202C] leading-tight truncate">{title}</h3>
            {subtitle && <p className="text-[11px] text-[#6B7280] mt-0.5">{subtitle}</p>}
            {!hideRange && (
              <p className="text-[10px] text-[#1B3A5C] mt-1 font-medium">
                Período: <span className="font-semibold">{fmtPeriod(from)}</span> – <span className="font-semibold">{fmtPeriod(to)}</span>
              </p>
            )}
          </div>
          <div className="flex flex-col items-end gap-1.5 shrink-0">
            {!hideRange && (
              <div className="flex gap-0.5">
                {PRESETS.map((p) => {
                  const active = isPresetActive(p.months)
                  return (
                    <button
                      key={p.label}
                      type="button"
                      onClick={() => handlePreset(p.months)}
                      className={[
                        'text-[9px] px-1.5 py-0.5 rounded border transition-colors',
                        active
                          ? 'bg-[#1B3A5C] text-white border-[#1B3A5C]'
                          : 'border-[#D1D9E0] text-[#6B7280] hover:bg-[#EEF0F4]',
                      ].join(' ')}
                    >{p.label}</button>
                  )
                })}
              </div>
            )}
            <div className="flex items-center gap-1.5">
              {!hideRange && (
                <>
                  <input
                    type="month"
                    value={from}
                    min={dataMin}
                    onChange={(e) => handleFrom(e.target.value)}
                    className="text-[10px] border border-[#D1D9E0] rounded px-1.5 py-0.5 text-[#1A202C]"
                  />
                  <span className="text-[10px] text-[#9CA3AF]">–</span>
                  <input
                    type="month"
                    value={to}
                    min={dataMin}
                    onChange={(e) => handleTo(e.target.value)}
                    className="text-[10px] border border-[#D1D9E0] rounded px-1.5 py-0.5 text-[#1A202C]"
                  />
                </>
              )}
              <button
                type="button"
                onClick={handleDownload}
                title="Descargar PNG"
                className="p-1 rounded hover:bg-[#EEF0F4] text-[#6B7280] hover:text-[#1B3A5C] transition-colors"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
                </svg>
              </button>
              <button
                type="button"
                onClick={() => setExpanded(true)}
                title="Expandir"
                className="p-1 rounded hover:bg-[#EEF0F4] text-[#6B7280] hover:text-[#1B3A5C] transition-colors"
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/>
                </svg>
              </button>
            </div>
          </div>
        </div>

        <div ref={cardRef} className="bg-white px-2 pb-2 flex-1">
          <div className="px-2">
            <h3 className="hidden print:block text-[13px] font-semibold text-[#1A202C]">{title}</h3>
          </div>
          {isLoading ? (
            <div className="w-full flex items-center justify-center" style={{ height }}>
              <div className="w-8 h-8 border-2 border-[#1B3A5C] border-t-transparent rounded-full animate-spin" />
            </div>
          ) : (
            <div className="relative w-full" style={{ height, minWidth: 0 }}>
              {children}
              {lastValue && lastValue.value != null && isFinite(lastValue.value) && (
                <div className="absolute top-1 right-3 bg-white/95 border border-[#D1D9E0] rounded-md shadow-sm px-2 py-1 text-right pointer-events-none">
                  {lastValue.label && (
                    <div className="text-[9px] uppercase tracking-wider text-[#6B7280] font-medium">
                      {lastValue.label}
                    </div>
                  )}
                  <div className="text-[14px] font-bold text-[#1B3A5C] tabular-nums leading-tight">
                    {lastValue.valueFormatter
                      ? lastValue.valueFormatter(lastValue.value)
                      : lastValue.value.toFixed(2)}
                    {lastValue.unit && <span className="text-[10px] font-medium text-[#6B7280] ml-1">{lastValue.unit}</span>}
                  </div>
                  {lastValue.fecha && (
                    <div className="text-[9px] text-[#9CA3AF] tabular-nums">{lastValue.fecha}</div>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        {note && (
          <p className="text-[10px] text-[#9CA3AF] italic px-4 pb-3 border-t border-[#F0F2F5] pt-2 mt-1">
            ⚠ {note}
          </p>
        )}
      </div>

      {expanded && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-6"
          onClick={() => setExpanded(false)}
        >
          <div
            className="bg-white rounded-2xl shadow-2xl w-full max-w-5xl max-h-[90vh] overflow-auto p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-base font-semibold text-[#1A202C]">{title}</h2>
                {subtitle && <p className="text-xs text-[#6B7280]">{subtitle}</p>}
                {!hideRange && (
                  <p className="text-[11px] text-[#1B3A5C] mt-1 font-medium">
                    Período: <span className="font-semibold">{fmtPeriod(from)}</span> – <span className="font-semibold">{fmtPeriod(to)}</span>
                  </p>
                )}
              </div>
              <div className="flex items-center gap-2">
                <button onClick={handleDownload} title="Descargar" className="text-xs px-3 py-1.5 bg-[#1B3A5C] text-white rounded-lg hover:bg-[#14304D] transition-colors">
                  Descargar PNG
                </button>
                <button onClick={() => setExpanded(false)} className="text-[#6B7280] hover:text-[#1A202C] p-1">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
              </div>
            </div>
            <div style={{ height: 520 }}>{children}</div>
            {note && <p className="text-[10px] text-[#9CA3AF] italic mt-3">⚠ {note}</p>}
          </div>
        </div>
      )}
    </>
  )
}
