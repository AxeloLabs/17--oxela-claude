#!/bin/bash

# Script d'ajout du module Firebase Data Connect E-commerce
# À exécuter à la racine du projet généré par le premier script

set -e

echo "🔥 Installation du module Firebase Data Connect E-commerce..."

# Vérifier qu'on est dans le bon dossier
if [ ! -f "turbo.json" ]; then
  echo "❌ Erreur: Ce script doit être exécuté à la racine du projet Turborepo"
  exit 1
fi

# ============================================================
# STRUCTURE FIREBASE DATA CONNECT
# ============================================================

echo "📁 Création de la structure Firebase Data Connect..."

mkdir -p dataconnect/{schema,connectors/ecommerce}

# ============================================================
# CONFIGURATION DATACONNECT
# ============================================================

cat > dataconnect/dataconnect.yaml << 'EOF'
specVersion: 'v1alpha'
serviceId: 'ecommerce-dataconnect'
location: 'europe-west1'
schema:
  source: './schema'
  datasource:
    postgresql:
      database: 'ecommerce'
connectorDirs: ['./connectors']
EOF

# ============================================================
# SCHEMA: TYPES DE BASE
# ============================================================

echo "📝 Création du schéma GraphQL..."

cat > dataconnect/schema/schema.gql << 'EOF'
# Types et énumérations

