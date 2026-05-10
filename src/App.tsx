import { Routes, Route, Navigate } from 'react-router-dom'
import { useEffect } from 'react'
import { useAuth } from './store/useAuth'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import LandingPage from './pages/LandingPage'
import ProtectedRoute from './components/auth/ProtectedRoute'
import DashboardLayout from './components/layout/DashboardLayout'

// Page Components
import OverviewPage from './pages/dashboard/OverviewPage'
import MembersPage from './pages/dashboard/MembersPage'
import SavingsPage from './pages/dashboard/SavingsPage'
import LoansPage from './pages/dashboard/LoansPage'

function App() {
  const { initialize, loading } = useAuth()

  useEffect(() => {
    initialize()
  }, [initialize])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-surface">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex flex-col">
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        
        {/* Protected Dashboard Routes */}
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <DashboardLayout />
            </ProtectedRoute>
          }
        >
          <Route index element={<OverviewPage />} />
          <Route 
            path="members" 
            element={
              <ProtectedRoute allowedRoles={['admin', 'bendahara']}>
                <MembersPage />
              </ProtectedRoute>
            } 
          />
          <Route path="savings" element={<SavingsPage />} />
          <Route path="loans" element={<LoansPage />} />
          <Route
            path="transactions"
            element={
              <ProtectedRoute allowedRoles={['admin', 'bendahara']}>
                <SavingsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="reports"
            element={
              <ProtectedRoute allowedRoles={['admin']}>
                <OverviewPage />
              </ProtectedRoute>
            }
          />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  )
}

export default App
