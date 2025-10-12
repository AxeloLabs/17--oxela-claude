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
