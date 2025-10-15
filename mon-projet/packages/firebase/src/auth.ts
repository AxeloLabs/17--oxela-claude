import { getAuth, Auth } from 'firebase/auth'
import { app } from './config'

let auth: Auth

if (typeof window !== 'undefined') {
  auth = getAuth(app)
}

export { auth }
