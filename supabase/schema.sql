-- ARTHAJAYA Cooperative Management System Schema
-- Supabase SQL Editor script

-- 1. ENUMS
CREATE TYPE user_role AS ENUM ('admin', 'bendahara', 'anggota');
CREATE TYPE saving_type AS ENUM ('pokok', 'wajib', 'sukarela');
CREATE TYPE transaction_type AS ENUM ('deposit', 'withdrawal');
CREATE TYPE loan_status AS ENUM ('pending', 'active', 'paid', 'rejected');
CREATE TYPE installment_status AS ENUM ('unpaid', 'paid', 'late');

-- 2. TABLES
-- Profiles: Extends auth.users
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    role user_role NOT NULL DEFAULT 'anggota',
    full_name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Members: Cooperative specific info
CREATE TABLE members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    member_number TEXT UNIQUE NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Savings: Tracks all deposits and withdrawals
CREATE TABLE savings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_id UUID REFERENCES members(id) ON DELETE CASCADE NOT NULL,
    type saving_type NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type transaction_type NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Loans: Credit system
CREATE TABLE loans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_id UUID REFERENCES members(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL, -- Annual or monthly rate
    tenor INTEGER NOT NULL, -- Number of months
    status loan_status DEFAULT 'pending' NOT NULL,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Installments: Repayment schedule
CREATE TABLE installments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    loan_id UUID REFERENCES loans(id) ON DELETE CASCADE NOT NULL,
    installment_number INTEGER NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    penalty DECIMAL(15,2) DEFAULT 0,
    paid_at TIMESTAMP WITH TIME ZONE,
    status installment_status DEFAULT 'unpaid' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. ROW LEVEL SECURITY (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings ENABLE ROW LEVEL SECURITY;
ALTER TABLE loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE installments ENABLE ROW LEVEL SECURITY;

-- Policies for Profiles
CREATE POLICY "Public profiles are viewable by everyone." ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile." ON profiles FOR UPDATE USING (auth.uid() = id);

-- Policies for Members
CREATE POLICY "Members viewable by staff." ON members FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'bendahara'))
);
CREATE POLICY "Members viewable by self." ON members FOR SELECT USING (user_id = auth.uid());

-- Policies for Savings
CREATE POLICY "Savings viewable by staff." ON savings FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'bendahara'))
);
CREATE POLICY "Savings viewable by self." ON savings FOR SELECT USING (
  EXISTS (SELECT 1 FROM members WHERE id = savings.member_id AND user_id = auth.uid())
);

-- Policies for Loans
CREATE POLICY "Loans viewable by staff." ON loans FOR SELECT USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'bendahara'))
);
CREATE POLICY "Loans viewable by self." ON loans FOR SELECT USING (
  EXISTS (SELECT 1 FROM members WHERE id = loans.member_id AND user_id = auth.uid())
);

-- 4. TRIGGERS
-- Create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', (new.raw_user_meta_data->>'role')::user_role);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 5. DUMMY DATA (Note: Profiles must match auth.users IDs, so these are placeholders)
-- You will need to create users in Auth first to use these correctly.
-- But here is how they would look:

/*
INSERT INTO members (member_number, user_id, status) 
VALUES ('MEM-2024-001', 'AUTH_USER_ID_1', 'active');

INSERT INTO savings (member_id, type, amount, transaction_type, description)
VALUES 
((SELECT id FROM members LIMIT 1), 'pokok', 1000000, 'deposit', 'Initial deposit'),
((SELECT id FROM members LIMIT 1), 'wajib', 100000, 'deposit', 'Monthly mandatory');

INSERT INTO loans (member_id, amount, interest_rate, tenor, status)
VALUES ((SELECT id FROM members LIMIT 1), 5000000, 1.5, 12, 'active');
*/
