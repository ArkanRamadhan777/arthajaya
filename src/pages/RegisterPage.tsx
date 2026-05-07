import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { supabase } from '../lib/supabase'
import { Button, Input } from '../components/ui/FormControls'
import { toast } from 'react-hot-toast'
import { Lock, Mail, User, ArrowRight, Phone, MapPin } from 'lucide-react'

const registerSchema = z.object({
  fullName: z.string().min(3, 'Nama lengkap minimal 3 karakter'),
  email: z.string().email('Alamat email tidak valid'),
  phone: z.string().min(10, 'Nomor telepon minimal 10 digit'),
  address: z.string().min(5, 'Alamat minimal 5 karakter'),
  password: z.string().min(6, 'Kata sandi minimal 6 karakter'),
  confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
  message: "Konfirmasi kata sandi tidak cocok",
  path: ["confirmPassword"],
});

type RegisterFormValues = z.infer<typeof registerSchema>

export default function RegisterPage() {
  const navigate = useNavigate()
  const [isLoading, setIsLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
  })

  const onSubmit = async (data: RegisterFormValues) => {
    setIsLoading(true)
    try {
      const { error } = await supabase.auth.signUp({
        email: data.email,
        password: data.password,
        options: {
          data: {
            full_name: data.fullName,
            phone: data.phone,
            address: data.address,
            role: 'anggota' // Default role for new registrations
          }
        }
      })

      if (error) throw error
      
      toast.success('Registrasi berhasil! Silakan masuk.')
      navigate('/login')
    } catch (error: any) {
      toast.error(error.message || 'Gagal melakukan registrasi')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-primary/10 via-surface to-surface-dark">
      <div className="w-full max-w-lg">
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center gap-2 mb-4">
            <img src="/logo.svg" alt="Logo" className="w-8 h-8" />
            <span className="text-2xl font-bold tracking-tighter text-white">ARTHAJAYA</span>
          </Link>
          <p className="text-slate-400 font-light">Bergabunglah dengan Koperasi Masa Depan</p>
        </div>

        <div className="glass-card p-8 space-y-6">
          <div className="space-y-1">
            <h2 className="text-2xl font-semibold">Daftar Anggota</h2>
            <p className="text-sm text-slate-500">Lengkapi data diri Anda untuk memulai</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="relative group">
                <div className="absolute left-3 top-[38px] text-slate-500 group-focus-within:text-primary transition-colors">
                  <User size={18} />
                </div>
                <Input
                  label="Nama Lengkap"
                  placeholder="Budi Santoso"
                  className="pl-10"
                  error={errors.fullName?.message}
                  {...register('fullName')}
                />
              </div>

              <div className="relative group">
                <div className="absolute left-3 top-[38px] text-slate-500 group-focus-within:text-primary transition-colors">
                  <Phone size={18} />
                </div>
                <Input
                  label="Nomor Telepon"
                  placeholder="08123456789"
                  className="pl-10"
                  error={errors.phone?.message}
                  {...register('phone')}
                />
              </div>
            </div>

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
                <MapPin size={18} />
              </div>
              <Input
                label="Alamat Lengkap"
                placeholder="Jl. Merdeka No. 123, Jakarta"
                className="pl-10"
                error={errors.address?.message}
                {...register('address')}
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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

              <div className="relative group">
                <div className="absolute left-3 top-[38px] text-slate-500 group-focus-within:text-primary transition-colors">
                  <Lock size={18} />
                </div>
                <Input
                  label="Ulangi Kata Sandi"
                  type="password"
                  placeholder="••••••••"
                  className="pl-10"
                  error={errors.confirmPassword?.message}
                  {...register('confirmPassword')}
                />
              </div>
            </div>

            <Button
              type="submit"
              className="w-full mt-4 h-12"
              isLoading={isLoading}
            >
              Daftar Sekarang <ArrowRight className="ml-2" size={18} />
            </Button>
          </form>

          <div className="text-center pt-2">
            <p className="text-sm text-slate-500">
              Sudah punya akun?{' '}
              <Link to="/login" className="text-primary hover:underline font-medium">
                Masuk di sini
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
