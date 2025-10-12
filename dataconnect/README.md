# Firebase Data Connect E-commerce

Ce dossier contient le schéma et les requêtes Firebase Data Connect pour l'application e-commerce.

## Structure

```
dataconnect/
├── dataconnect.yaml          # Configuration principale
├── schema/
│   └── schema.gql           # Schéma de données (tables, types, relations)
└── connectors/
    └── ecommerce/
        ├── connector.yaml   # Configuration du connecteur
        ├── queries.gql      # Requêtes de lecture
        └── mutations.gql    # Mutations (create, update, delete)
```

## Installation Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

## Initialisation

```bash
# À la racine du projet
firebase init dataconnect

# Sélectionner:
# - Use an existing project (ou créer un nouveau)
# - PostgreSQL (Cloud SQL)
# - Choisir la région (us-east4 recommandé)
```

## Déploiement

```bash
# Déployer le schéma et les connecteurs
firebase deploy --only dataconnect

# Générer le SDK TypeScript
firebase dataconnect:sdk:generate
```

## Utilisation dans le code

Après génération du SDK, vous pouvez utiliser les fonctions dans votre code:

```typescript
import { listProducts, getProductBySlug } from "@mon-projet/firebase";

// Lister les produits
const products = await listProducts({ limit: 20 });

// Récupérer un produit
const product = await getProductBySlug({ slug: "mon-produit" });
```

## Schéma de données

### Tables principales:

- **User**: Utilisateurs (synchronisés avec Firebase Auth)
- **Product**: Produits du catalogue
- **Category**: Catégories de produits
- **Order**: Commandes
- **OrderItem**: Articles dans les commandes
- **CartItem**: Panier d'achat
- **Review**: Avis clients

## Variables d'environnement

Ajoutez dans vos fichiers `.env.local`:

```
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=https://your-project.us-east4.dataconnect.firebase.google.com
```
