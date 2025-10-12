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