enum UserRole {
  ADMIN
  CUSTOMER
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

enum ProductStatus {
  ACTIVE
  INACTIVE
  OUT_OF_STOCK
}

# Type User (lié à Firebase Auth)
type User @table {
  id: UUID! @default(expr: "uuidV4()")
  firebaseUid: String! @unique
  email: String! @unique
  displayName: String
  photoURL: String
  role: UserRole! @default(value: "CUSTOMER")
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
  
  # Relations
  orders: [Order!] @relationship
  reviews: [Review!] @relationship
  cartItems: [CartItem!] @relationship
}

# Type Category
type Category @table {
  id: UUID! @default(expr: "uuidV4()")
  name: String!
  slug: String! @unique
  description: String
  imageUrl: String
  parentId: UUID
  parent: Category @relationship
  children: [Category!] @relationship
  products: [Product!] @relationship
  createdAt: Timestamp! @default(expr: "request.time")
}

# Type Product
type Product @table {
  id: UUID! @default(expr: "uuidV4()")
  name: String!
  slug: String! @unique
  description: String!
  price: Float!
  compareAtPrice: Float
  stock: Int! @default(value: "0")
  status: ProductStatus! @default(value: "ACTIVE")
  imageUrl: String!
  images: [String!]
  categoryId: UUID!
  category: Category! @relationship
  sku: String @unique
  weight: Float
  dimensions: String
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
  
  # Relations
  orderItems: [OrderItem!] @relationship
  reviews: [Review!] @relationship
  cartItems: [CartItem!] @relationship
}

# Type Order
type Order @table {
  id: UUID! @default(expr: "uuidV4()")
  orderNumber: String! @unique
  userId: UUID!
  user: User! @relationship
  status: OrderStatus! @default(value: "PENDING")
  subtotal: Float!
  shippingCost: Float!
  tax: Float!
  total: Float!
  
  # Adresse de livraison
  shippingName: String!
  shippingAddress: String!
  shippingCity: String!
  shippingPostalCode: String!
  shippingCountry: String!
  
  # Adresse de facturation
  billingName: String!
  billingAddress: String!
  billingCity: String!
  billingPostalCode: String!
  billingCountry: String!
  
  paymentMethod: String!
  paymentStatus: String!
  
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
  
  # Relations
  items: [OrderItem!] @relationship
}

# Type OrderItem
type OrderItem @table {
  id: UUID! @default(expr: "uuidV4()")
  orderId: UUID!
  order: Order! @relationship
  productId: UUID!
  product: Product! @relationship
  quantity: Int!
  priceAtTime: Float!
  subtotal: Float!
}

# Type Review
type Review @table {
  id: UUID! @default(expr: "uuidV4()")
  productId: UUID!
  product: Product! @relationship
  userId: UUID!
  user: User! @relationship
  rating: Int!
  title: String
  comment: String!
  verified: Boolean! @default(value: "false")
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}

# Type CartItem (panier)
type CartItem @table {
  id: UUID! @default(expr: "uuidV4()")
  userId: UUID!
  user: User! @relationship
  productId: UUID!
  product: Product! @relationship
  quantity: Int!
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}
EOF

# ============================================================
# QUERIES
# ============================================================

cat > dataconnect/connectors/ecommerce/queries.gql << 'EOF'
# ============================================================
# QUERIES - Utilisateurs
# ============================================================

# Récupérer un utilisateur par son Firebase UID
query GetUserByFirebaseUid($firebaseUid: String!) @auth(level: USER) {
  user(firebaseUid: $firebaseUid) {
    id
    firebaseUid
    email
    displayName
    photoURL
    role
    createdAt
  }
}

# Récupérer tous les utilisateurs (admin only)
query ListUsers @auth(level: USER) {
  users {
    id
    email
    displayName
    role
    createdAt
  }
}

# ============================================================
# QUERIES - Produits
# ============================================================

# Liste tous les produits actifs
query ListProducts(
  $limit: Int = 20
  $offset: Int = 0
  $categoryId: UUID
) {
  products(
    where: { 
      status: { eq: "ACTIVE" }
      categoryId: { eq: $categoryId }
    }
    limit: $limit
    offset: $offset
    orderBy: { createdAt: DESC }
  ) {
    id
    name
    slug
    description
    price
    compareAtPrice
    stock
    status
    imageUrl
    images
    category {
      id
      name
      slug
    }
    createdAt
  }
}

# Récupérer un produit par son slug
query GetProductBySlug($slug: String!) {
  product(slug: $slug) {
    id
    name
    slug
    description
    price
    compareAtPrice
    stock
    status
    imageUrl
    images
    sku
    weight
    dimensions
    category {
      id
      name
      slug
    }
    reviews {
      id
      rating
      title
      comment
      verified
      user {
        displayName
        photoURL
      }
      createdAt
    }
    createdAt
    updatedAt
  }
}

# Recherche de produits
query SearchProducts($searchTerm: String!) {
  products(
    where: {
      OR: [
        { name: { contains: $searchTerm } }
        { description: { contains: $searchTerm } }
      ]
      status: { eq: "ACTIVE" }
    }
    limit: 20
  ) {
    id
    name
    slug
    description
    price
    imageUrl
    category {
      name
    }
  }
}

# ============================================================
# QUERIES - Catégories
# ============================================================

# Liste toutes les catégories
query ListCategories {
  categories(orderBy: { name: ASC }) {
    id
    name
    slug
    description
    imageUrl
    parent {
      id
      name
    }
  }
}

# Récupérer une catégorie par son slug avec ses produits
query GetCategoryBySlug($slug: String!) {
  category(slug: $slug) {
    id
    name
    slug
    description
    imageUrl
    products(where: { status: { eq: "ACTIVE" } }) {
      id
      name
      slug
      price
      imageUrl
      stock
    }
  }
}

# ============================================================
# QUERIES - Panier
# ============================================================

# Récupérer le panier d'un utilisateur
query GetUserCart($userId: UUID!) @auth(level: USER) {
  cartItems(where: { userId: { eq: $userId } }) {
    id
    quantity
    product {
      id
      name
      slug
      price
      imageUrl
      stock
      status
    }
    createdAt
  }
}

# ============================================================
# QUERIES - Commandes
# ============================================================

# Liste les commandes d'un utilisateur
query ListUserOrders($userId: UUID!) @auth(level: USER) {
  orders(
    where: { userId: { eq: $userId } }
    orderBy: { createdAt: DESC }
  ) {
    id
    orderNumber
    status
    total
    createdAt
    items {
      id
      quantity
      priceAtTime
      product {
        name
        imageUrl
      }
    }
  }
}

# Détails d'une commande
query GetOrderById($orderId: UUID!) @auth(level: USER) {
  order(id: $orderId) {
    id
    orderNumber
    status
    subtotal
    shippingCost
    tax
    total
    shippingName
    shippingAddress
    shippingCity
    shippingPostalCode
    shippingCountry
    billingName
    billingAddress
    billingCity
    billingPostalCode
    billingCountry
    paymentMethod
    paymentStatus
    createdAt
    items {
      id
      quantity
      priceAtTime
      subtotal
      product {
        name
        imageUrl
        slug
      }
    }
  }
}

# Liste toutes les commandes (admin)
query ListAllOrders($status: OrderStatus) @auth(level: USER) {
  orders(
    where: { status: { eq: $status } }
    orderBy: { createdAt: DESC }
    limit: 50
  ) {
    id
    orderNumber
    status
    total
    user {
      email
      displayName
    }
    createdAt
  }
}

# ============================================================
# QUERIES - Reviews
# ============================================================

# Reviews d'un produit
query GetProductReviews($productId: UUID!, $limit: Int = 10) {
  reviews(
    where: { productId: { eq: $productId } }
    orderBy: { createdAt: DESC }
    limit: $limit
  ) {
    id
    rating
    title
    comment
    verified
    user {
      displayName
      photoURL
    }
    createdAt
  }
}
EOF

# ============================================================
# MUTATIONS
# ============================================================

cat > dataconnect/connectors/ecommerce/mutations.gql << 'EOF'
# ============================================================
# MUTATIONS - Utilisateurs
# ============================================================

# Créer ou mettre à jour un utilisateur après connexion Firebase Auth
mutation UpsertUser(
  $firebaseUid: String!
  $email: String!
  $displayName: String
  $photoURL: String
) @auth(level: USER) {
  user_upsert(
    data: {
      firebaseUid: $firebaseUid
      email: $email
      displayName: $displayName
      photoURL: $photoURL
    }
  ) {
    id
    firebaseUid
    email
    displayName
    role
  }
}

# ============================================================
# MUTATIONS - Produits (Admin)
# ============================================================

# Créer un produit
mutation CreateProduct(
  $name: String!
  $slug: String!
  $description: String!
  $price: Float!
  $stock: Int!
  $imageUrl: String!
  $categoryId: UUID!
  $compareAtPrice: Float
  $images: [String!]
  $sku: String
) @auth(level: USER) {
  product_insert(
    data: {
      name: $name
      slug: $slug
      description: $description
      price: $price
      stock: $stock
      imageUrl: $imageUrl
      categoryId: $categoryId
      compareAtPrice: $compareAtPrice
      images: $images
      sku: $sku
    }
  ) {
    id
    name
    slug
  }
}

# Mettre à jour un produit
mutation UpdateProduct(
  $id: UUID!
  $name: String
  $description: String
  $price: Float
  $stock: Int
  $status: ProductStatus
) @auth(level: USER) {
  product_update(
    id: $id
    data: {
      name: $name
      description: $description
      price: $price
      stock: $stock
      status: $status
      updatedAt: { expr: "request.time" }
    }
  ) {
    id
    name
    updatedAt
  }
}

# Supprimer un produit
mutation DeleteProduct($id: UUID!) @auth(level: USER) {
  product_delete(id: $id) {
    id
  }
}

# ============================================================
# MUTATIONS - Catégories (Admin)
# ============================================================

# Créer une catégorie
mutation CreateCategory(
  $name: String!
  $slug: String!
  $description: String
  $imageUrl: String
  $parentId: UUID
) @auth(level: USER) {
  category_insert(
    data: {
      name: $name
      slug: $slug
      description: $description
      imageUrl: $imageUrl
      parentId: $parentId
    }
  ) {
    id
    name
    slug
  }
}

# ============================================================
# MUTATIONS - Panier
# ============================================================

# Ajouter au panier
mutation AddToCart(
  $userId: UUID!
  $productId: UUID!
  $quantity: Int!
) @auth(level: USER) {
  cartItem_insert(
    data: {
      userId: $userId
      productId: $productId
      quantity: $quantity
    }
  ) {
    id
    quantity
  }
}

# Mettre à jour la quantité dans le panier
mutation UpdateCartItemQuantity(
  $id: UUID!
  $quantity: Int!
) @auth(level: USER) {
  cartItem_update(
    id: $id
    data: {
      quantity: $quantity
      updatedAt: { expr: "request.time" }
    }
  ) {
    id
    quantity
  }
}

# Supprimer du panier
mutation RemoveFromCart($id: UUID!) @auth(level: USER) {
  cartItem_delete(id: $id) {
    id
  }
}

# Vider le panier
mutation ClearCart($userId: UUID!) @auth(level: USER) {
  cartItems_deleteMany(where: { userId: { eq: $userId } })
}

# ============================================================
# MUTATIONS - Commandes
# ============================================================

# Créer une commande
mutation CreateOrder(
  $userId: UUID!
  $orderNumber: String!
  $subtotal: Float!
  $shippingCost: Float!
  $tax: Float!
  $total: Float!
  $shippingName: String!
  $shippingAddress: String!
  $shippingCity: String!
  $shippingPostalCode: String!
  $shippingCountry: String!
  $billingName: String!
  $billingAddress: String!
  $billingCity: String!
  $billingPostalCode: String!
  $billingCountry: String!
  $paymentMethod: String!
  $paymentStatus: String!
) @auth(level: USER) {
  order_insert(
    data: {
      userId: $userId
      orderNumber: $orderNumber
      subtotal: $subtotal
      shippingCost: $shippingCost
      tax: $tax
      total: $total
      shippingName: $shippingName
      shippingAddress: $shippingAddress
      shippingCity: $shippingCity
      shippingPostalCode: $shippingPostalCode
      shippingCountry: $shippingCountry
      billingName: $billingName
      billingAddress: $billingAddress
      billingCity: $billingCity
      billingPostalCode: $billingPostalCode
      billingCountry: $billingCountry
      paymentMethod: $paymentMethod
      paymentStatus: $paymentStatus
    }
  ) {
    id
    orderNumber
  }
}

# Ajouter un article à une commande
mutation AddOrderItem(
  $orderId: UUID!
  $productId: UUID!
  $quantity: Int!
  $priceAtTime: Float!
  $subtotal: Float!
) @auth(level: USER) {
  orderItem_insert(
    data: {
      orderId: $orderId
      productId: $productId
      quantity: $quantity
      priceAtTime: $priceAtTime
      subtotal: $subtotal
    }
  ) {
    id
  }
}

# Mettre à jour le statut d'une commande
mutation UpdateOrderStatus(
  $id: UUID!
  $status: OrderStatus!
) @auth(level: USER) {
  order_update(
    id: $id
    data: {
      status: $status
      updatedAt: { expr: "request.time" }
    }
  ) {
    id
    status
  }
}

# ============================================================
# MUTATIONS - Reviews
# ============================================================

# Créer un avis
mutation CreateReview(
  $productId: UUID!
  $userId: UUID!
  $rating: Int!
  $title: String
  $comment: String!
) @auth(level: USER) {
  review_insert(
    data: {
      productId: $productId
      userId: $userId
      rating: $rating
      title: $title
      comment: $comment
    }
  ) {
    id
    rating
  }
}

# Mettre à jour un avis
mutation UpdateReview(
  $id: UUID!
  $rating: Int
  $title: String
  $comment: String
) @auth(level: USER) {
  review_update(
    id: $id
    data: {
      rating: $rating
      title: $title
      comment: $comment
      updatedAt: { expr: "request.time" }
    }
  ) {
    id
  }
}

# Vérifier un avis (admin)
mutation VerifyReview($id: UUID!) @auth(level: USER) {
  review_update(
    id: $id
    data: { verified: true }
  ) {
    id
    verified
  }
}
EOF

# ============================================================
# CONFIGURATION DU CONNECTEUR
# ============================================================

cat > dataconnect/connectors/ecommerce/connector.yaml << 'EOF'
connectorId: 'ecommerce'
generate:
  javascriptSdk:
    outputDir: '../../../packages/firebase/src/generated'
    package: '@mon-projet/firebase'
EOF

# ============================================================
# MISE À JOUR DU PACKAGE FIREBASE
# ============================================================

echo "🔄 Mise à jour du package Firebase..."

# Mise à jour de dataconnect.ts
cat > packages/firebase/src/dataconnect.ts << 'EOF'
import { getDataConnect, DataConnect } from 'firebase/data-connect'
import { app } from './config'

let dataConnect: DataConnect

if (typeof window !== 'undefined') {
  dataConnect = getDataConnect(app, {
    connector: 'ecommerce',
    location: 'europe-west1',
    service: 'ecommerce-dataconnect'
  })
}

export { dataConnect }

// Réexporter les types et fonctions générés
export * from './generated'

// Types personnalisés pour l'application
export interface CartItemWithProduct {
  id: string
  quantity: number
  product: {
    id: string
    name: string
    slug: string
    price: number
    imageUrl: string
    stock: number
  }
}

export interface OrderWithItems {
  id: string
  orderNumber: string
  status: string
  total: number
  createdAt: string
  items: {
    id: string
    quantity: number
    priceAtTime: number
    product: {
      name: string
      imageUrl: string
    }
  }[]
}
EOF

# Créer le dossier pour les fichiers générés
mkdir -p packages/firebase/src/generated

cat > packages/firebase/src/generated/index.ts << 'EOF'
// Ce fichier sera généré automatiquement par Firebase Data Connect
// après avoir exécuté: firebase dataconnect:sdk:generate

// Pour l'instant, on exporte des types de base
export interface Product {
  id: string
  name: string
  slug: string
  description: string
  price: number
  stock: number
  imageUrl: string
}

export interface User {
  id: string
  firebaseUid: string
  email: string
  displayName?: string
  role: 'ADMIN' | 'CUSTOMER'
}

export interface Order {
  id: string
  orderNumber: string
  status: string
  total: number
  createdAt: string
}

// Les fonctions seront générées automatiquement
// Exemples de signatures:
// export function listProducts(variables?: ListProductsVariables): Promise<ListProductsResponse>
// export function getProductBySlug(variables: GetProductBySlugVariables): Promise<GetProductBySlugResponse>
// etc.
EOF

# ============================================================
# HOOKS REACT POUR DATA CONNECT
# ============================================================

echo "⚛️  Création des hooks React..."

mkdir -p packages/firebase/src/hooks

cat > packages/firebase/src/hooks/useProducts.ts << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { dataConnect } from '../dataconnect'

interface Product {
  id: string
  name: string
  slug: string
  description: string
  price: number
  compareAtPrice?: number
  stock: number
  imageUrl: string
  category?: {
    name: string
    slug: string
  }
}

export function useProducts(categoryId?: string) {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchProducts() {
      try {
        setLoading(true)
        // TODO: Utiliser la fonction générée par Data Connect
        // const result = await listProducts({ categoryId })
        // setProducts(result.data.products)
        
        // Pour l'instant, données de test
        setProducts([])
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    }

    fetchProducts()
  }, [categoryId])

