import { Wallet, ArrowDownLeft, ArrowUpRight, Plus } from 'lucide-react'
import { Button } from '../../components/ui/FormControls'

export default function SavingsPage() {
  const savingTypes = [
    { name: 'Simpanan Pokok', balance: 'Rp 1,000,000', description: 'Simpanan wajib saat awal menjadi anggota', color: 'bg-blue-500' },
    { name: 'Simpanan Wajib', balance: 'Rp 5,400,000', description: 'Simpanan rutin setiap bulan', color: 'bg-primary' },
    { name: 'Simpanan Sukarela', balance: 'Rp 12,850,000', description: 'Simpanan bebas yang bisa diambil kapan saja', color: 'bg-green-500' },
  ]

  return (
    <div className="space-y-8 animate-in slide-in-from-right-4 duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold">Ringkasan Simpanan</h1>
          <p className="text-slate-500">Pantau dan kelola seluruh simpanan koperasi Anda.</p>
        </div>
        <div className="flex gap-2">
          <Button variant="secondary">Penarikan</Button>
          <Button>
            <Plus size={18} className="mr-2" /> Setoran Baru
          </Button>
        </div>
      </div>

      {/* Saving Type Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {savingTypes.map((type) => (
          <div key={type.name} className="glass-card p-6 relative overflow-hidden group">
            <div className={`absolute top-0 right-0 w-32 h-32 ${type.color}/10 rounded-full -mr-16 -mt-16 blur-2xl transition-all group-hover:scale-150`} />
            <div className="space-y-4 relative z-10">
              <div className={`w-10 h-10 rounded-lg ${type.color}/20 flex items-center justify-center text-white`}>
                <Wallet size={20} />
              </div>
              <div>
                <p className="text-sm text-slate-500">{type.name}</p>
                <h3 className="text-2xl font-bold">{type.balance}</h3>
              </div>
              <p className="text-xs text-slate-600">{type.description}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="glass-card overflow-hidden">
          <div className="p-6 border-b border-white/5 flex items-center justify-between">
            <h3 className="text-lg font-semibold">Setoran Terbaru</h3>
            <button className="text-sm text-primary hover:underline">Lihat Semua</button>
          </div>
          <div className="divide-y divide-white/5">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="p-4 flex items-center justify-between hover:bg-white/5 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-green-500/10 text-green-500 flex items-center justify-center">
                    <ArrowDownLeft size={18} />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Setoran Simpanan Wajib</p>
                    <p className="text-xs text-slate-500">05 Okt 2026 • Simpanan Wajib</p>
                  </div>
                </div>
                <p className="text-sm font-bold text-green-500">+Rp 100,000</p>
              </div>
            ))}
          </div>
        </div>

        <div className="glass-card overflow-hidden">
          <div className="p-6 border-b border-white/5 flex items-center justify-between">
            <h3 className="text-lg font-semibold">Penarikan Terbaru</h3>
            <button className="text-sm text-primary hover:underline">Lihat Semua</button>
          </div>
          <div className="divide-y divide-white/5">
            {[1, 2].map((i) => (
              <div key={i} className="p-4 flex items-center justify-between hover:bg-white/5 transition-colors">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-red-500/10 text-red-500 flex items-center justify-center">
                    <ArrowUpRight size={18} />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Penarikan Sukarela</p>
                    <p className="text-xs text-slate-500">28 Sep 2026 • Simpanan Sukarela</p>
                  </div>
                </div>
                <p className="text-sm font-bold text-red-500">-Rp 1,500,000</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
