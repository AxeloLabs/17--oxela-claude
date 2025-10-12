#!/bin/bash

echo "🔥 Configuration Firebase Data Connect"
echo ""
echo "Ce script vous aide à configurer Firebase Data Connect pour votre projet."
echo ""

# Vérifier si Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI n'est pas installé."
    echo "📦 Installation..."
    npm install -g firebase-tools
fi

echo "✅ Firebase CLI est installé"
echo ""

# Login Firebase
echo "🔐 Connexion à Firebase..."
firebase login

echo ""
echo "📋 Prochaines étapes manuelles:"
echo ""
echo "1. Initialisez Data Connect:"
echo "   firebase init dataconnect"
echo ""
echo "2. Déployez votre schéma:"
echo "   firebase deploy --only dataconnect"
echo ""
echo "3. Générez le SDK TypeScript:"
echo "   firebase dataconnect:sdk:generate"
echo ""
echo "4. Les fichiers générés seront dans:"
echo "   packages/firebase/src/generated/"
echo ""
echo "5. Mettez à jour vos .env.local avec l'URL Data Connect"
echo ""
echo "📚 Documentation: https://firebase.google.com/docs/data-connect"