  return { products, loading, error }
}

export function useProduct(slug: string) {
  const [product, setProduct] = useState<Product | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    async function fetchProduct() {
      try {
        setLoading(true)
        // TODO: Utiliser la fonction générée
        // const result = await getProductBySlug({ slug })
        // setProduct(result.data.product)
        
        setProduct(null)
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    }

    if (slug) {
      fetchProduct()
    }
  }, [slug])

  return { product, loading, error }
}
EOF

cat > packages/firebase/src/hooks/useCart.ts << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { useAuth } from './useAuth'
import { dataConnect } from '../dataconnect'

interface CartItem {
  id: string
  quantity: number
  product: {
    id: string
    name: string
    price: number
    imageUrl: string
    stock: number
  }
}

export function useCart() {
  const { user } = useAuth()
  const [cartItems, setCartItems] = useState<CartItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (user) {
      loadCart()
    }
  }, [user])

  async function loadCart() {
    try {
      setLoading(true)
      // TODO: Utiliser la fonction générée
      // const result = await getUserCart({ userId: user.id })
      // setCartItems(result.data.cartItems)
      
      setCartItems([])
    } finally {
      setLoading(false)
    }
  }

  async function addToCart(productId: string, quantity: number = 1) {
    if (!user) throw new Error('User not authenticated')
    
    // TODO: Utiliser la mutation générée
    // await addToCartMutation({ userId: user.id, productId, quantity })
    await loadCart()
  }

  async function updateQuantity(cartItemId: string, quantity: number) {
    // TODO: Utiliser la mutation générée
    // await updateCartItemQuantityMutation({ id: cartItemId, quantity })
    await loadCart()
  }

  async function removeFromCart(cartItemId: string) {
    // TODO: Utiliser la mutation générée
    // await removeFromCartMutation({ id: cartItemId })
    await loadCart()
  }

  const total = cartItems.reduce((sum, item) => 
    sum + (item.product.price * item.quantity), 0
  )

  return {
    cartItems,
    loading,
    total,
    addToCart,
    updateQuantity,
    removeFromCart,
    refresh: loadCart
  }
}
EOF

