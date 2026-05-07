import { Calendar, Clock, CheckCircle2, Plus } from 'lucide-react'
import { Button } from '../../components/ui/FormControls'

export default function LoansPage() {
  const activeLoans = [
    { 
      id: 'L-2024-88', 
      amount: 'Rp 25,000,000', 
      tenor: '24 Bulan', 
      interest: '1.5%', 
      status: 'aktif', 
      progress: 45, 
      remaining: 'Rp 14,250,000',
      next_payment: '15 Nov 2026'
    }
  ]

  return (
    <div className="space-y-8 animate-in slide-in-from-left-4 duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold">Manajemen Pinjaman</h1>
          <p className="text-slate-500">Pantau pinjaman aktif dan jadwal angsuran Anda.</p>
        </div>
        <Button>
          <Plus size={18} className="mr-2" /> Ajukan Pinjaman
        </Button>
      </div>

      {activeLoans.map((loan) => (
        <div key={loan.id} className="glass-card p-8">
          <div className="flex flex-col lg:flex-row gap-8">
            <div className="flex-1 space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-slate-500 font-mono uppercase">ID Pinjaman: {loan.id}</p>
                  <h2 className="text-3xl font-bold mt-1">{loan.amount}</h2>
                </div>
                <span className="px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-bold uppercase tracking-wider">
                  {loan.status}
                </span>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="p-4 rounded-2xl bg-white/5 space-y-1">
                  <p className="text-[10px] text-slate-500 uppercase font-semibold">Tenor</p>
                  <p className="text-sm font-bold">{loan.tenor}</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 space-y-1">
                  <p className="text-[10px] text-slate-500 uppercase font-semibold">Bunga</p>
                  <p className="text-sm font-bold">{loan.interest}</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 space-y-1">
                  <p className="text-[10px] text-slate-500 uppercase font-semibold">Sisa Pinjaman</p>
                  <p className="text-sm font-bold">{loan.remaining}</p>
                </div>
                <div className="p-4 rounded-2xl bg-white/5 space-y-1 text-primary">
                  <p className="text-[10px] text-primary/70 uppercase font-semibold">Jatuh Tempo</p>
                  <p className="text-sm font-bold">{loan.next_payment}</p>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-slate-500">Progres Pelunasan</span>
                  <span className="font-bold">{loan.progress}%</span>
                </div>
                <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-primary transition-all duration-1000" 
                    style={{ width: `${loan.progress}%` }} 
                  />
                </div>
              </div>
            </div>

            <div className="lg:w-80 space-y-4">
              <div className="p-6 rounded-2xl bg-white/5 border border-white/10 space-y-4">
                <h3 className="font-semibold flex items-center gap-2">
                  <Clock size={18} className="text-primary" /> Angsuran Mendatang
                </h3>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Jumlah</span>
                    <span className="font-bold">Rp 1,250,000</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Denda</span>
                    <span className="font-bold text-green-500">Rp 0</span>
                  </div>
                </div>
                <Button className="w-full">Bayar Sekarang</Button>
              </div>
            </div>
          </div>
        </div>
      ))}

      <div className="glass-card overflow-hidden">
        <div className="p-6 border-b border-white/5">
          <h3 className="text-lg font-semibold">Riwayat Angsuran</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/5 bg-white/5 text-xs font-semibold uppercase tracking-wider text-slate-500">
                <th className="px-6 py-4">No.</th>
                <th className="px-6 py-4">Tgl Jatuh Tempo</th>
                <th className="px-6 py-4">Jumlah</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Tgl Bayar</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5 text-sm">
              {[1, 2, 3].map((i) => (
                <tr key={i} className="hover:bg-white/5 transition-colors">
                  <td className="px-6 py-4 font-bold">{i}</td>
                  <td className="px-6 py-4 text-slate-400">{15 - i} Sep 2026</td>
                  <td className="px-6 py-4 font-semibold">Rp 1,250,000</td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2 text-green-500">
                      <CheckCircle2 size={16} />
                      <span className="text-xs font-bold uppercase">Lunas</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right text-slate-500">{14 - i} Sep 2026</td>
                </tr>
              ))}
              <tr className="hover:bg-white/5 transition-colors">
                <td className="px-6 py-4 font-bold">4</td>
                <td className="px-6 py-4 text-slate-400">15 Okt 2026</td>
                <td className="px-6 py-4 font-semibold">Rp 1,250,000</td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2 text-primary">
                    <Clock size={16} />
                    <span className="text-xs font-bold uppercase">Menunggu</span>
                  </div>
                </td>
                <td className="px-6 py-4 text-right text-slate-500">-</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
