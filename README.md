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