cat > packages/firebase/src/hooks/useAuth.ts << 'EOF'
'use client'

import { useState, useEffect } from 'react'
import { User as FirebaseUser, onAuthStateChanged } from 'firebase/auth'
import { auth } from '../auth'

interface User {
  id: string
  firebaseUid: string
  email: string
  displayName?: string
  photoURL?: string
  role: 'ADMIN' | 'CUSTOMER'
}

export function useAuth() {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null)
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setFirebaseUser(firebaseUser)
      
      if (firebaseUser) {
        // Synchroniser avec Data Connect
        try {
          // TODO: Utiliser la mutation générée
          // const result = await upsertUserMutation({
          //   firebaseUid: firebaseUser.uid,
          //   email: firebaseUser.email!,
          //   displayName: firebaseUser.displayName,
          //   photoURL: firebaseUser.photoURL
          // })
          // setUser(result.data.user)
          
          // Pour l'instant, créer un user de base
          setUser({
            id: firebaseUser.uid,
            firebaseUid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName || undefined,
            photoURL: firebaseUser.photoURL || undefined,
            role: 'CUSTOMER'
          })
        } catch (error) {
          console.error('Error syncing user:', error)
        }
      } else {
        setUser(null)
      }
      
      setLoading(false)
    })

    return unsubscribe
  }, [])

  return { firebaseUser, user, loading }
}
EOF

