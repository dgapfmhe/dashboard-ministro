'use client'
import {
  ComposedChart, Bar, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer,
} from 'recharts'
import { C } from '@/lib/colors'

interface Props {
  data: Record<string, number | string>[]
  barKey: string
  barLabel: string
  barColor?: string
  lineKey: string
  lineLabel: string
  lineColor?: string
  xKey?: string
  yLeftFormatter?: (v: number) => string
  yRightFormatter?: (v: number) => string
  yLeftUnit?: string
  yRightUnit?: string
  xFormatter?: (v: string) => string
  /** Dominio del eje derecho (línea). Útil para "ajustar el TCN" y que la
   * relación visual con las barras sea clara. Default: ['auto', 'auto']. */
  yRightDomain?: [number | 'auto', number | 'auto']
}

const shortNum = (v: number) => {
  if (Math.abs(v) >= 1000) return `${(v / 1000).toFixed(1)}B`
  return `${v.toFixed(0)}`
}

const CustomTooltip = ({ active, payload, label }: {
  active?: boolean
  payload?: { name: string; value: number; color: string }[]
  label?: string
}) => {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-[#1A202C] text-white text-[11px] px-3 py-2 rounded-lg shadow-lg">
      <p className="font-medium mb-1">{label}</p>
      {payload.map((p) => (
        <p key={p.name} style={{ color: p.color }}>
          {p.name}: {typeof p.value === 'number' ? p.value.toFixed(2) : p.value}
        </p>
      ))}
    </div>
  )
}

export default function ComboChartDual({
  data,
  barKey,
  barLabel,
  barColor = C.blue,
  lineKey,
  lineLabel,
  lineColor = C.red,
  xKey = 'fecha',
  yLeftFormatter = shortNum,
  yRightFormatter = (v) => `${v.toFixed(1)}%`,
  xFormatter = (v) => v.slice(0, 7),
  yRightDomain,
}: Props) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <ComposedChart data={data} margin={{ top: 8, right: 52, left: 8, bottom: 4 }}>
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
          yAxisId="left"
          tickFormatter={yLeftFormatter}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
          width={52}
        />
        <YAxis
          yAxisId="right"
          orientation="right"
          tickFormatter={yRightFormatter}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
          width={48}
          domain={yRightDomain ?? ['auto', 'auto']}
        />
        <Tooltip content={<CustomTooltip />} />
        <Legend iconSize={10} wrapperStyle={{ fontSize: 11 }} />
        <Bar
          yAxisId="left"
          dataKey={barKey}
          name={barLabel}
          fill={barColor}
          radius={[3, 3, 0, 0]}
          maxBarSize={48}
          opacity={0.85}
        />
        <Line
          yAxisId="right"
          type="monotone"
          dataKey={lineKey}
          name={lineLabel}
          stroke={lineColor}
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 4 }}
          connectNulls
        />
      </ComposedChart>
    </ResponsiveContainer>
  )
}
