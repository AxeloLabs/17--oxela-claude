import { Button } from '@mon-projet/ui/button'

export default function HomePage() {
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-blue-600 to-purple-700 text-white py-20">
        <div className="max-w-6xl mx-auto px-4">
          <h1 className="text-5xl font-bold mb-6">
            Bienvenue sur Notre Site
          </h1>
          <p className="text-xl mb-8 max-w-2xl">
            Découvrez nos services exceptionnels et transformez votre business 
            avec nos solutions innovantes.
          </p>
          <Button className="bg-white text-blue-600 hover:bg-gray-100">
            En savoir plus
          </Button>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">
            Nos Services
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            {[1, 2, 3].map((i) => (
              <div key={i} className="p-6 border rounded-lg shadow-sm">
                <h3 className="text-xl font-semibold mb-3">Service {i}</h3>
                <p className="text-gray-600">
                  Description de votre service avec des mots-clés pertinents 
                  pour le SEO.
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </main>
  )
}
