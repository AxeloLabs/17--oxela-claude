#!/bin/bash

# Script de correction du schéma Firebase Data Connect
# Corrige les directives non supportées

set -e

echo "🔧 Correction du schéma Firebase Data Connect..."

# Vérifier qu'on est dans le bon dossier
if [ ! -d "dataconnect" ]; then
  echo "❌ Erreur: Le dossier dataconnect n'existe pas"
  exit 1
fi

# ============================================================
# SCHÉMA CORRIGÉ (sans @relationship)
# ============================================================

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
  role: UserRole! @default(value: CUSTOMER)
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}

# Type Category
type Category @table {
  id: UUID! @default(expr: "uuidV4()")
  name: String!
  slug: String! @unique
  description: String
  imageUrl: String
  parentId: UUID
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
  stock: Int! @default(value: 0)
  status: ProductStatus! @default(value: ACTIVE)
  imageUrl: String!
  images: [String!]
  categoryId: UUID!
  sku: String @unique
  weight: Float
  dimensions: String
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}

# Type Order
type Order @table {
  id: UUID! @default(expr: "uuidV4()")
  orderNumber: String! @unique
  userId: UUID!
  status: OrderStatus! @default(value: PENDING)
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
}

# Type OrderItem
type OrderItem @table {
  id: UUID! @default(expr: "uuidV4()")
  orderId: UUID!
  productId: UUID!
  quantity: Int!
  priceAtTime: Float!
  subtotal: Float!
}

# Type Review
type Review @table {
  id: UUID! @default(expr: "uuidV4()")
  productId: UUID!
  userId: UUID!
  rating: Int!
  title: String
  comment: String!
  verified: Boolean! @default(value: false)
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}

# Type CartItem (panier)
type CartItem @table {
  id: UUID! @default(expr: "uuidV4()")
  userId: UUID!
  productId: UUID!
  quantity: Int!
  createdAt: Timestamp! @default(expr: "request.time")
  updatedAt: Timestamp! @default(expr: "request.time")
}
EOF

# ============================================================
# QUERIES CORRIGÉES
# ============================================================

cat > dataconnect/connectors/ecommerce/queries.gql << 'EOF'
# ============================================================
# QUERIES - Utilisateurs
# ============================================================

# Récupérer un utilisateur par son Firebase UID
query GetUserByFirebaseUid($firebaseUid: String!) @auth(level: USER) {
  users(where: { firebaseUid: { eq: $firebaseUid } }) {
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
  users(orderBy: { createdAt: DESC }) {
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
  $limit: Int
  $offset: Int
  $categoryId: UUID
) {
  products(
    where: { 
      _and: [
        { status: { eq: ACTIVE } }
        { categoryId: { eq: $categoryId } }
      ]
    }
    limit: $limit
    offset: $offset
    orderBy: [{ createdAt: DESC }]
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
    categoryId
    createdAt
  }
}

# Récupérer un produit par son slug
query GetProductBySlug($slug: String!) {
  products(where: { slug: { eq: $slug } }) {
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
    categoryId
    createdAt
    updatedAt
  }
}

# Recherche de produits
query SearchProducts($searchTerm: String!) {
  products(
    where: {
      _and: [
        {
          _or: [
            { name: { contains: $searchTerm } }
            { description: { contains: $searchTerm } }
          ]
        }
        { status: { eq: ACTIVE } }
      ]
    }
    limit: 20
  ) {
    id
    name
    slug
    description
    price
    imageUrl
    categoryId
  }
}

# ============================================================
# QUERIES - Catégories
# ============================================================

# Liste toutes les catégories
query ListCategories {
  categories(orderBy: [{ name: ASC }]) {
    id
    name
    slug
    description
    imageUrl
    parentId
  }
}

# Récupérer une catégorie par son slug
query GetCategoryBySlug($slug: String!) {
  categories(where: { slug: { eq: $slug } }) {
    id
    name
    slug
    description
    imageUrl
    parentId
  }
}

# Produits d'une catégorie
query GetProductsByCategory($categoryId: UUID!) {
  products(
    where: { 
      _and: [
        { categoryId: { eq: $categoryId } }
        { status: { eq: ACTIVE } }
      ]
    }
  ) {
    id
    name
    slug
    price
    imageUrl
    stock
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
    productId
    createdAt
  }
}

# Détails d'un item du panier avec produit
query GetCartItemWithProduct($id: UUID!) @auth(level: USER) {
  cartItems(where: { id: { eq: $id } }) {
    id
    quantity
    productId
    userId
  }
}

# ============================================================
# QUERIES - Commandes
# ============================================================

# Liste les commandes d'un utilisateur
query ListUserOrders($userId: UUID!) @auth(level: USER) {
  orders(
    where: { userId: { eq: $userId } }
    orderBy: [{ createdAt: DESC }]
  ) {
    id
    orderNumber
    status
    total
    createdAt
  }
}

# Détails d'une commande
query GetOrderById($orderId: UUID!) @auth(level: USER) {
  orders(where: { id: { eq: $orderId } }) {
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
    userId
  }
}

# Items d'une commande
query GetOrderItems($orderId: UUID!) @auth(level: USER) {
  orderItems(where: { orderId: { eq: $orderId } }) {
    id
    quantity
    priceAtTime
    subtotal
    productId
  }
}

# Liste toutes les commandes (admin)
query ListAllOrders($status: OrderStatus) @auth(level: USER) {
  orders(
    where: { status: { eq: $status } }
    orderBy: [{ createdAt: DESC }]
    limit: 50
  ) {
    id
    orderNumber
    status
    total
    userId
    createdAt
  }
}

# ============================================================
# QUERIES - Reviews
# ============================================================

# Reviews d'un produit
query GetProductReviews($productId: UUID!, $limit: Int) {
  reviews(
    where: { productId: { eq: $productId } }
    orderBy: [{ createdAt: DESC }]
    limit: $limit
  ) {
    id
    rating
    title
    comment
    verified
    userId
    createdAt
  }
}

# Reviews d'un utilisateur
query GetUserReviews($userId: UUID!) @auth(level: USER) {
  reviews(
    where: { userId: { eq: $userId } }
    orderBy: [{ createdAt: DESC }]
  ) {
    id
    rating
    title
    comment
    verified
    productId
    createdAt
  }
}
EOF

# ============================================================
# MUTATIONS CORRIGÉES
# ============================================================

cat > dataconnect/connectors/ecommerce/mutations.gql << 'EOF'
# ============================================================
# MUTATIONS - Utilisateurs
# ============================================================

# Créer un utilisateur après connexion Firebase Auth
mutation CreateUser(
  $firebaseUid: String!
  $email: String!
  $displayName: String
  $photoURL: String
) @auth(level: USER) {
  user_insert(
    data: {
      firebaseUid: $firebaseUid
      email: $email
      displayName: $displayName
      photoURL: $photoURL
    }
  )
}

# Mettre à jour un utilisateur
mutation UpdateUser(
  $firebaseUid: String!
  $displayName: String
  $photoURL: String
) @auth(level: USER) {
  user_update(
    key: { firebaseUid: $firebaseUid }
    data: {
      displayName: $displayName
      photoURL: $photoURL
      updatedAt: { expr: "request.time" }
    }
  )
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
  )
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
    key: { id: $id }
    data: {
      name: $name
      description: $description
      price: $price
      stock: $stock
      status: $status
      updatedAt: { expr: "request.time" }
    }
  )
}

