'use client'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, ReferenceLine,
} from 'recharts'
import { C, PALETTE } from '@/lib/colors'

export interface LineSeries {
  key: string
  label: string
  color?: string
  dashed?: boolean
  strokeWidth?: number
}

interface Props {
  data: Record<string, number | string>[]
  series: LineSeries[]
  xKey?: string
  unit?: string
  yFormatter?: (v: number) => string
  xFormatter?: (v: string) => string
  refLine?: number
  showLegend?: boolean
  dot?: boolean
  /** Dominio del eje Y. ['auto', 'auto'] usa el rango de los datos.
   * ['dataMin - X', 'dataMax + Y'] ajusta con padding. Útil para
   * ampliar visualmente diferencias pequeñas entre series. */
  yDomain?: [number | string, number | string]
}

const defaultYFmt = (v: number) => `${v.toFixed(1)}`
const defaultXFmt = (v: string) => {
  if (v.length >= 7) {
    const [y, m] = v.split('-')
    const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic']
    return `${months[parseInt(m) - 1]} ${y.slice(2)}`
  }
  return v.slice(0, 4)
}

const CustomTooltip = ({ active, payload, label, unit, yFmt }: {
  active?: boolean; payload?: { name: string; value: number; color: string }[]
  label?: string; unit?: string; yFmt: (v: number) => string
}) => {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-[#1A202C] text-white text-[11px] px-3 py-2 rounded-lg shadow-lg">
      <p className="font-medium mb-1">{label}</p>
      {payload.map((p) => (
        <p key={p.name} style={{ color: p.color }}>
          {p.name}: {yFmt(p.value)} {unit ?? ''}
        </p>
      ))}
    </div>
  )
}

export default function LineChartSimple({
  data, series, xKey = 'fecha', unit, yFormatter = defaultYFmt,
  xFormatter = defaultXFmt, refLine, showLegend = true, dot = false,
  yDomain,
}: Props) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <LineChart data={data} margin={{ top: 8, right: 20, left: 8, bottom: 4 }}>
        <CartesianGrid vertical={false} stroke={C.gridStroke} strokeDasharray="3 3" />
        <XAxis
          dataKey={xKey}
          tickFormatter={xFormatter}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
          interval="preserveStartEnd"
        />
        <YAxis
          tickFormatter={yFormatter}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
          width={52}
          domain={yDomain ?? ['auto', 'auto']}
        />
        <Tooltip content={<CustomTooltip unit={unit} yFmt={yFormatter} />} />
        {showLegend && (
          <Legend iconType="plainline" iconSize={16} wrapperStyle={{ fontSize: 11 }} />
        )}
        {refLine !== undefined && (
          <ReferenceLine y={refLine} stroke={C.gridStroke} strokeDasharray="4 2" strokeWidth={1.5} />
        )}
        {series.map((s, i) => (
          <Line
            key={s.key}
            type="monotone"
            dataKey={s.key}
            name={s.label}
            stroke={s.color ?? PALETTE[i % PALETTE.length]}
            strokeWidth={s.strokeWidth ?? 2}
            strokeDasharray={s.dashed ? '5 3' : undefined}
            dot={dot ? { r: 2 } : false}
            activeDot={{ r: 4 }}
            connectNulls
          />
        ))}
      </LineChart>
    </ResponsiveContainer>
  )
}
