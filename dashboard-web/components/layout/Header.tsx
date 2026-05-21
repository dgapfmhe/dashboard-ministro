'use client'
import { useState, useEffect } from 'react'
import { exportarExcelCompleto } from '@/lib/excelExport'

interface Props {
  lastUpdate?: string
}
export default function Header({ lastUpdate }: Props) {
  const [downloading, setDownloading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  // Solo renderizar el botón después del mount del cliente (evita warning
  // de hidratación cuando extensiones inyectan fdprocessedid en buttons).
  const [mounted, setMounted] = useState(false)
  useEffect(() => { setMounted(true) }, [])

  // Descarga el Excel pre-construido (con gráficos nativos manipulables).
  // El archivo se regenera vía `python scripts/build_dashboard_excel.py` y
  // queda en /public como dashboard_completo.xlsx.
  const handleExport = async () => {
    setDownloading(true); setError(null)
    try {
      const res = await fetch('/dashboard_completo.xlsx', { cache: 'no-store' })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const blob = await res.blob()
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `dashboard_ministro_${new Date().toISOString().slice(0, 10)}.xlsx`
      document.body.appendChild(a); a.click(); document.body.removeChild(a)
      URL.revokeObjectURL(url)
    } catch (e) {
      // Fallback: si el archivo pre-construido no está disponible (servidor
      // dev, primera vez, etc.) genera uno con xlsx en cliente.
      try {
        await exportarExcelCompleto()
      } catch (e2) {
        setError(e2 instanceof Error ? e2.message : 'Error al exportar')
      }
    } finally {
      setDownloading(false)
    }
  }

  return (
    <header className="bg-[#1B3A5C] text-white shadow-md">
      <div className="max-w-screen-2xl mx-auto px-6 py-3 flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-8 h-8 rounded-md bg-white/10 flex items-center justify-center shrink-0">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2">
              <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
          </div>
          <div className="min-w-0">
            <h1 className="text-[15px] font-bold tracking-tight leading-tight truncate">Panel Macroeconómico</h1>
            <p className="text-[10px] text-white/60 leading-tight">Monitor de Indicadores Financieros y Económicos</p>
          </div>
        </div>

        <div className="flex items-center gap-3 shrink-0">
          {lastUpdate && (
            <div className="text-[10px] text-white/50 hidden md:flex items-center gap-1.5">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
              </svg>
              Última: <span className="text-white/80 font-medium">{lastUpdate}</span>
            </div>
          )}
          <button
            onClick={handleExport}
            disabled={downloading}
            title="Descargar todos los datos en un Excel multi-hoja"
            className="flex items-center gap-1.5 text-[11px] px-3 py-1.5 rounded-md bg-white/10 hover:bg-white/20 transition-colors disabled:opacity-50 disabled:cursor-wait"
          >
            {downloading ? (
              <>
                <span className="w-3 h-3 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                Generando…
              </>
            ) : (
              <>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/>
                  <polyline points="7 10 12 15 17 10"/>
                  <line x1="12" y1="15" x2="12" y2="3"/>
                </svg>
                Descargar Excel
              </>
            )}
          </button>
          {error && (
            <span className="text-[10px] text-red-300">{error}</span>
          )}
        </div>
      </div>
    </header>
  )
}
