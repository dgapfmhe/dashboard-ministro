'use client'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, Cell, ReferenceLine,
} from 'recharts'
import { C } from '@/lib/colors'

interface Props {
  data: { fecha: string; valor: number }[]
  color?: string
  unit?: string
  xFormatter?: (v: string) => string
  yFormatter?: (v: number) => string
  label?: string
  showLegend?: boolean
  refLine?: number
}

const defaultXFmt = (v: string) => v.slice(0, 4)
const defaultYFmt = (v: number) => {
  if (Math.abs(v) >= 1000) return `${(v / 1000).toFixed(1)}B`
  return `${v.toFixed(0)}`
}

const CustomTooltip = ({ active, payload, label, unit, yFmt }: {
  active?: boolean; payload?: { value: number }[]; label?: string; unit?: string; yFmt: (v: number) => string
}) => {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-[#1A202C] text-white text-[11px] px-3 py-2 rounded-lg shadow-lg">
      <p className="font-medium mb-1">{label}</p>
      <p>{yFmt(payload[0].value)} {unit ?? ''}</p>
    </div>
  )
}

export default function BarChartVert({
  data, color = C.blue, unit, xFormatter = defaultXFmt,
  yFormatter = defaultYFmt, label = 'Valor', showLegend = false, refLine,
}: Props) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart data={data} margin={{ top: 8, right: 16, left: 8, bottom: 4 }} barCategoryGap="30%">
        <CartesianGrid vertical={false} stroke={C.gridStroke} strokeDasharray="3 3" />
        <XAxis
          dataKey="fecha"
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
        />
        <Tooltip content={<CustomTooltip unit={unit} yFmt={yFormatter} />} />
        {showLegend && <Legend iconType="square" iconSize={10} wrapperStyle={{ fontSize: 11 }} />}
        {refLine !== undefined && (
          <ReferenceLine y={refLine} stroke={C.red} strokeDasharray="4 2" strokeWidth={1.5} />
        )}
        <Bar dataKey="valor" name={label} fill={color} radius={[3, 3, 0, 0]} maxBarSize={48}>
          {data.map((entry) => (
            <Cell key={entry.fecha} fill={entry.valor < 0 ? C.red : color} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}