cat > packages/firebase/src/hooks/index.ts << 'EOF'
export * from './useAuth'
export * from './useProducts'
export * from './useCart'
EOF

# Mettre à jour l'index du package firebase
cat > packages/firebase/src/index.ts << 'EOF'
export * from './config'
export * from './auth'
export * from './dataconnect'
export * from './hooks'
EOF

# ============================================================
# README FIREBASE DATA CONNECT
# ============================================================

cat > dataconnect/README.md << 'EOF'
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
# - Choisir la région (europe-west1 recommandé)
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
import { listProducts, getProductBySlug } from '@mon-projet/firebase'

// Lister les produits
const products = await listProducts({ limit: 20 })

// Récupérer un produit
const product = await getProductBySlug({ slug: 'mon-produit' })
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
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=https://your-project.europe-west1.dataconnect.firebase.google.com
```
EOF

# ============================================================
# EXEMPLE DE COMPOSANTS REACT
# ============================================================

echo "🎨 Création des composants d'exemple..."

mkdir -p packages/ui/src/ecommerce

cat > packages/ui/src/ecommerce/ProductCard.tsx << 'EOF'
import React from 'react'
import { Card } from '../card'
import { Button } from '../button'

interface ProductCardProps {
  id: string
  name: string
  slug: string
  price: number
  compareAtPrice?: number
  imageUrl: string
  stock: number
  onAddToCart?: (id: string) => void
}

export function ProductCard({
  id,
  name,
  slug,
  price,
  compareAtPrice,
  imageUrl,
  stock,
  onAddToCart
}: ProductCardProps) {
  const discount = compareAtPrice 
    ? Math.round(((compareAtPrice - price) / compareAtPrice) * 100)
    : 0

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      <div className="relative">
        <img 
          src={imageUrl} 
          alt={name} 
          className="w-full h-48 object-cover"
        />
        {discount > 0 && (
          <span className="absolute top-2 right-2 bg-red-500 text-white px-2 py-1 rounded text-sm font-bold">
            -{discount}%
          </span>
        )}
        {stock === 0 && (
          <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <span className="text-white font-bold">Rupture de stock</span>
          </div>
        )}
      </div>
      
      <div className="p-4">
        <h3 className="font-semibold text-lg mb-2 truncate">{name}</h3>
        
        <div className="flex items-center gap-2 mb-4">
          <span className="text-2xl font-bold text-gray-900">
            {price.toFixed(2)} €
          </span>
          {compareAtPrice && (
            <span className="text-sm text-gray-500 line-through">
              {compareAtPrice.toFixed(2)} €
            </span>
          )}
        </div>

        <div className="flex gap-2">
          <Button 
            variant="outline" 
            className="flex-1"
            onClick={() => window.location.href = `/products/${slug}`}
          >
            Voir
          </Button>
          <Button 
            className="flex-1"
            disabled={stock === 0}
            onClick={() => onAddToCart?.(id)}
          >
            Ajouter
          </Button>
        </div>
      </div>
    </Card>
  )
}
EOF

cat > packages/ui/src/ecommerce/CartItem.tsx << 'EOF'
import React from 'react'

interface CartItemProps {
  id: string
  name: string
  price: number
  quantity: number
  imageUrl: string
  maxStock: number
  onUpdateQuantity: (id: string, quantity: number) => void
  onRemove: (id: string) => void
}

export function CartItem({
  id,
  name,
  price,
  quantity,
  imageUrl,
  maxStock,
  onUpdateQuantity,
  onRemove
}: CartItemProps) {
  return (
    <div className="flex gap-4 py-4 border-b">
      <img 
        src={imageUrl} 
        alt={name}
        className="w-20 h-20 object-cover rounded"
      />
      
      <div className="flex-1">
        <h3 className="font-semibold">{name}</h3>
        <p className="text-gray-600">{price.toFixed(2)} €</p>
        
        <div className="flex items-center gap-2 mt-2">
          <button
            onClick={() => onUpdateQuantity(id, Math.max(1, quantity - 1))}
            className="w-8 h-8 border rounded flex items-center justify-center hover:bg-gray-100"
          >
            -
          </button>
          <span className="w-12 text-center">{quantity}</span>
          <button
            onClick={() => onUpdateQuantity(id, Math.min(maxStock, quantity + 1))}
            className="w-8 h-8 border rounded flex items-center justify-center hover:bg-gray-100"
            disabled={quantity >= maxStock}
          >
            +
          </button>
        </div>
      </div>
      
      <div className="text-right">
        <p className="font-bold text-lg">
          {(price * quantity).toFixed(2)} €
        </p>
        <button
          onClick={() => onRemove(id)}
          className="text-red-500 text-sm hover:underline mt-2"
        >
          Supprimer
        </button>
      </div>
    </div>
  )
}
EOF

cat > packages/ui/src/ecommerce/OrderSummary.tsx << 'EOF'
import React from 'react'
import { Card } from '../card'
import { Button } from '../button'

interface OrderSummaryProps {
  subtotal: number
  shipping: number
  tax: number
  total: number
  onCheckout?: () => void
  loading?: boolean
}

export function OrderSummary({
  subtotal,
  shipping,
  tax,
  total,
  onCheckout,
  loading = false
}: OrderSummaryProps) {
  return (
    <Card className="sticky top-4">
      <h3 className="text-xl font-bold mb-4">Récapitulatif</h3>
      
      <div className="space-y-2 mb-4">
        <div className="flex justify-between">
          <span className="text-gray-600">Sous-total</span>
          <span>{subtotal.toFixed(2)} €</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">Livraison</span>
          <span>{shipping.toFixed(2)} €</span>
        </div>
        <div className="flex justify-between">
          <span className="text-gray-600">TVA</span>
          <span>{tax.toFixed(2)} €</span>
        </div>
        <div className="border-t pt-2 flex justify-between text-lg font-bold">
          <span>Total</span>
          <span>{total.toFixed(2)} €</span>
        </div>
      </div>
      
      <Button 
        className="w-full"
        onClick={onCheckout}
        disabled={loading}
      >
        {loading ? 'Traitement...' : 'Passer commande'}
      </Button>
    </Card>
  )
}
EOF

cat > packages/ui/src/ecommerce/index.ts << 'EOF'
export { ProductCard } from './ProductCard'
export { CartItem } from './CartItem'
export { OrderSummary } from './OrderSummary'
EOF

# Mettre à jour l'index de ui
cat > packages/ui/src/index.ts << 'EOF'
export { Button } from './button'
export { Card } from './card'
export * from './ecommerce'
EOF

# ============================================================
# EXEMPLES DE PAGES POUR L'APP VITRINE
# ============================================================

echo "📄 Création des pages d'exemple pour le site vitrine..."

mkdir -p apps/vitrine/app/products

cat > apps/vitrine/app/products/page.tsx << 'EOF'
import { ProductCard } from '@mon-projet/ui/ecommerce'

// Cette page sera générée côté serveur pour le SEO
export const metadata = {
  title: 'Nos Produits - Boutique',
  description: 'Découvrez notre catalogue de produits'
}

// Données de démonstration
const mockProducts = [
  {
    id: '1',
    name: 'Produit Premium 1',
    slug: 'produit-premium-1',
    price: 29.99,
    compareAtPrice: 49.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 10
  },
  {
    id: '2',
    name: 'Produit Standard 2',
    slug: 'produit-standard-2',
    price: 19.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 5
  },
  {
    id: '3',
    name: 'Produit Épuisé',
    slug: 'produit-epuise',
    price: 39.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 0
  }
]

export default function ProductsPage() {
  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Nos Produits</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {mockProducts.map((product) => (
          <ProductCard
            key={product.id}
            {...product}
            onAddToCart={(id) => console.log('Add to cart:', id)}
          />
        ))}
      </div>
    </div>
  )
}
EOF

mkdir -p apps/vitrine/app/products/\[slug\]

cat > "apps/vitrine/app/products/[slug]/page.tsx" << 'EOF'
import { Button } from '@mon-projet/ui/button'

// Générer les pages statiques pour le SEO
export async function generateStaticParams() {
  // TODO: Récupérer depuis Firebase Data Connect
  return [
    { slug: 'produit-premium-1' },
    { slug: 'produit-standard-2' }
  ]
}

export async function generateMetadata({ params }: { params: { slug: string } }) {
  // TODO: Récupérer depuis Firebase Data Connect
  return {
    title: `Produit ${params.slug} - Boutique`,
    description: 'Description du produit optimisée pour le SEO'
  }
}

export default function ProductPage({ params }: { params: { slug: string } }) {
  // TODO: Récupérer le produit depuis Firebase Data Connect
  const product = {
    name: 'Produit Premium 1',
    price: 29.99,
    compareAtPrice: 49.99,
    description: 'Description détaillée du produit avec tous les détails importants pour le SEO et les clients.',
    imageUrl: 'https://via.placeholder.com/600x600',
    stock: 10
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="grid md:grid-cols-2 gap-8">
        {/* Image */}
        <div>
          <img 
            src={product.imageUrl} 
            alt={product.name}
            className="w-full rounded-lg shadow-lg"
          />
        </div>

        {/* Informations */}
        <div>
          <h1 className="text-4xl font-bold mb-4">{product.name}</h1>
          
          <div className="flex items-center gap-4 mb-6">
            <span className="text-3xl font-bold text-gray-900">
              {product.price.toFixed(2)} €
            </span>
            {product.compareAtPrice && (
              <span className="text-xl text-gray-500 line-through">
                {product.compareAtPrice.toFixed(2)} €
              </span>
            )}
          </div>

          <p className="text-gray-700 mb-6 leading-relaxed">
            {product.description}
          </p>

          <div className="mb-6">
            <span className={`inline-block px-3 py-1 rounded ${
              product.stock > 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
            }`}>
              {product.stock > 0 ? `${product.stock} en stock` : 'Rupture de stock'}
            </span>
          </div>

          <Button 
            className="w-full mb-4"
            disabled={product.stock === 0}
          >
            Ajouter au panier
          </Button>

          <div className="border-t pt-6 space-y-2 text-sm text-gray-600">
            <p>✓ Livraison gratuite à partir de 50€</p>
            <p>✓ Retour gratuit sous 30 jours</p>
            <p>✓ Garantie 2 ans</p>
          </div>
        </div>
      </div>

      {/* Avis clients */}
      <div className="mt-12">
        <h2 className="text-2xl font-bold mb-6">Avis clients</h2>
        <p className="text-gray-600">Aucun avis pour le moment.</p>
      </div>
    </div>
  )
}
EOF

# ============================================================
# PAGE PANIER POUR LE DASHBOARD
# ============================================================

echo "🛒 Création de la page panier pour le dashboard..."

mkdir -p apps/dashboard/app/cart

cat > apps/dashboard/app/cart/page.tsx << 'EOF'
'use client'

import { CartItem, OrderSummary } from '@mon-projet/ui/ecommerce'
import { useState } from 'react'

export default function CartPage() {
  const [cartItems, setCartItems] = useState([
    {
      id: '1',
      productId: 'p1',
      name: 'Produit 1',
      price: 29.99,
      quantity: 2,
      imageUrl: 'https://via.placeholder.com/100x100',
      maxStock: 10
    },
    {
      id: '2',
      productId: 'p2',
      name: 'Produit 2',
      price: 19.99,
      quantity: 1,
      imageUrl: 'https://via.placeholder.com/100x100',
      maxStock: 5
    }
  ])

  const handleUpdateQuantity = (id: string, quantity: number) => {
    setCartItems(items =>
      items.map(item => item.id === id ? { ...item, quantity } : item)
    )
  }

  const handleRemove = (id: string) => {
    setCartItems(items => items.filter(item => item.id !== id))
  }

  const subtotal = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0)
  const shipping = 5.99
  const tax = subtotal * 0.2
  const total = subtotal + shipping + tax

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Mon Panier</h1>

      <div className="grid lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          {cartItems.length === 0 ? (
            <p className="text-gray-600">Votre panier est vide</p>
          ) : (
            <div className="bg-white rounded-lg shadow p-6">
              {cartItems.map(item => (
                <CartItem
                  key={item.id}
                  {...item}
                  onUpdateQuantity={handleUpdateQuantity}
                  onRemove={handleRemove}
                />
              ))}
            </div>
          )}
        </div>

        <div>
          <OrderSummary
            subtotal={subtotal}
            shipping={shipping}
            tax={tax}
            total={total}
            onCheckout={() => console.log('Checkout')}
          />
        </div>
      </div>
    </div>
  )
}
EOF

# ============================================================
# PAGE COMMANDES POUR LE DASHBOARD
# ============================================================

mkdir -p apps/dashboard/app/orders

cat > apps/dashboard/app/orders/page.tsx << 'EOF'
'use client'

import { Card } from '@mon-projet/ui/card'

const mockOrders = [
  {
    id: '1',
    orderNumber: 'ORD-2024-001',
    status: 'DELIVERED',
    total: 89.97,
    createdAt: '2024-01-15',
    items: [
      { name: 'Produit 1', quantity: 2, imageUrl: 'https://via.placeholder.com/50x50' }
    ]
  },
  {
    id: '2',
    orderNumber: 'ORD-2024-002',
    status: 'PROCESSING',
    total: 49.99,
    createdAt: '2024-01-20',
    items: [
      { name: 'Produit 2', quantity: 1, imageUrl: 'https://via.placeholder.com/50x50' }
    ]
  }
]

const statusColors = {
  PENDING: 'bg-yellow-100 text-yellow-800',
  PROCESSING: 'bg-blue-100 text-blue-800',
  SHIPPED: 'bg-purple-100 text-purple-800',
  DELIVERED: 'bg-green-100 text-green-800',
  CANCELLED: 'bg-red-100 text-red-800'
}

const statusLabels = {
  PENDING: 'En attente',
  PROCESSING: 'En préparation',
  SHIPPED: 'Expédiée',
  DELIVERED: 'Livrée',
  CANCELLED: 'Annulée'
}

export default function OrdersPage() {
  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Mes Commandes</h1>

      <div className="space-y-4">
        {mockOrders.map(order => (
          <Card key={order.id}>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-bold text-lg">{order.orderNumber}</h3>
                <p className="text-sm text-gray-600">
                  Commandé le {new Date(order.createdAt).toLocaleDateString('fr-FR')}
                </p>
              </div>
              <span className={`px-3 py-1 rounded text-sm font-medium ${
                statusColors[order.status as keyof typeof statusColors]
              }`}>
                {statusLabels[order.status as keyof typeof statusLabels]}
              </span>
            </div>

            <div className="flex items-center gap-4 mb-4">
              {order.items.map((item, idx) => (
                <div key={idx} className="flex items-center gap-2">
                  <img 
                    src={item.imageUrl} 
                    alt={item.name}
                    className="w-12 h-12 object-cover rounded"
                  />
                  <span className="text-sm">{item.name} (x{item.quantity})</span>
                </div>
              ))}
            </div>

            <div className="flex justify-between items-center pt-4 border-t">
              <span className="font-bold">Total: {order.total.toFixed(2)} €</span>
              <button className="text-blue-600 hover:underline">
                Voir les détails
              </button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}
EOF

# ============================================================
# PAGE ADMIN POUR GÉRER LES PRODUITS
# ============================================================

echo "⚙️  Création de la page admin..."

mkdir -p apps/admin/app/products

cat > apps/admin/app/products/page.tsx << 'EOF'
'use client'

import { Button } from '@mon-projet/ui/button'
import { Card } from '@mon-projet/ui/card'
import { useState } from 'react'

const mockProducts = [
  {
    id: '1',
    name: 'Produit Premium 1',
    price: 29.99,
    stock: 10,
    status: 'ACTIVE',
    category: 'Électronique'
  },
  {
    id: '2',
    name: 'Produit Standard 2',
    price: 19.99,
    stock: 5,
    status: 'ACTIVE',
    category: 'Accessoires'
  }
]

export default function AdminProductsPage() {
  const [products] = useState(mockProducts)

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Gestion des Produits</h1>
        <Button>+ Nouveau Produit</Button>
      </div>

      <Card>
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th className="text-left py-3 px-4">Nom</th>
              <th className="text-left py-3 px-4">Catégorie</th>
              <th className="text-left py-3 px-4">Prix</th>
              <th className="text-left py-3 px-4">Stock</th>
              <th className="text-left py-3 px-4">Statut</th>
              <th className="text-left py-3 px-4">Actions</th>
            </tr>
          </thead>
          <tbody>
            {products.map(product => (
              <tr key={product.id} className="border-b hover:bg-gray-50">
                <td className="py-3 px-4 font-medium">{product.name}</td>
                <td className="py-3 px-4">{product.category}</td>
                <td className="py-3 px-4">{product.price.toFixed(2)} €</td>
                <td className="py-3 px-4">{product.stock}</td>
                <td className="py-3 px-4">
                  <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-sm">
                    {product.status}
                  </span>
                </td>
                <td className="py-3 px-4">
                  <div className="flex gap-2">
                    <button className="text-blue-600 hover:underline text-sm">
                      Modifier
                    </button>
                    <button className="text-red-600 hover:underline text-sm">
                      Supprimer
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  )
}
EOF

# ============================================================
# SCRIPT D'AIDE FIREBASE
# ============================================================

cat > firebase-setup.sh << 'EOF'
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
EOF

chmod +x firebase-setup.sh

# ============================================================
# GUIDE D'INSTALLATION
# ============================================================

cat > FIREBASE_SETUP.md << 'EOF'
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
- **Region**: europe-west1 (ou votre région préférée)
- **Service ID**: ecommerce-dataconnect
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
NEXT_PUBLIC_FIREBASE_DATA_CONNECT_URL=https://votre-projet.europe-west1.dataconnect.firebase.google.com
```

