/* Juicio experto sobre los pronósticos del Laboratorio.
 * El pronóstico FINAL = pronóstico de un modelo/combinación base + juicio del analista.
 * Nunca reemplaza al del modelo: ambos se muestran y se reportan lado a lado. */

export type ModoJuicio = 'ajuste' | 'valor' | 'mezcla'
export type Riesgo = 'balanceado' | 'alcista' | 'bajista'

export type Juicio = {
  activo: boolean
  base: string                 // id del modelo o combinación base
  modo: ModoJuicio             // ajuste aditivo · valor propio · mezcla con peso λ
  valores: (number | null)[]   // por período del horizonte
  peso: number                 // λ ∈ [0,1] (solo en modo mezcla)
  riesgo: Riesgo               // balance de riesgos → banda asimétrica
  asimetria: number            // % de ensanchamiento del lado del riesgo (0–200)
  justificacion: string
  autor: string
  actualizado: string
}

export const JUICIO_VACIO: Juicio = {
  activo: false, base: '', modo: 'ajuste', valores: [], peso: 0.5, riesgo: 'balanceado',
  asimetria: 50, justificacion: '', autor: '', actualizado: '',
}

export const NOMBRE_MODO: Record<ModoJuicio, string> = {
  ajuste: 'Ajuste aditivo (± sobre el modelo)',
  valor: 'Valor propio (reemplaza el central)',
  mezcla: 'Mezcla ponderada con mi valor (λ)',
}
export const NOMBRE_RIESGO: Record<Riesgo, string> = {
  balanceado: 'Balanceado', alcista: 'Sesgo al alza', bajista: 'Sesgo a la baja',
}

export const Z: Record<number, number> = { 50: 0.674, 68: 0.994, 80: 1.2816, 90: 1.6449, 95: 1.96 }

export type PuntoTray = { fecha: string; media: number | null; sd: number | null; interanual?: number | null }
export type PuntoFinal = {
  fecha: string; modelo: number | null; final: number | null; li: number | null; ls: number | null
  li_modelo: number | null; ls_modelo: number | null; ajuste: number | null
  interanual_modelo: number | null; interanual_final: number | null
}

/** Aplica el juicio a la trayectoria base. `nivel` = nivel de confianza (50/68/80/90/95). */
export function aplicarJuicio(tray: PuntoTray[], j: Juicio | null, nivel: number, esPctMensual: boolean): PuntoFinal[] {
  const z = Z[nivel] ?? 1.96
  let factorBase = 1, factorFinal = 1        // para recomponer la tasa interanual
  return tray.map((p, k) => {
    const b = p.media
    const sd = p.sd ?? 0
    let f = b
    if (j?.activo && b != null) {
      const v = j.valores[k]
      if (j.modo === 'ajuste') f = b + (v ?? 0)
      else if (j.modo === 'valor') f = v ?? b
      else f = v == null ? b : (1 - j.peso) * b + j.peso * v
    }
    const half = z * sd
    const abajo = j?.activo && j.riesgo === 'bajista' ? 1 + j.asimetria / 100 : 1
    const arriba = j?.activo && j.riesgo === 'alcista' ? 1 + j.asimetria / 100 : 1
    let iaF: number | null = null
    if (esPctMensual && p.interanual != null && b != null && f != null) {
      factorBase *= 1 + b / 100
      factorFinal *= 1 + f / 100
      iaF = ((1 + p.interanual / 100) * factorFinal / factorBase - 1) * 100
    }
    return {
      fecha: p.fecha, modelo: b, final: f,
      li: f == null ? null : f - half * abajo, ls: f == null ? null : f + half * arriba,
      li_modelo: b == null ? null : b - half, ls_modelo: b == null ? null : b + half,
      ajuste: b != null && f != null ? f - b : null,
      interanual_modelo: p.interanual ?? null, interanual_final: iaF,
    }
  })
}

const clave = (objetivo: string, transf: string) => `lab-juicio:${objetivo}:${transf}`
export function cargarJuicio(objetivo: string, transf: string): Juicio | null {
  try {
    const s = localStorage.getItem(clave(objetivo, transf))
    return s ? { ...JUICIO_VACIO, ...JSON.parse(s) } : null
  } catch { return null }
}
export function guardarJuicio(objetivo: string, transf: string, j: Juicio) {
  try { localStorage.setItem(clave(objetivo, transf), JSON.stringify(j)) } catch { /* sin almacenamiento */ }
}
