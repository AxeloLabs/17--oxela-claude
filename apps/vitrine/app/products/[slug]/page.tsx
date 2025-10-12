import { Button } from '@mon-projet/ui/button'

// Générer les pages statiques pour le SEO
export async function generateStaticParams() {
  // TODO: Récupérer depuis Firebase Data Connect
  return [
    { slug: 'produit-premium-1' },
    { slug: 'produit-standard-2' }
  ]
}

export async function generateMetadata({ params }: { params: { slug: string } }) {
  // TODO: Récupérer depuis Firebase Data Connect
  return {
    title: `Produit ${params.slug} - Boutique`,
    description: 'Description du produit optimisée pour le SEO'
  }
}

export default function ProductPage({ params }: { params: { slug: string } }) {
  // TODO: Récupérer le produit depuis Firebase Data Connect
  const product = {
    name: 'Produit Premium 1',
    price: 29.99,
    compareAtPrice: 49.99,
    description: 'Description détaillée du produit avec tous les détails importants pour le SEO et les clients.',
    imageUrl: 'https://via.placeholder.com/600x600',
    stock: 10
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="grid md:grid-cols-2 gap-8">
        {/* Image */}
        <div>
          <img 
            src={product.imageUrl} 
            alt={product.name}
            className="w-full rounded-lg shadow-lg"
          />
        </div>

        {/* Informations */}
        <div>
          <h1 className="text-4xl font-bold mb-4">{product.name}</h1>
          
          <div className="flex items-center gap-4 mb-6">
            <span className="text-3xl font-bold text-gray-900">
              {product.price.toFixed(2)} €
            </span>
            {product.compareAtPrice && (
              <span className="text-xl text-gray-500 line-through">
                {product.compareAtPrice.toFixed(2)} €
              </span>
            )}
          </div>

          <p className="text-gray-700 mb-6 leading-relaxed">
            {product.description}
          </p>

          <div className="mb-6">
            <span className={`inline-block px-3 py-1 rounded ${
              product.stock > 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
            }`}>
              {product.stock > 0 ? `${product.stock} en stock` : 'Rupture de stock'}
            </span>
          </div>

          <Button 
            className="w-full mb-4"
            disabled={product.stock === 0}
          >
            Ajouter au panier
          </Button>

          <div className="border-t pt-6 space-y-2 text-sm text-gray-600">
            <p>✓ Livraison gratuite à partir de 50€</p>
            <p>✓ Retour gratuit sous 30 jours</p>
            <p>✓ Garantie 2 ans</p>
          </div>
        </div>
      </div>

      {/* Avis clients */}
      <div className="mt-12">
        <h2 className="text-2xl font-bold mb-6">Avis clients</h2>
        <p className="text-gray-600">Aucun avis pour le moment.</p>
      </div>
    </div>
  )
}