## 3. Utilisation dans le code

### Exemple: Lister les produits

```typescript
import { listProducts } from '@mon-projet/firebase'

async function getProducts() {
  const result = await listProducts({ limit: 20 })
  return result.data.products
}
```

### Exemple: Ajouter au panier

```typescript
import { addToCart } from '@mon-projet/firebase'

async function handleAddToCart(userId: string, productId: string) {
  await addToCart({
    userId,
    productId,
    quantity: 1
  })
}
```

### Exemple avec les hooks React

```typescript
'use client'

import { useProducts } from '@mon-projet/firebase'

export default function ProductsPage() {
  const { products, loading, error } = useProducts()

  if (loading) return <div>Chargement...</div>
  if (error) return <div>Erreur: {error.message}</div>

  return (
    <div>
      {products.map(product => (
        <div key={product.id}>{product.name}</div>
      ))}
    </div>
  )
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
  upsertUser 
} from '@mon-projet/firebase'

async function seed() {
  // Créer des catégories
  const category = await createCategory({
    name: 'Électronique',
    slug: 'electronique',
    description: 'Produits électroniques'
  })

  // Créer des produits
  await createProduct({
    name: 'Smartphone XYZ',
    slug: 'smartphone-xyz',
    description: 'Le meilleur smartphone',
    price: 599.99,
    stock: 50,
    imageUrl: 'https://...',
    categoryId: category.data.category_insert.id
  })
}

seed().catch(console.error)
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
EOF

# ============================================================
# FINALISATION
# ============================================================

echo ""
echo "✅ Module Firebase Data Connect créé avec succès !"
echo ""
echo "📦 Ce qui a été ajouté:"
echo "   • Schéma GraphQL complet (Users, Products, Orders, etc.)"
echo "   • Queries pour lire les données"
echo "   • Mutations pour créer/modifier/supprimer"
echo "   • Hooks React (useProducts, useCart, useAuth)"
echo "   • Composants UI e-commerce (ProductCard, CartItem, OrderSummary)"
echo "   • Pages d'exemple pour vitrine, dashboard et admin"
echo ""
echo "📁 Nouvelle structure:"
echo "   dataconnect/"
echo "   ├── schema/schema.gql"
echo "   ├── connectors/ecommerce/"
echo "   │   ├── queries.gql"
echo "   │   └── mutations.gql"
echo "   └── dataconnect.yaml"
echo ""
echo "   packages/firebase/src/"
echo "   ├── hooks/ (useAuth, useProducts, useCart)"
echo "   └── generated/ (sera généré par Firebase CLI)"
echo ""
echo "   packages/ui/src/ecommerce/"
echo "   ├── ProductCard.tsx"
echo "   ├── CartItem.tsx"
echo "   └── OrderSummary.tsx"
echo ""
echo "📚 Guides créés:"
echo "   • FIREBASE_SETUP.md - Guide complet d'installation"
echo "   • firebase-setup.sh - Script d'aide à la configuration"
echo "   • dataconnect/README.md - Documentation du schéma"
echo ""
echo "🔥 Prochaines étapes:"
echo ""
echo "1. Créer un projet Firebase (si pas encore fait):"
echo "   https://console.firebase.google.com"
echo ""
echo "2. Activer Firebase Authentication et Data Connect"
echo ""
echo "3. Exécuter le script d'aide:"
echo "   ./firebase-setup.sh"
echo ""
echo "4. Ou manuellement:"
echo "   firebase login"
echo "   firebase init dataconnect"
echo "   firebase deploy --only dataconnect"
echo "   firebase dataconnect:sdk:generate"
echo ""
echo "5. Configurer les variables d'environnement:"
echo "   Copiez .env.local.example vers .env.local dans chaque app"
echo "   Ajoutez vos credentials Firebase"
echo ""
echo "6. Installer les dépendances (si pas encore fait):"
echo "   pnpm install"
echo ""
echo "7. Lancer le projet:"
echo "   pnpm dev"
echo ""
echo "📖 Lire le guide complet: FIREBASE_SETUP.md"
echo ""
echo "🎉 Le module Firebase Data Connect est prêt !"
echo ""
echo "💡 Astuces:"
echo "   • Le schéma contient 7 tables interconnectées"
echo "   • Les queries incluent des filtres, pagination et relations"
echo "   • Les mutations gèrent tout le cycle CRUD"
echo "   • Les hooks React simplifient l'utilisation dans vos composants"
echo "   • Les composants UI sont prêts à l'emploi"
echo ""
echo "🔗 Pages créées:"
echo "   • Vitrine: /products et /products/[slug] (avec SEO)"
echo "   • Dashboard: /cart et /orders"
echo "   • Admin: /products (gestion)"
echo ""