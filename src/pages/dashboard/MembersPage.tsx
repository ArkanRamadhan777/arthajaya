import { useState } from 'react'
import { Plus, Search, Filter, MoreVertical, Edit2, Trash2 } from 'lucide-react'
import { Button } from '../../components/ui/FormControls'

const dummyMembers = [
  { id: 1, name: 'Budi Santoso', email: 'budi@example.com', member_number: 'MEM-2024-001', join_date: '2024-01-15', status: 'active' },
  { id: 2, name: 'Siti Aminah', email: 'siti@example.com', member_number: 'MEM-2024-002', join_date: '2024-01-20', status: 'active' },
  { id: 3, name: 'Rahmat Hidayat', email: 'rahmat@example.com', member_number: 'MEM-2024-003', join_date: '2024-02-05', status: 'inactive' },
  { id: 4, name: 'Dewi Lestari', email: 'dewi@example.com', member_number: 'MEM-2024-004', join_date: '2024-02-12', status: 'active' },
  { id: 5, name: 'Agus Prayogo', email: 'agus@example.com', member_number: 'MEM-2024-005', join_date: '2024-03-01', status: 'active' },
]

export default function MembersPage() {
  const [searchTerm, setSearchTerm] = useState('')

  return (
    <div className="space-y-8 animate-in slide-in-from-bottom-4 duration-700">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold">Manajemen Anggota</h1>
          <p className="text-slate-500">Kelola data anggota koperasi dan status keanggotaan mereka.</p>
        </div>
        <Button className="w-full md:w-auto">
          <Plus size={18} className="mr-2" /> Tambah Anggota Baru
        </Button>
      </div>

      <div className="glass-card overflow-hidden">
        <div className="p-6 border-b border-white/5 flex flex-col md:flex-row gap-4 items-center">
          <div className="relative flex-1 w-full">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
            <input 
              type="text" 
              placeholder="Cari berdasarkan nama, email, atau nomor anggota..."
              className="w-full bg-white/5 border border-white/5 rounded-xl py-2 pl-10 pr-4 text-sm focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div className="flex gap-2 w-full md:w-auto">
            <Button variant="secondary" className="flex-1 md:flex-none">
              <Filter size={18} className="mr-2" /> Filter
            </Button>
            <Button variant="secondary" className="flex-1 md:flex-none">
              Ekspor
            </Button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/5 bg-white/5 text-xs font-semibold uppercase tracking-wider text-slate-500">
                <th className="px-6 py-4">Nama Anggota</th>
                <th className="px-6 py-4">ID Anggota</th>
                <th className="px-6 py-4">Tanggal Bergabung</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-white/5 text-sm">
              {dummyMembers.map((member) => (
                <tr key={member.id} className="hover:bg-white/5 transition-colors group">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-primary/20 text-primary flex items-center justify-center font-bold text-xs uppercase">
                        {member.name.charAt(0)}
                      </div>
                      <div>
                        <p className="font-medium">{member.name}</p>
                        <p className="text-xs text-slate-500">{member.email}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-mono text-xs">{member.member_number}</td>
                  <td className="px-6 py-4 text-slate-400">{member.join_date}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded-full text-[10px] font-bold uppercase ${
                      member.status === 'active' 
                        ? 'bg-green-500/10 text-green-500' 
                        : 'bg-red-500/10 text-red-500'
                    }`}>
                      {member.status === 'active' ? 'Aktif' : 'Nonaktif'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button className="p-1.5 text-slate-400 hover:text-white transition-colors">
                        <Edit2 size={16} />
                      </button>
                      <button className="p-1.5 text-slate-400 hover:text-red-500 transition-colors">
                        <Trash2 size={16} />
                      </button>
                      <button className="p-1.5 text-slate-400 hover:text-white transition-colors">
                        <MoreVertical size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="p-6 border-t border-white/5 flex items-center justify-between">
          <p className="text-sm text-slate-500">Menampilkan 1 sampai 5 dari 1,284 anggota</p>
          <div className="flex gap-2">
            <button className="px-4 py-1 text-xs text-slate-400 hover:text-white transition-colors disabled:opacity-30" disabled>Sebelumnya</button>
            <button className="px-4 py-1 text-xs text-slate-400 hover:text-white transition-colors">Selanjutnya</button>
          </div>
        </div>
      </div>
    </div>
  )
}
