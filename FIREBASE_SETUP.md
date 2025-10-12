# Guide d'installation Firebase Data Connect

## 1. Prérequis

- Avoir un projet Firebase créé sur https://console.firebase.google.com
- Node.js 18+ installé
- Firebase CLI installé (`npm install -g firebase-tools`)

## 2. Installation et configuration

### Étape 1: Se connecter à Firebase

```bash
firebase login
```

### Étape 2: Initialiser Data Connect

À la racine du projet, exécutez:

```bash
firebase init dataconnect
```

Répondez aux questions:

- **Select project**: Choisissez votre projet Firebase existant
- **Database**: PostgreSQL (Cloud SQL)
- **Region**: us-east4 (ou votre région préférée)
- **Service ID**: oxela-auth-service
- **Database name**: ecommerce

### Étape 3: Déployer le schéma

```bash
cd dataconnect
firebase deploy --only dataconnect
```

Cette commande va:

- Créer la base de données PostgreSQL
- Créer toutes les tables définies dans le schéma
- Déployer les queries et mutations

### Étape 4: Générer le SDK TypeScript

```bash
firebase dataconnect:sdk:generate
```

Cela va générer les types TypeScript et les fonctions dans:
`packages/firebase/src/generated/`

### Étape 5: Configurer les variables d'environnement

Récupérez l'URL de votre Data Connect dans la console Firebase, puis ajoutez-la dans vos fichiers `.env.local`:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=votre_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=votre_projet.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=votre_projet_id
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=https://votre-projet.us-east4.dataconnect.firebase.google.com
```

## 3. Utilisation dans le code

### Exemple: Lister les produits

```typescript
import { listProducts } from "@mon-projet/firebase";

async function getProducts() {
  const result = await listProducts({ limit: 20 });
  return result.data.products;
}
```

### Exemple: Ajouter au panier

```typescript
import { addToCart } from "@mon-projet/firebase";

async function handleAddToCart(userId: string, productId: string) {
  await addToCart({
    userId,
    productId,
    quantity: 1,
  });
}
```

### Exemple avec les hooks React

```typescript
"use client";

import { useProducts } from "@mon-projet/firebase";

export default function ProductsPage() {
  const { products, loading, error } = useProducts();

  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error.message}</div>;

  return (
    <div>
      {products.map((product) => (
        <div key={product.id}>{product.name}</div>
      ))}
    </div>
  );
}
```

## 4. Commandes utiles

```bash
# Voir les logs
firebase dataconnect:services:list

# Redéployer après modification du schéma
firebase deploy --only dataconnect

# Régénérer le SDK après modification des queries
firebase dataconnect:sdk:generate

# Voir la console Data Connect
firebase dataconnect:sql:shell
```

## 5. Données de test

Pour ajouter des données de test, vous pouvez utiliser les mutations dans la console Firebase ou créer un script:

```typescript
// scripts/seed-database.ts
import {
  createCategory,
  createProduct,
  upsertUser,
} from "@mon-projet/firebase";

async function seed() {
  // Créer des catégories
  const category = await createCategory({
    name: "Électronique",
    slug: "electronique",
    description: "Produits électroniques",
  });

  // Créer des produits
  await createProduct({
    name: "Smartphone XYZ",
    slug: "smartphone-xyz",
    description: "Le meilleur smartphone",
    price: 599.99,
    stock: 50,
    imageUrl: "https://...",
    categoryId: category.data.category_insert.id,
  });
}

seed().catch(console.error);
```

## 6. Résolution de problèmes

### Erreur: "Service not found"

- Vérifiez que le déploiement s'est bien passé
- Vérifiez l'URL dans vos variables d'environnement

### Erreur: "Unauthorized"

- Vérifiez que Firebase Auth est bien configuré
- Vérifiez les règles d'authentification dans vos queries/mutations

### Le SDK ne se génère pas

- Vérifiez que le fichier `connector.yaml` est correct
- Assurez-vous d'être dans le bon dossier lors de l'exécution

## 7. Ressources

- [Documentation Firebase Data Connect](https://firebase.google.com/docs/data-connect)
- [GraphQL Schema Reference](https://firebase.google.com/docs/data-connect/schema)
- [SDK Generation Guide](https://firebase.google.com/docs/data-connect/sdk)
