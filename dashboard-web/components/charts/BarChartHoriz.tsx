'use client'
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer, Cell, LabelList,
} from 'recharts'
import { C, PALETTE } from '@/lib/colors'

export interface HBarSeries {
  key: string
  label: string
  color?: string
}

interface Props {
  data: Record<string, number | string>[]
  series: HBarSeries[]
  yKey?: string
  unit?: string
  formatter?: (v: number) => string
}

const defaultFmt = (v: number) => {
  if (Math.abs(v) >= 1000) return `${(v / 1000).toFixed(1)}B`
  return `${v.toFixed(0)}`
}

const CustomTooltip = ({ active, payload, label, unit, fmt }: {
  active?: boolean
  payload?: { name: string; value: number; color: string }[]
  label?: string
  unit?: string
  fmt: (v: number) => string
}) => {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-[#1A202C] text-white text-[11px] px-3 py-2 rounded-lg shadow-lg">
      <p className="font-medium mb-1">{label}</p>
      {payload.map((p) => (
        <p key={p.name} style={{ color: p.color }}>
          {p.name}: {fmt(p.value)} {unit ?? ''}
        </p>
      ))}
    </div>
  )
}

export default function BarChartHoriz({
  data, series, yKey = 'nombre', unit, formatter = defaultFmt,
}: Props) {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <BarChart
        data={data}
        layout="vertical"
        margin={{ top: 4, right: 64, left: 8, bottom: 4 }}
        barCategoryGap="20%"
        barGap={3}
      >
        <CartesianGrid horizontal={false} stroke={C.gridStroke} strokeDasharray="3 3" />
        <XAxis
          type="number"
          tickFormatter={formatter}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
        />
        <YAxis
          type="category"
          dataKey={yKey}
          tick={{ fontSize: 10, fill: C.axisStroke }}
          axisLine={false}
          tickLine={false}
          width={100}
        />
        <Tooltip content={<CustomTooltip unit={unit} fmt={formatter} />} />
        <Legend iconType="square" iconSize={10} wrapperStyle={{ fontSize: 11 }} />
        {series.map((s, i) => (
          <Bar
            key={s.key}
            dataKey={s.key}
            name={s.label}
            fill={s.color ?? PALETTE[i % PALETTE.length]}
            radius={[0, 3, 3, 0]}
            maxBarSize={28}
          >
            <LabelList
              dataKey={s.key}
              position="right"
              formatter={(v: unknown) => formatter(v as number)}
              style={{ fontSize: 9, fill: C.axisStroke }}
            />
          </Bar>
        ))}
      </BarChart>
    </ResponsiveContainer>
  )
}
