#!/bin/bash

# Script de génération du projet Turborepo
# Pour Mac/Linux

set -e

PROJECT_NAME="mon-projet"

echo "🚀 Création du projet $PROJECT_NAME..."

# Créer la structure de dossiers
mkdir -p $PROJECT_NAME/{apps/{admin,dashboard,vitrine},packages/{firebase,ui,typescript-config,eslint-config}}

cd $PROJECT_NAME

# ============================================================
# FICHIERS RACINE
# ============================================================

echo "📝 Création des fichiers de configuration racine..."

cat > package.json << 'EOF'
{
  "name": "mon-projet",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "lint": "turbo run lint",
    "clean": "turbo run clean"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "typescript": "^5.3.0"
  },
  "packageManager": "pnpm@8.15.0",
  "engines": {
    "node": ">=18"
  }
}
EOF

cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "clean": {
      "cache": false
    }
  }
}
EOF

cat > .gitignore << 'EOF'
# dependencies
node_modules
.pnp
.pnp.js

# testing
coverage

# next.js
.next/
out/
build
dist

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local
.env

# turbo
.turbo
EOF

cat > README.md << 'EOF'
# Mon Projet Turborepo

Projet multi-apps avec:
- Admin Dashboard (port 3001)
- User Dashboard (port 3002)
- Site Vitrine avec SEO (port 3000)

## Installation

```bash
pnpm install
```

## Configuration

Copiez les fichiers .env.local.example et configurez vos variables Firebase:

```bash
cp apps/admin/.env.local.example apps/admin/.env.local
cp apps/dashboard/.env.local.example apps/dashboard/.env.local
cp apps/vitrine/.env.local.example apps/vitrine/.env.local
```

## Développement

```bash
# Lancer tous les projets
pnpm dev

# Lancer un projet spécifique
cd apps/admin && pnpm dev
```

## Build

```bash
pnpm build
```
EOF

# ============================================================
# APP: ADMIN
# ============================================================

echo "📱 Création de l'app Admin..."

cat > apps/admin/package.json << 'EOF'
{
  "name": "@mon-projet/admin",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3001",
    "build": "next build",
    "start": "next start -p 3001",
    "lint": "next lint"
  },
  "dependencies": {
    "@mon-projet/firebase": "workspace:*",
    "@mon-projet/ui": "workspace:*",
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "firebase": "^10.12.0"
  },
  "devDependencies": {
    "@mon-projet/typescript-config": "workspace:*",
    "@mon-projet/eslint-config": "workspace:*",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5.3.0",
    "eslint": "^8",
    "eslint-config-next": "^14.2.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
EOF

cat > apps/admin/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
}

module.exports = nextConfig
EOF

