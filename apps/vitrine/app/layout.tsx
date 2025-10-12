import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Mon Site Vitrine - Bienvenue',
  description: 'Découvrez nos services et produits. Description optimisée pour le SEO.',
  keywords: ['mot-clé1', 'mot-clé2', 'mot-clé3'],
  authors: [{ name: 'Votre Entreprise' }],
  openGraph: {
    title: 'Mon Site Vitrine',
    description: 'Description optimisée pour le SEO',
    type: 'website',
    locale: 'fr_FR',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Mon Site Vitrine',
    description: 'Description optimisée pour le SEO',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  )
}
