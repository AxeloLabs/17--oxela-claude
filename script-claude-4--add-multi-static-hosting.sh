#!/bin/bash

# Script de configuration Firebase Hosting pour monorepo
# À exécuter à la racine du projet

set -e

echo "🔥 Configuration Firebase Hosting pour Monorepo"
echo ""

# Vérifier qu'on est dans le bon dossier
if [ ! -f "turbo.json" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet Turborepo"
  exit 1
fi

# Vérifier que Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI n'est pas installé."
    echo "📦 Installation..."
    npm install -g firebase-tools
fi

echo "✅ Firebase CLI est installé"
echo ""

# Demander le nom du projet
read -p "📝 Nom de votre projet (sans espaces, ex: mon-ecommerce): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME="mon-projet"
  echo "   Utilisation du nom par défaut: $PROJECT_NAME"
fi

echo ""
echo "🏗️  Création de la configuration Firebase Hosting..."
echo ""

# ============================================================
# CRÉER firebase.json
# ============================================================

cat > firebase.json << EOF
{
  "hosting": [
    {
      "site": "${PROJECT_NAME}-vitrine",
      "public": "apps/vitrine/out",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "cleanUrls": true,
      "trailingSlash": false,
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ],
      "headers": [
        {
          "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|ico|woff|woff2|ttf|eot)",
          "headers": [
            {
              "key": "Cache-Control",
              "value": "public, max-age=31536000, immutable"
            }
          ]
        },
        {
          "source": "**/*.@(js|css)",
          "headers": [
            {
              "key": "Cache-Control",
              "value": "public, max-age=31536000, immutable"
            }
          ]
        }
      ]
    },
    {
      "site": "${PROJECT_NAME}-dashboard",
      "public": "apps/dashboard/out",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "cleanUrls": true,
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    },
    {
      "site": "${PROJECT_NAME}-admin",
      "public": "apps/admin/out",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "cleanUrls": true,
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    }
  ],
  "dataconnect": {
    "source": "dataconnect"
  }
}
EOF

echo "✅ firebase.json créé"

# ============================================================
# CRÉER .firebaserc
# ============================================================

echo ""
echo "🔐 Connexion à Firebase..."
firebase login

echo ""
echo "📋 Sélectionnez ou créez votre projet Firebase..."
firebase use --add

# Récupérer le project ID
PROJECT_ID=$(firebase use | grep "Active Project" | awk '{print $3}' || firebase projects:list --json | jq -r '.[0].projectId')

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Impossible de récupérer le project ID"
  echo "💡 Vous devrez créer les sites manuellement"
else
  echo ""
  echo "🌐 Création des sites Firebase Hosting..."
  
  # Créer les 3 sites
  echo "   Création de ${PROJECT_NAME}-vitrine..."
  firebase hosting:sites:create ${PROJECT_NAME}-vitrine 2>/dev/null || echo "   Site vitrine existe déjà"
  
  echo "   Création de ${PROJECT_NAME}-dashboard..."
  firebase hosting:sites:create ${PROJECT_NAME}-dashboard 2>/dev/null || echo "   Site dashboard existe déjà"
  
  echo "   Création de ${PROJECT_NAME}-admin..."
  firebase hosting:sites:create ${PROJECT_NAME}-admin 2>/dev/null || echo "   Site admin existe déjà"
  
  echo "✅ Sites créés avec succès"
fi

# ============================================================
# METTRE À JOUR next.config.js pour VITRINE
# ============================================================

echo ""
echo "⚙️  Configuration de Next.js pour export statique..."

cat > apps/vitrine/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
  output: 'export',
  images: {
    unoptimized: true
  },
  trailingSlash: true
}

module.exports = nextConfig
EOF

echo "✅ apps/vitrine/next.config.js configuré"

# ============================================================
# METTRE À JOUR next.config.js pour DASHBOARD
# ============================================================

cat > apps/dashboard/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
  output: 'export',
  images: {
    unoptimized: true
  }
}

module.exports = nextConfig
EOF

echo "✅ apps/dashboard/next.config.js configuré"

# ============================================================
# METTRE À JOUR next.config.js pour ADMIN
# ============================================================

cat > apps/admin/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
  output: 'export',
  images: {
    unoptimized: true
  }
}

module.exports = nextConfig
EOF

echo "✅ apps/admin/next.config.js configuré"

# ============================================================
# METTRE À JOUR package.json racine avec scripts de déploiement
# ============================================================

echo ""
echo "📦 Ajout des scripts de déploiement..."

# Créer un fichier temporaire pour le nouveau package.json
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

