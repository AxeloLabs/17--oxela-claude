import { ProductCard } from '@mon-projet/ui/ecommerce'

// Cette page sera générée côté serveur pour le SEO
export const metadata = {
  title: 'Nos Produits - Boutique',
  description: 'Découvrez notre catalogue de produits'
}

// Données de démonstration
const mockProducts = [
  {
    id: '1',
    name: 'Produit Premium 1',
    slug: 'produit-premium-1',
    price: 29.99,
    compareAtPrice: 49.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 10
  },
  {
    id: '2',
    name: 'Produit Standard 2',
    slug: 'produit-standard-2',
    price: 19.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 5
  },
  {
    id: '3',
    name: 'Produit Épuisé',
    slug: 'produit-epuise',
    price: 39.99,
    imageUrl: 'https://via.placeholder.com/300x300',
    stock: 0
  }
]

export default function ProductsPage() {
  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8">Nos Produits</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {mockProducts.map((product) => (
          <ProductCard
            key={product.id}
            {...product}
            onAddToCart={(id) => console.log('Add to cart:', id)}
          />
        ))}
      </div>
    </div>
  )
}
