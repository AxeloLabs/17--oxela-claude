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
-