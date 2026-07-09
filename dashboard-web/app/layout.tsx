import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Dashboard Macro',
  description: 'Panel a la carta',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    // suppressHydrationWarning en <html> y <body> evita el warning de hidratación
    // cuando extensiones de browser (Bitwarden, LastPass, Edge autofill, etc.)
    // inyectan atributos como `fdprocessedid` en los elementos antes de que
    // React termine de hidratar. No es un bug del código.
    <html lang="es" className="h-full" suppressHydrationWarning>
      <body className="min-h-full flex flex-col" suppressHydrationWarning>{children}</body>
    </html>
  )
}
