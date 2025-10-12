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