cat > apps/admin/tsconfig.json << 'EOF'
{
  "extends": "@mon-projet/typescript-config/nextjs.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > apps/admin/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > apps/admin/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > apps/admin/.env.local.example << 'EOF'
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=your_data_connect_url
EOF

mkdir -p apps/admin/app
cat > apps/admin/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Admin Dashboard',
  robots: { index: false, follow: false },
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
EOF

cat > apps/admin/app/page.tsx << 'EOF'
import { Button } from '@mon-projet/ui/button'

export default function AdminPage() {
  return (
    <main className="min-h-screen p-8 bg-gray-50">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Admin Dashboard</h1>
        <p className="text-gray-600 mb-6">Gérez votre application depuis cette interface.</p>
        <Button>Action Admin</Button>
      </div>
    </main>
  )
}
EOF

cat > apps/admin/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# ============================================================
# APP: DASHBOARD
# ============================================================

echo "👤 Création de l'app Dashboard..."

cat > apps/dashboard/package.json << 'EOF'
{
  "name": "@mon-projet/dashboard",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3002",
    "build": "next build",
    "start": "next start -p 3002",
    "lint": "next lint"
  },
  "dependencies": {
    "@mon-projet/firebase": "workspace:*",
    "@mon-projet/ui": "workspace:*",
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "firebase": "^10.12.0"
  },
  "devDependencies": {
    "@mon-projet/typescript-config": "workspace:*",
    "@mon-projet/eslint-config": "workspace:*",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5.3.0",
    "eslint": "^8",
    "eslint-config-next": "^14.2.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
EOF

cat > apps/dashboard/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
}

module.exports = nextConfig
EOF

cat > apps/dashboard/tsconfig.json << 'EOF'
{
  "extends": "@mon-projet/typescript-config/nextjs.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > apps/dashboard/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > apps/dashboard/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > apps/dashboard/.env.local.example << 'EOF'
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=your_data_connect_url
EOF

mkdir -p apps/dashboard/app
cat > apps/dashboard/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'User Dashboard',
  robots: { index: false, follow: false },
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
EOF

cat > apps/dashboard/app/page.tsx << 'EOF'
import { Button } from '@mon-projet/ui/button'

export default function DashboardPage() {
  return (
    <main className="min-h-screen p-8 bg-gray-50">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Dashboard Utilisateur</h1>
        <p className="text-gray-600 mb-6">Bienvenue sur votre espace personnel.</p>
        <Button>Mon Action</Button>
      </div>
    </main>
  )
}
EOF

cat > apps/dashboard/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# ============================================================
# APP: VITRINE
# ============================================================

echo "🌐 Création de l'app Vitrine..."

cat > apps/vitrine/package.json << 'EOF'
{
  "name": "@mon-projet/vitrine",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "@mon-projet/firebase": "workspace:*",
    "@mon-projet/ui": "workspace:*",
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "firebase": "^10.12.0"
  },
  "devDependencies": {
    "@mon-projet/typescript-config": "workspace:*",
    "@mon-projet/eslint-config": "workspace:*",
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5.3.0",
    "eslint": "^8",
    "eslint-config-next": "^14.2.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
EOF

cat > apps/vitrine/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
}

module.exports = nextConfig
EOF

cat > apps/vitrine/tsconfig.json << 'EOF'
{
  "extends": "@mon-projet/typescript-config/nextjs.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > apps/vitrine/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

cat > apps/vitrine/postcss.config.js << 'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

cat > apps/vitrine/.env.local.example << 'EOF'
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=your_data_connect_url
EOF

mkdir -p apps/vitrine/app
cat > apps/vitrine/app/layout.tsx << 'EOF'
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
EOF

cat > apps/vitrine/app/page.tsx << 'EOF'
import { Button } from '@mon-projet/ui/button'

export default function HomePage() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-blue-600 to-purple-700 text-white py-20">
        <div className="max-w-6xl mx-auto px-4">
          <h1 className="text-5xl font-bold mb-6">
            Bienvenue sur Notre Site
          </h1>
          <p className="text-xl mb-8 max-w-2xl">
            Découvrez nos services exceptionnels et transformez votre business 
            avec nos solutions innovantes.
          </p>
          <Button className="bg-white text-blue-600 hover:bg-gray-100">
            En savoir plus
          </Button>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">
            Nos Services
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            {[1, 2, 3].map((i) => (
              <div key={i} className="p-6 border rounded-lg shadow-sm">
                <h3 className="text-xl font-semibold mb-3">Service {i}</h3>
                <p className="text-gray-600">
                  Description de votre service avec des mots-clés pertinents 
                  pour le SEO.
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </main>
  )
}
EOF

cat > apps/vitrine/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# ============================================================
# PACKAGE: FIREBASE
# ============================================================

echo "🔥 Création du package Firebase..."

cat > packages/firebase/package.json << 'EOF'
{
  "name": "@mon-projet/firebase",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "firebase": "^10.12.0"
  },
  "devDependencies": {
    "@mon-projet/typescript-config": "workspace:*",
    "typescript": "^5.3.0"
  }
}
EOF

cat > packages/firebase/tsconfig.json << 'EOF'
{
  "extends": "@mon-projet/typescript-config/base.json",
  "compilerOptions": {
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
EOF

mkdir -p packages/firebase/src
cat > packages/firebase/src/index.ts << 'EOF'
export * from './config'
export * from './auth'
export * from './dataconnect'
EOF

cat > packages/firebase/src/config.ts << 'EOF'
import { initializeApp, getApps, FirebaseApp } from 'firebase/app'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
}

let app: FirebaseApp

if (typeof window !== 'undefined' && !getApps().length) {
  app = initializeApp(firebaseConfig)
}

export { app }
export { firebaseConfig }
EOF

cat > packages/firebase/src/auth.ts << 'EOF'
import { getAuth, Auth } from 'firebase/auth'
import { app } from './config'

let auth: Auth

if (typeof window !== 'undefined') {
  auth = getAuth(app)
}

export { auth }
EOF

cat > packages/firebase/src/dataconnect.ts << 'EOF'
import { getDataConnect, DataConnect } from 'firebase/data-connect'
import { app } from './config'

let dataConnect: DataConnect

if (typeof window !== 'undefined') {
  dataConnect = getDataConnect(app, {
    connector: 'your-connector-name',
    location: 'us-east4',
    service: 'your-service-id'
  })
}

export { dataConnect }

// Types d'exemple - à adapter selon votre schéma
export interface User {
  id: string
  email: string
  name: string
  createdAt: string
}

// Fonctions helpers d'exemple
export async function getUsers(): Promise<User[]> {
  // TODO: Implémentation avec Firebase Data Connect
  return []
}

export async function getUserById(id: string): Promise<User | null> {
  // TODO: Implémentation avec Firebase Data Connect
  return null
}
EOF

# ============================================================
# PACKAGE: UI
# ============================================================

echo "🎨 Création du package UI..."

cat > packages/ui/package.json << 'EOF'
{
  "name": "@mon-projet/ui",
  "version": "1.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "@mon-projet/typescript-config": "workspace:*",
    "@mon-projet/eslint-config": "workspace:*",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5.3.0"
  }
}
EOF

cat > packages/ui/tsconfig.json << 'EOF'
{
  "extends": "@mon-projet/typescript-config/react-library.json",
  "compilerOptions": {
    "outDir": "dist"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
EOF

mkdir -p packages/ui/src
cat > packages/ui/src/index.ts << 'EOF'
export { Button } from './button'
export { Card } from './card'
EOF

cat > packages/ui/src/button.tsx << 'EOF'
import React from 'react'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode
  variant?: 'primary' | 'secondary' | 'outline'
}

export function Button({ 
  children, 
  className = '', 
  variant = 'primary',
  ...props 
}: ButtonProps) {
  const baseStyles = 'px-4 py-2 rounded font-medium transition-colors'
  
  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-600 text-white hover:bg-gray-700',
    outline: 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50'
  }

  return (
    <button
      className={`${baseStyles} ${variants[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}
EOF

cat > packages/ui/src/card.tsx << 'EOF'
import React from 'react'

interface CardProps {
  children: React.ReactNode
  className?: string
  title?: string
}

export function Card({ children, className = '', title }: CardProps) {
  return (
    <div className={`bg-white rounded-lg shadow-md p-6 ${className}`}>
      {title && <h3 className="text-xl font-semibold mb-4">{title}</h3>}
      {children}
    </div>
  )
}
EOF

# ============================================================
# PACKAGE: TYPESCRIPT CONFIG
# ============================================================

echo "⚙️  Création du package TypeScript Config..."

cat > packages/typescript-config/package.json << 'EOF'
{
  "name": "@mon-projet/typescript-config",
  "version": "1.0.0",
  "private": true,
  "main": "base.json"
}
EOF

cat > packages/typescript-config/base.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowJs": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "isolatedModules": true,
    "incremental": true
  },
  "exclude": ["node_modules"]
}
EOF

cat > packages/typescript-config/nextjs.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "ES2020"],
    "jsx": "preserve",
    "module": "esnext",
    "moduleResolution": "bundler",
    "noEmit": true
  }
}
EOF

cat > packages/typescript-config/react-library.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true
  }
}
EOF

# ============================================================
# PACKAGE: ESLINT CONFIG
# ============================================================

echo "🔍 Création du package ESLint Config..."

cat > packages/eslint-config/package.json << 'EOF'
{
  "name": "@mon-projet/eslint-config",
  "version": "1.0.0",
  "private": true,
  "main": "index.js",
  "dependencies": {
    "eslint-config-next": "^14.2.0",
    "eslint-config-prettier": "^9.1.0"
  }
}
EOF

cat > packages/eslint-config/index.js << 'EOF'
module.exports = {
  extends: ['next', 'prettier'],
}
EOF

# ============================================================
# FINALISATION
# ============================================================

echo ""
echo "✅ Projet créé avec succès !"
echo ""
echo "📍 Prochaines étapes :"
echo ""
echo "1. Installer pnpm si nécessaire :"
echo "   npm install -g pnpm"
echo ""
echo "2. Installer les dépendances :"
echo "   cd $PROJECT_NAME"
echo "   pnpm install"
echo ""
echo "3. Configurer Firebase :"
echo "   cp apps/admin/.env.local.example apps/admin/.env.local"
echo "   cp apps/dashboard/.env.local.example apps/dashboard/.env.local"
echo "   cp apps/vitrine/.env.local.example apps/vitrine/.env.local"
echo "   # Puis éditez chaque .env.local avec vos credentials Firebase"
echo ""
echo "4. Lancer le projet :"
echo "   pnpm dev"
echo ""
echo "🌐 URLs de développement :"
echo "   - Admin:     http://localhost:3001"
echo "   - Dashboard: http://localhost:3002"
echo "   - Vitrine:   http://localhost:3000"
echo ""
echo "🎉 Bon développement !"