import { getDataConnect, DataConnect } from 'firebase/data-connect'
import { app } from './config'

let dataConnect: DataConnect

if (typeof window !== 'undefined') {
  dataConnect = getDataConnect(app, {
    connector: 'your-connector-name',
    location: 'europe-west1',
    service: 'your-service-id'
  })
}

export { dataConnect }

// Types d'exemple - à adapter selon votre schéma
export interface User {
  id: string
  email: string
  name: string
  createdAt: string
}

// Fonctions helpers d'exemple
export async function getUsers(): Promise<User[]> {
  // TODO: Implémentation avec Firebase Data Connect
  return []
}

export async function getUserById(id: string): Promise<User | null> {
  // TODO: Implémentation avec Firebase Data Connect
  return null
}
