import { create } from 'zustand'
import type { User } from '@supabase/supabase-js'
import { authService, type UserProfile } from '../services/authService'
import { supabase } from '../lib/supabase'

interface AuthState {
  user: User | null
  profile: UserProfile | null
  loading: boolean
  initialized: boolean
  setUser: (user: User | null, profile: UserProfile | null) => void
  initialize: () => Promise<void>
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

export const useAuth = create<AuthState>((set) => ({
  user: null,
  profile: null,
  loading: true,
  initialized: false,
  setUser: (user, profile) => set({ user, profile, loading: false }),
  initialize: async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.user) {
        const profile = await authService.getProfile(session.user.id)
        set({ user: session.user, profile, loading: false, initialized: true })
      } else {
        set({ user: null, profile: null, loading: false, initialized: true })
      }
    } catch (error) {
      console.error('Auth initialization error:', error)
      set({ user: null, profile: null, loading: false, initialized: true })
    }

    // Listen for auth changes
    supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session?.user) {
        const profile = await authService.getProfile(session.user.id)
        set({ user: session.user, profile, loading: false })
      } else if (event === 'SIGNED_OUT') {
        set({ user: null, profile: null, loading: false })
      }
    })
  },
  signIn: async (email, password) => {
    await authService.signIn(email, password)
    // Profile will be set by the onAuthStateChange listener
  },
  signOut: async () => {
    await authService.signOut()
    set({ user: null, profile: null })
  }
}))
