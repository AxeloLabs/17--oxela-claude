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
