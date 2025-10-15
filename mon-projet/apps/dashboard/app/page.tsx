import { Button } from '@mon-projet/ui/button'

export default function DashboardPage() {
  return (
    <main className="min-h-screen p-8 bg-gray-50">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Dashboard Utilisateur</h1>
        <p className="text-gray-600 mb-6">Bienvenue sur votre espace personnel.</p>
        <Button>Mon Action</Button>
      </div>
    </main>
  )
}
