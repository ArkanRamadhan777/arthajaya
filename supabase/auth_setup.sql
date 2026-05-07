-- ARTHAJAYA AUTH & REGISTRATION SETUP
-- Additional triggers to handle automatic membership on registration.

-- Function to handle automatic member creation for 'anggota' role
CREATE OR REPLACE FUNCTION public.handle_new_member() 
RETURNS TRIGGER AS $$
BEGIN
  -- Only create a member record if the role is 'anggota'
  IF NEW.role = 'anggota' THEN
    INSERT INTO public.members (user_id, member_number, status)
    VALUES (
      NEW.id, 
      'MEM-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval(pg_get_serial_sequence('members', 'id'))::text, 4, '0'), 
      'active'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to run AFTER a profile is created
CREATE OR REPLACE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_member();

-- Note: The sequence generation above assumes 'id' is a serial. 
-- Since we use UUID, we'll use a simpler member_number generation or a custom sequence.

-- Let's create a dedicated sequence for member numbers
CREATE SEQUENCE IF NOT EXISTS member_number_seq;

CREATE OR REPLACE FUNCTION public.handle_new_member_v2() 
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role = 'anggota' THEN
    INSERT INTO public.members (user_id, member_number, status)
    VALUES (
      NEW.id, 
      'MEM-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(nextval('member_number_seq')::text, 4, '0'), 
      'active'
    )
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the trigger to use the new function
DROP TRIGGER IF EXISTS on_profile_created ON public.profiles;
CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_member_v2();