pkg.scripts = {
  ...pkg.scripts,
  'build:vitrine': 'pnpm --filter @mon-projet/vitrine build',
  'build:dashboard': 'pnpm --filter @mon-projet/dashboard build',
  'build:admin': 'pnpm --filter @mon-projet/admin build',
  'deploy': 'pnpm build && firebase deploy',
  'deploy:vitrine': 'pnpm build:vitrine && firebase deploy --only hosting:${PROJECT_NAME}-vitrine',
  'deploy:dashboard': 'pnpm build:dashboard && firebase deploy --only hosting:${PROJECT_NAME}-dashboard',
  'deploy:admin': 'pnpm build:admin && firebase deploy --only hosting:${PROJECT_NAME}-admin',
  'deploy:dataconnect': 'firebase deploy --only dataconnect'
};

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
" 2>/dev/null || echo "⚠️  Impossible de mettre à jour package.json automatiquement"

echo "✅ Scripts ajoutés au package.json"

# ============================================================
# CRÉER script de déploiement interactif
# ============================================================

echo ""
echo "🚀 Création du script de déploiement interactif..."

cat > deploy.sh << 'DEPLOY_SCRIPT'
#!/bin/bash

# Script de déploiement Firebase interactif
set -e

echo "🚀 Déploiement Firebase"
echo ""
echo "Que voulez-vous déployer ?"
echo ""
echo "1) 🌐 Site Vitrine uniquement"
echo "2) 👤 Dashboard Utilisateur uniquement"
echo "3) ⚙️  Admin uniquement"
echo "4) 🔥 Data Connect uniquement"
echo "5) 🎯 Tout déployer"
echo "6) 🧪 Preview (test avant déploiement)"
echo ""

read -p "Votre choix (1-6): " choice
echo ""

case $choice in
  1)
    echo "📦 Build du site vitrine..."
    pnpm --filter @mon-projet/vitrine build
    echo ""
    echo "🚀 Déploiement..."
    firebase deploy --only hosting:PROJECT_NAME-vitrine
    ;;
  2)
    echo "📦 Build du dashboard..."
    pnpm --filter @mon-projet/dashboard build
    echo ""
    echo "🚀 Déploiement..."
    firebase deploy --only hosting:PROJECT_NAME-dashboard
    ;;
  3)
    echo "📦 Build de l'admin..."
    pnpm --filter @mon-projet/admin build
    echo ""
    echo "🚀 Déploiement..."
    firebase deploy --only hosting:PROJECT_NAME-admin
    ;;
  4)
    echo "🚀 Déploiement Data Connect..."
    firebase deploy --only dataconnect
    ;;
  5)
    echo "📦 Build de toutes les apps..."
    pnpm build
    echo ""
    echo "🚀 Déploiement complet..."
    firebase deploy
    ;;
  6)
    echo "📦 Build de toutes les apps..."
    pnpm build
    echo ""
    echo "🧪 Création d'un preview channel..."
    firebase hosting:channel:deploy preview
    ;;
  *)
    echo "❌ Choix invalide"
    exit 1
    ;;
esac

echo ""
echo "✅ Déploiement terminé !"
echo ""
echo "🌐 Vos sites sont disponibles à:"
echo "   Vitrine:   https://PROJECT_NAME-vitrine.web.app"
echo "   Dashboard: https://PROJECT_NAME-dashboard.web.app"
echo "   Admin:     https://PROJECT_NAME-admin.web.app"
echo ""
DEPLOY_SCRIPT

# Remplacer PROJECT_NAME dans deploy.sh
sed -i.bak "s/PROJECT_NAME/${PROJECT_NAME}/g" deploy.sh && rm deploy.sh.bak

chmod +x deploy.sh

echo "✅ deploy.sh créé"

# ============================================================
# CRÉER .firebaseignore
# ============================================================

