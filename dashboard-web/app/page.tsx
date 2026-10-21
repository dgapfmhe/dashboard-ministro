'use client'
import { useState, useEffect } from 'react'
import Header from '@/components/layout/Header'
import SectorExterno from '@/components/tabs/SectorExterno'
import DepositosRemunerados from '@/components/tabs/DepositosRemunerados'
import DepositosPrestamos from '@/components/tabs/DepositosPrestamos'
import Tasas from '@/components/tabs/Tasas'
import TipoCambio from '@/components/tabs/TipoCambio'
import SectorElectrico from '@/components/tabs/SectorElectrico'
import Personalizado from '@/components/tabs/Personalizado'
import Sintesis from '@/components/tabs/Sintesis'
import Sentimiento from '@/components/tabs/Sentimiento'
import Laboratorio from '@/components/tabs/Laboratorio'

const TABS = [
  { id: 'sintesis',             label: 'Síntesis Macro' },
  { id: 'externo',              label: 'Sector Externo' },
  { id: 'depositos-rem',        label: 'Depósitos Remunerados CP' },
  { id: 'depositos-prestamos',  label: 'Depósitos y Préstamos' },
  { id: 'tasas',                label: 'Tasas' },
  { id: 'tipo-cambio',          label: 'Tipo de Cambio' },
  { id: 'sector-electrico',     label: 'Sector Eléctrico' },
  { id: 'sentimiento',          label: 'Sentimiento de Prensa' },
  { id: 'laboratorio',          label: 'Laboratorio de Pronósticos' },
  { id: 'personalizado',        label: 'Personalizado' },
] as const

type TabId = typeof TABS[number]['id']

export default function Home() {
  const [active, setActive] = useState<TabId>('sintesis')
  // Renderizar buttons SOLO después del mount del cliente. El servidor envía
  // un placeholder; el navegador hidrata y entonces renderiza los buttons.
  // Esto evita que extensiones (Bitwarden, autofill) inyecten `fdprocessedid`
  // entre el SSR y la hidratación, causando el warning de mismatch.
  const [mounted, setMounted] = useState(false)
  useEffect(() => { setMounted(true) }, [])

  return (
    <div className="min-h-screen flex flex-col bg-[#EEF0F4]">
      <Header />

      {/* ── Tab navigation ── */}
      <nav className="bg-white border-b border-[#D1D9E0] sticky top-0 z-40 shadow-sm">
        <div className="max-w-screen-2xl mx-auto px-4 flex items-end gap-0 overflow-x-auto min-h-[48px]">
          {mounted && TABS.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActive(tab.id)}
              className={[
                'relative shrink-0 px-4 py-3 text-[12px] font-medium transition-colors whitespace-nowrap',
                active === tab.id
                  ? 'text-[#1B3A5C] border-b-2 border-[#1B3A5C]'
                  : 'text-[#6B7280] hover:text-[#1A202C] border-b-2 border-transparent',
              ].join(' ')}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </nav>

      {/* ── Tab content ── */}
      <main className="flex-1 max-w-screen-2xl mx-auto w-full px-4 py-5">
        {mounted && active === 'sintesis'            && <Sintesis />}
        {mounted && active === 'externo'             && <SectorExterno />}
        {mounted && active === 'depositos-rem'       && <DepositosRemunerados />}
        {mounted && active === 'depositos-prestamos' && <DepositosPrestamos />}
        {mounted && active === 'tasas'               && <Tasas />}
        {mounted && active === 'tipo-cambio'         && <TipoCambio />}
        {mounted && active === 'sector-electrico'    && <SectorElectrico />}
        {mounted && active === 'sentimiento'         && <Sentimiento />}
        {mounted && active === 'laboratorio'         && <Laboratorio />}
        {mounted && active === 'personalizado'       && <Personalizado />}
      </main>

      {/* ── Footer ── */}
      <footer className="bg-white border-t border-[#D1D9E0] mt-auto">
        <div className="max-w-screen-2xl mx-auto px-6 py-3 flex items-center justify-between">
          <p className="text-[10px] text-[#9CA3AF]">
            Fuentes: BCRD · DGII · DGAPF · MEM · FRED · Yahoo Finance · Banco Mundial · Google News
          </p>
          <p className="text-[10px] text-[#9CA3AF]">
            Actualización automática vía GitHub Actions
          </p>
        </div>
      </footer>
    </div>
  )
}
