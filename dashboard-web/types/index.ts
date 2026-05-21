export type DataPoint = {
  fecha: string
  valor: number
}

export type SeriesMap = Record<string, DataPoint[]>

export type MergedPoint = {
  fecha: string
  [key: string]: number | string
}

export type TabId =
  | 'externo'
  | 'depositos-remunerados'
  | 'depositos-prestamos'
  | 'tasas'
  | 'tipo-cambio'
  | 'sector-electrico'

export type TabConfig = {
  id: TabId
  label: string
}