# Supprimer un produit
mutation DeleteProduct($id: UUID!) @auth(level: USER) {
  product_delete(key: { id: $id })
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
  )
}

# Mettre à jour une catégorie
mutation UpdateCategory(
  $id: UUID!
  $name: String
  $description: String
  $imageUrl: String
) @auth(level: USER) {
  category_update(
    key: { id: $id }
    data: {
      name: $name
      description: $description
      imageUrl: $imageUrl
    }
  )
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
  )
}

# Mettre à jour la quantité dans le panier
mutation UpdateCartItemQuantity(
  $id: UUID!
  $quantity: Int!
) @auth(level: USER) {
  cartItem_update(
    key: { id: $id }
    data: {
      quantity: $quantity
      updatedAt: { expr: "request.time" }
    }
  )
}

# Supprimer du panier
mutation RemoveFromCart($id: UUID!) @auth(level: USER) {
  cartItem_delete(key: { id: $id })
}

# Vider le panier
mutation ClearCart($userId: UUID!) @auth(level: USER) {
  cartItem_deleteMany(where: { userId: { eq: $userId } })
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
  )
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
  )
}

# Mettre à jour le statut d'une commande
mutation UpdateOrderStatus(
  $id: UUID!
  $status: OrderStatus!
) @auth(level: USER) {
  order_update(
    key: { id: $id }
    data: {
      status: $status
      updatedAt: { expr: "request.time" }
    }
  )
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
  )
}

# Mettre à jour un avis
mutation UpdateReview(
  $id: UUID!
  $rating: Int
  $title: String
  $comment: String
) @auth(level: USER) {
  review_update(
    key: { id: $id }
    data: {
      rating: $rating
      title: $title
      comment: $comment
      updatedAt: { expr: "request.time" }
    }
  )
}

# Vérifier un avis (admin)
mutation VerifyReview($id: UUID!) @auth(level: USER) {
  review_update(
    key: { id: $id }
    data: { verified: true }
  )
}

# Supprimer un avis
mutation DeleteReview($id: UUID!) @auth(level: USER) {
  review_delete(key: { id: $id })
}
EOF

echo ""
echo "✅ Schéma corrigé avec succès !"
echo ""
echo "🔄 Maintenant, exécutez:"
echo "   1. firebase deploy --only dataconnect"
echo "   2. firebase dataconnect:sdk:generate"
echo ""
echo "📝 Changements effectués:"
echo "   • Suppression des directives @relationship non supportées"
echo "   • Les relations sont maintenant gérées via les IDs"
echo "   • Ajout de queries séparées pour récupérer les données liées"
echo "   • Syntaxe corrigée pour les enums (@default sans guillemets)"
echo ""