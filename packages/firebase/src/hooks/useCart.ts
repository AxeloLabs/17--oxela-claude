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