cat > .firebaseignore << 'EOF'
# Node
node_modules/
**/node_modules/**

# Build
.next/
out/
dist/
build/

# Cache
.turbo/
.cache/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Git
.git/
.gitignore

# Testing
coverage/
.nyc_output/

# Misc
*.pem
*.key
EOF

echo "✅ .firebaseignore créé"

# ============================================================
# CRÉER README pour le déploiement
# ============================================================

cat > DEPLOYMENT.md << EOF
# 🚀 Guide de Déploiement

## Sites Firebase Hosting

Votre projet utilise 3 sites Firebase Hosting:

- **${PROJECT_NAME}-vitrine**: Site public avec SEO
- **${PROJECT_NAME}-dashboard**: Dashboard utilisateur (authentifié)
- **${PROJECT_NAME}-admin**: Interface admin (authentifié)

## 📦 Build local

\`\`\`bash
# Build toutes les apps
pnpm build

# Build une app spécifique
pnpm build:vitrine
pnpm build:dashboard
pnpm build:admin
\`\`\`

## 🚀 Déploiement

### Méthode 1: Script interactif (recommandé)

\`\`\`bash
./deploy.sh
\`\`\`

Le script vous guidera pour choisir ce que vous voulez déployer.

### Méthode 2: Commandes directes

\`\`\`bash
# Déployer tout
pnpm deploy

# Déployer un site spécifique
pnpm deploy:vitrine
pnpm deploy:dashboard
pnpm deploy:admin

# Déployer Data Connect
pnpm deploy:dataconnect
\`\`\`

### Méthode 3: Firebase CLI

\`\`\`bash
# Déployer un site spécifique
firebase deploy --only hosting:${PROJECT_NAME}-vitrine

# Déployer plusieurs sites
firebase deploy --only hosting:${PROJECT_NAME}-vitrine,hosting:${PROJECT_NAME}-dashboard

# Déployer tout
firebase deploy
\`\`\`

## 🧪 Preview avant déploiement

\`\`\`bash
# Créer un preview channel
firebase hosting:channel:deploy preview

# Preview d'un site spécifique
firebase hosting:channel:deploy preview --only ${PROJECT_NAME}-vitrine
\`\`\`

## 🌐 URLs de production

- Vitrine: https://${PROJECT_NAME}-vitrine.web.app
- Dashboard: https://${PROJECT_NAME}-dashboard.web.app
- Admin: https://${PROJECT_NAME}-admin.web.app

## 🎨 Domaines personnalisés

Pour ajouter des domaines personnalisés:

1. Aller dans Firebase Console > Hosting
2. Cliquer sur "Ajouter un domaine personnalisé"
3. Suivre les instructions pour chaque site

Exemple:
- vitrine.mondomaine.com → ${PROJECT_NAME}-vitrine
- app.mondomaine.com → ${PROJECT_NAME}-dashboard
- admin.mondomaine.com → ${PROJECT_NAME}-admin

## 🔄 Workflow de développement

\`\`\`bash
# 1. Développement local
pnpm dev

# 2. Tester le build
pnpm build

# 3. Déployer en preview
firebase hosting:channel:deploy preview

# 4. Valider et déployer en production
./deploy.sh
\`\`\`

## 📊 Voir les logs

\`\`\`bash
# Logs de déploiement
firebase hosting:channel:list

# Voir les versions
firebase hosting:releases:list
\`\`\`

## 🔧 Dépannage

### "Public directory not found"
- Assurez-vous d'avoir build l'app avant: \`pnpm build\`
- Vérifiez que le dossier \`out\` existe dans chaque app

### "Site not found"
- Créez le site: \`firebase hosting:sites:create ${PROJECT_NAME}-SITENAME\`
- Vérifiez firebase.json

### Build échoue
- Nettoyez le cache: \`rm -rf .next .turbo node_modules\`
- Réinstallez: \`pnpm install\`
- Rebuilder: \`pnpm build\`

## 🚀 Alternative: Vercel

Si vous préférez Vercel pour la vitrine (meilleur SEO avec SSR):

1. Déployer la vitrine sur Vercel
2. Garder dashboard et admin sur Firebase
3. Modifier \`apps/vitrine/next.config.js\` pour enlever \`output: 'export'\`

## 📚 Ressources

- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Next.js Static Export](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Multi-site Hosting](https://firebase.google.com/docs/hosting/multisites)
EOF

echo "✅ DEPLOYMENT.md créé"

# ============================================================
# FINALISATION
# ============================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Configuration Firebase Hosting terminée !"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Fichiers créés:"
echo "   ✓ firebase.json"
echo "   ✓ .firebaseignore"
echo "   ✓ deploy.sh (script de déploiement interactif)"
echo "   ✓ DEPLOYMENT.md (guide de déploiement)"
echo "   ✓ apps/*/next.config.js (mis à jour)"
echo ""
echo "🌐 Sites Firebase créés:"
echo "   ✓ ${PROJECT_NAME}-vitrine"
echo "   ✓ ${PROJECT_NAME}-dashboard"
echo "   ✓ ${PROJECT_NAME}-admin"
echo ""
echo "🚀 Prochaines étapes:"
echo ""
echo "1. Tester le build:"
echo "   pnpm build"
echo ""
echo "2. Déployer (choisissez une méthode):"
echo "   • Script interactif: ./deploy.sh"
echo "   • Tout déployer:    pnpm deploy"
echo "   • Site spécifique:  pnpm deploy:vitrine"
echo ""
echo "3. Voir le résultat:"
echo "   https://${PROJECT_NAME}-vitrine.web.app"
echo "   https://${PROJECT_NAME}-dashboard.web.app"
echo "   https://${PROJECT_NAME}-admin.web.app"
echo ""
echo "📖 Lire le guide complet: DEPLOYMENT.md"
echo ""
echo "💡 Astuce: Utilisez './deploy.sh' pour un déploiement"
echo "   guidé étape par étape !"
echo ""
echo "🎉 Votre projet est prêt à être déployé !"
echo ""



# ✨ Ce que le script fait automatiquement :

# ✅ Vérifie Firebase CLI
# ✅ Crée firebase.json avec 3 sites
# ✅ Vous connecte à Firebase
# ✅ Crée les 3 sites Hosting automatiquement
# ✅ Configure tous les next.config.js pour export statique
# ✅ Ajoute les scripts de déploiement au package.json
# ✅ Crée un script deploy.sh interactif
# ✅ Crée .firebaseignore
# ✅ Génère DEPLOYMENT.md avec toute la doc