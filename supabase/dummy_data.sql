-- ARTHAJAYA DUMMY DATA LOADER
-- This script automatically finds the first user in your Supabase Auth and populates dummy data.
-- IMPORTANT: Make sure you have created at least one user in the Supabase Auth Dashboard first.

DO $$
DECLARE
    v_user_id UUID;
    v_member_id UUID;
    v_loan_id UUID;
BEGIN
    -- 1. Get the first available user from auth.users
    SELECT id INTO v_user_id FROM auth.users LIMIT 1;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'No users found in auth.users. Please create a user in the Supabase Auth Dashboard first.';
    END IF;

    -- 2. Ensure a profile exists (The trigger handle_new_user should have created this, but we'll be safe)
    INSERT INTO profiles (id, full_name, role)
    VALUES (v_user_id, 'Sample Member', 'anggota')
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Member
    INSERT INTO members (user_id, member_number, join_date, status)
    VALUES (v_user_id, 'MEM-2024-001', '2024-01-15', 'active')
    ON CONFLICT (member_number) DO NOTHING
    RETURNING id INTO v_member_id;

    -- If the member already existed, get its ID
    IF v_member_id IS NULL THEN
        SELECT id INTO v_member_id FROM members WHERE member_number = 'MEM-2024-001';
    END IF;

    -- 4. Initial Savings
    INSERT INTO savings (member_id, type, amount, transaction_type, description)
    VALUES 
    (v_member_id, 'pokok', 1000000, 'deposit', 'Initial principal savings'),
    (v_member_id, 'wajib', 500000, 'deposit', 'Initial mandatory savings'),
    (v_member_id, 'sukarela', 2000000, 'deposit', 'Initial voluntary savings')
    ON CONFLICT DO NOTHING;

    -- 5. Monthly Savings
    INSERT INTO savings (member_id, type, amount, transaction_type, description, created_at)
    VALUES 
    (v_member_id, 'wajib', 100000, 'deposit', 'Monthly mandatory - Feb', NOW() - INTERVAL '2 months'),
    (v_member_id, 'wajib', 100000, 'deposit', 'Monthly mandatory - Mar', NOW() - INTERVAL '1 month')
    ON CONFLICT DO NOTHING;

    -- 6. Create an Active Loan
    INSERT INTO loans (member_id, amount, interest_rate, tenor, status, approved_at)
    VALUES 
    (v_member_id, 12000000, 1.0, 12, 'active', NOW() - INTERVAL '1 month')
    RETURNING id INTO v_loan_id;

    -- 7. Generate Installments for the Loan (if loan was created)
    IF v_loan_id IS NOT NULL THEN
        INSERT INTO installments (loan_id, installment_number, amount, status, paid_at)
        VALUES 
        (v_loan_id, 1, 1120000, 'paid', NOW() - INTERVAL '15 days'),
        (v_loan_id, 2, 1120000, 'unpaid', NULL),
        (v_loan_id, 3, 1120000, 'unpaid', NULL),
        (v_loan_id, 4, 1120000, 'unpaid', NULL),
        (v_loan_id, 5, 1120000, 'unpaid', NULL),
        (v_loan_id, 6, 1120000, 'unpaid', NULL),
        (v_loan_id, 7, 1120000, 'unpaid', NULL),
        (v_loan_id, 8, 1120000, 'unpaid', NULL),
        (v_loan_id, 9, 1120000, 'unpaid', NULL),
        (v_loan_id, 10, 1120000, 'unpaid', NULL),
        (v_loan_id, 11, 1120000, 'unpaid', NULL),
        (v_loan_id, 12, 1120000, 'unpaid', NULL);
    END IF;

    RAISE NOTICE 'Dummy data successfully loaded for User: %', v_user_id;
END $$;
