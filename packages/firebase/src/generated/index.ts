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
