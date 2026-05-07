-- =================================================================================
-- ARTHAJAYA FULL SYSTEM SETUP (FIXED RLS EDITION)
-- =================================================================================

-- 1. PEMBERSIHAN
DROP TABLE IF EXISTS public.installments CASCADE;
DROP TABLE IF EXISTS public.loans CASCADE;
DROP TABLE IF EXISTS public.savings CASCADE;
DROP TABLE IF EXISTS public.members CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_member() CASCADE;
DROP SEQUENCE IF EXISTS member_number_seq;

-- 2. SETUP
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SEQUENCE member_number_seq;

-- 3. TABEL
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'bendahara', 'anggota')),
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE UNIQUE NOT NULL,
  member_number TEXT UNIQUE NOT NULL,
  join_date DATE DEFAULT CURRENT_DATE,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.savings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID REFERENCES public.members ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('pokok', 'wajib', 'sukarela')),
  amount DECIMAL(15,2) NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('deposit', 'withdrawal')),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.loans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id UUID REFERENCES public.members ON DELETE CASCADE NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  interest_rate DECIMAL(5,2) NOT NULL,
  tenor INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'paid', 'rejected')),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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

-- 4. KEAMANAN (Tanpa Rekursi)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "View own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Staff manage all" ON public.profiles FOR ALL USING (role IN ('admin', 'bendahara'));

CREATE POLICY "Staff manage members" ON public.members FOR ALL USING (
  (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'bendahara')
);
CREATE POLICY "Member view own" ON public.members FOR SELECT USING (user_id = auth.uid());

-- 5. TRIGGERS
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

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_member() 
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'anggota' THEN
    INSERT INTO public.members (user_id, member_number, status)
    VALUES (NEW.id, 'MEM-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval('member_number_seq')::text, 4, '0'), 'active');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_profile_created AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.handle_new_member();

-- 6. DATA
DO $$
DECLARE
    v_admin_id UUID := gen_random_uuid();
    v_bendahara_id UUID := gen_random_uuid();
    v_anggota_id UUID := gen_random_uuid();
    v_member_id UUID;
    v_loan_id UUID;
BEGIN
    DELETE FROM auth.users WHERE email IN ('admin@arthajaya.com', 'bendahara@arthajaya.com', 'anggota@arthajaya.com');

    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_admin_id, 'authenticated', 'authenticated', 'admin@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Admin Arthajaya","role":"admin"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_bendahara_id, 'authenticated', 'authenticated', 'bendahara@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Bendahara Arthajaya","role":"bendahara"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, instance_id)
    VALUES (v_anggota_id, 'authenticated', 'authenticated', 'anggota@arthajaya.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"full_name":"Budi Anggota","role":"anggota"}', now(), now(), '00000000-0000-0000-0000-000000000000');

    SELECT id INTO v_member_id FROM public.members WHERE user_id = v_anggota_id;
    INSERT INTO public.savings (member_id, type, amount, transaction_type, description) VALUES (v_member_id, 'pokok', 1000000, 'deposit', 'Setoran Awal');
    INSERT INTO public.loans (member_id, amount, interest_rate, tenor, status, approved_at) VALUES (v_member_id, 12000000, 1.5, 12, 'active', now()) RETURNING id INTO v_loan_id;
    INSERT INTO public.installments (loan_id, installment_number, amount, status, paid_at) VALUES (v_loan_id, 1, 1180000, 'paid', now());
END $$;
