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
