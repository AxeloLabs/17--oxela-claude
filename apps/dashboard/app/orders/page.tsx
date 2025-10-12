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
