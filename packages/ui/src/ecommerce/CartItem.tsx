import React from 'react'

interface CartItemProps {
  id: string
  name: string
  price: number
  quantity: number
  imageUrl: string
  maxStock: number
  onUpdateQuantity: (id: string, quantity: number) => void
  onRemove: (id: string) => void
}

export function CartItem({
  id,
  name,
  price,
  quantity,
  imageUrl,
  maxStock,
  onUpdateQuantity,
  onRemove
}: CartItemProps) {
  return (
    <div className="flex gap-4 py-4 border-b">
      <img 
        src={imageUrl} 
        alt={name}
        className="w-20 h-20 object-cover rounded"
      />
      
      <div className="flex-1">
        <h3 className="font-semibold">{name}</h3>
        <p className="text-gray-600">{price.toFixed(2)} €</p>
        
        <div className="flex items-center gap-2 mt-2">
          <button
            onClick={() => onUpdateQuantity(id, Math.max(1, quantity - 1))}
            className="w-8 h-8 border rounded flex items-center justify-center hover:bg-gray-100"
          >
            -
          </button>
          <span className="w-12 text-center">{quantity}</span>
          <button
            onClick={() => onUpdateQuantity(id, Math.min(maxStock, quantity + 1))}
            className="w-8 h-8 border rounded flex items-center justify-center hover:bg-gray-100"
            disabled={quantity >= maxStock}
          >
            +
          </button>
        </div>
      </div>
      
      <div className="text-right">
        <p className="font-bold text-lg">
          {(price * quantity).toFixed(2)} €
        </p>
        <button
          onClick={() => onRemove(id)}
          className="text-red-500 text-sm hover:underline mt-2"
        >
          Supprimer
        </button>
      </div>
    </div>
  )
}
