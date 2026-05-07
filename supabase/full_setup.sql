-- =================================================================================
-- ARTHAJAYA FULL SYSTEM SETUP (ULTIMATE EDITION)
-- Jalankan file ini SATU KALI di SQL Editor Supabase untuk setup seluruh sistem.
-- =================================================================================

-- 1. PEMBERSIHAN (Hapus semua jika sudah ada)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_profile_created ON public.profiles;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.handle_new_member();
DROP TABLE IF EXISTS public.installments CASCADE;
DROP TABLE IF EXISTS public.loans CASCADE;
DROP TABLE IF EXISTS public.savings CASCADE;
DROP TABLE IF EXISTS public.members CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP SEQUENCE IF EXISTS member_number_seq;

-- 2. EKSTENSI & SEQUENCE
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SEQUENCE member_number_seq;

-- 3. PEMBUATAN TABEL
-- Tabel Profil (User Management)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'bendahara', 'anggota')),
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Anggota
CREATE TABLE public.members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE UNIQUE NOT NULL,
  member_number TEXT UNIQUE NOT NULL,
  join_date DATE DEFAULT CURRENT_DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Simpanan
CREATE TABLE public.savings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID REFERENCES public.members ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('pokok', 'wajib', 'sukarela')),
  amount DECIMAL(15,2) NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('deposit', 'withdrawal')),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Pinjaman
CREATE TABLE public.loans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID REFERENCES public.members ON DELETE CASCADE NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  interest_rate DECIMAL(5,2) NOT NULL, -- per bulan
  tenor INTEGER NOT NULL, -- dalam bulan
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'paid', 'rejected')),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabel Cicilan
CREATE TABLE public.installments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_id UUID REFERENCES public.loans ON DELETE CASCADE NOT NULL,
  installment_number INTEGER NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  penalty DECIMAL(15,2) DEFAULT 0,
  paid_at TIMESTAMPTZ,
  status TEXT DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'paid', 'late')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. KEAMANAN (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.installments ENABLE ROW LEVEL SECURITY;

-- Policy: Semua user terautentikasi bisa baca profilnya sendiri
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
-- Policy: Admin & Bendahara bisa baca semua
CREATE POLICY "Staff can view all profiles" ON public.profiles FOR ALL 
USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'bendahara')));

-- (Policy tabel lainnya disingkat untuk efisiensi, Admin punya akses penuh)
CREATE POLICY "Admin full access members" ON public.members FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'bendahara')));
CREATE POLICY "Members view own data" ON public.members FOR SELECT USING (user_id = auth.uid());

-- 5. FUNGSI OTOMASI (TRIGGERS)
-- Fungsi: Buat Profil saat User baru mendaftar di Auth
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User Baru'), 
    COALESCE(NEW.raw_user_meta_data->>'role', 'anggota')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Fungsi: Buat Member ID saat Profil dengan role 'anggota' dibuat
CREATE OR REPLACE FUNCTION public.handle_new_member() 
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'anggota' THEN
    INSERT INTO public.members (user_id, member_number, status)
    VALUES (
      NEW.id, 
      'MEM-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval('member_number_seq')::text, 4, '0'), 
      'active'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_member();

-- 6. GENERASI DATA DUMMY (ADMIN, BENDAHARA, ANGGOTA)
DO $$
DECLARE
    v_admin_id UUID := gen_random_uuid();
    v_bendahara_id UUID := gen_random_uuid();
    v_anggota_id UUID := gen_random_uuid();
    v_member_id UUID;
    v_loan_id UUID;
BEGIN
    -- Hapus user lama jika ada (berdasarkan email)
    DELETE FROM auth.users WHERE email IN ('admin@arthajaya.com', 'bendahara@arthajaya.com', 'anggota@arthajaya.com');

    -- Masukkan User Admin
    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_admin_id, 'authenticated', 'authenticated', 'admin@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Admin Arthajaya","role":"admin"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    -- Masukkan User Bendahara
    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_bendahara_id, 'authenticated', 'authenticated', 'bendahara@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Bendahara Arthajaya","role":"bendahara"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    -- Masukkan User Anggota
    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_anggota_id, 'authenticated', 'authenticated', 'anggota@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Budi Anggota","role":"anggota"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    -- Tunggu sebentar (Profil & Member akan dibuat otomatis oleh Trigger di atas)
    
    -- Ambil Member ID yang baru dibuat oleh trigger untuk Budi Anggota
    SELECT id INTO v_member_id FROM public.members WHERE user_id = v_anggota_id;

    -- Tambah Saldo Awal (Simpanan Pokok)
    INSERT INTO public.savings (member_id, type, amount, transaction_type, description)
    VALUES (v_member_id, 'pokok', 1000000, 'deposit', 'Setoran Awal Pokok');

    -- Tambah Pinjaman Aktif
    INSERT INTO public.loans (member_id, amount, interest_rate, tenor, status, approved_at)
    VALUES (v_member_id, 12000000, 1.5, 12, 'active', now())
    RETURNING id INTO v_loan_id;

    -- Tambah Cicilan Pertama yang sudah lunas
    INSERT INTO public.installments (loan_id, installment_number, amount, status, paid_at)
    VALUES (v_loan_id, 1, 1180000, 'paid', now());

    RAISE NOTICE 'SISTEM ARTHAJAYA BERHASIL DI-SETUP!';
    RAISE NOTICE 'Login Admin: admin@arthajaya.com | password123';
END $$;
