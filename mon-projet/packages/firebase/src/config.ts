import { initializeApp, getApps, FirebaseApp } from 'firebase/app'

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
}

let app: FirebaseApp

if (typeof window !== 'undefined' && !getApps().length) {
  app = initializeApp(firebaseConfig)
}

export { app }
export { firebaseConfig }
