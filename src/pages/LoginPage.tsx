import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { supabase } from '../lib/supabase'
import { Button, Input } from '../components/ui/FormControls'
import { toast } from 'react-hot-toast'
import { Lock, Mail, ArrowRight } from 'lucide-react'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

type LoginFormValues = z.infer<typeof loginSchema>

export default function LoginPage() {
  const navigate = useNavigate()
  const [isLoading, setIsLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginFormValues) => {
    setIsLoading(true)
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password,
      })

      if (error) throw error
      
      toast.success('Welcome back to ARTHAJAYA!')
      navigate('/dashboard')
    } catch (error: any) {
      toast.error(error.message || 'Failed to login')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-primary/10 via-surface to-surface-dark">
      <div className="w-full max-w-md">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-bold text-primary mb-2 tracking-tighter">ARTHAJAYA</h1>
          <p className="text-slate-400">Dashboard Keuangan Koperasi</p>
        </div>

        <div className="glass-card p-8 space-y-6">
          <div className="space-y-2">
            <h2 className="text-2xl font-semibold">Masuk</h2>
            <p className="text-sm text-slate-500">Masukkan kredensial Anda untuk mengakses akun</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="relative group">
              <div className="absolute left-3 top-[38px] text-slate-500 group-focus-within:text-primary transition-colors">
                <Mail size={18} />
              </div>
              <Input
                label="Alamat Email"
                placeholder="nama@contoh.com"
                className="pl-10"
                error={errors.email?.message}
                {...register('email')}
              />
            </div>

            <div className="relative group">
              <div className="absolute left-3 top-[38px] text-slate-500 group-focus-within:text-primary transition-colors">
                <Lock size={18} />
              </div>
              <Input
                label="Kata Sandi"
                type="password"
                placeholder="••••••••"
                className="pl-10"
                error={errors.password?.message}
                {...register('password')}
              />
            </div>

            <Button
              type="submit"
              className="w-full mt-2"
              isLoading={isLoading}
            >
              Masuk Sekarang <ArrowRight className="ml-2" size={18} />
            </Button>
          </form>

          <div className="text-center pt-4">
            <p className="text-sm text-slate-500">
              Belum punya akun?{' '}
              <button className="text-primary hover:underline font-medium">
                Hubungi Admin
              </button>
            </p>
          </div>
        </div>

        <div className="mt-8 text-center text-xs text-slate-600">
          &copy; 2026 Koperasi ARTHAJAYA. Seluruh hak dilindungi.
        </div>
      </div>
    </div>
  )
}
