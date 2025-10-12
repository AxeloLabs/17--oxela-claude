'use client'

import { useState, useEffect } from 'react'
import { User as FirebaseUser, onAuthStateChanged } from 'firebase/auth'
import { auth } from '../auth'

interface User {
  id: string
  firebaseUid: string
  email: string
  displayName?: string
  photoURL?: string
  role: 'ADMIN' | 'CUSTOMER'
}

export function useAuth() {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null)
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setFirebaseUser(firebaseUser)
      
      if (firebaseUser) {
        // Synchroniser avec Data Connect
        try {
          // TODO: Utiliser la mutation générée
          // const result = await upsertUserMutation({
          //   firebaseUid: firebaseUser.uid,
          //   email: firebaseUser.email!,
          //   displayName: firebaseUser.displayName,
          //   photoURL: firebaseUser.photoURL
          // })
          // setUser(result.data.user)
          
          // Pour l'instant, créer un user de base
          setUser({
            id: firebaseUser.uid,
            firebaseUid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName || undefined,
            photoURL: firebaseUser.photoURL || undefined,
            role: 'CUSTOMER'
          })
        } catch (error) {
          console.error('Error syncing user:', error)
        }
      } else {
        setUser(null)
      }
      
      setLoading(false)
    })

    return unsubscribe
  }, [])

  return { firebaseUser, user, loading }
}
