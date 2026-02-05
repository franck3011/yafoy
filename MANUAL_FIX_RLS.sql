-- ============================================
-- MANDATORY FIX: Execute this in Supabase Dashboard
-- Navigate to: https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/sql
-- ============================================
-- This creates a server-side function that bypasses RLS
-- to insert chat room participants
-- ============================================

-- Create the RPC function
CREATE OR REPLACE FUNCTION add_chat_room_participants(
  p_room_id UUID,
  p_participants JSONB
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- This allows bypassing RLS
AS $$
BEGIN
  -- Insert each participant from the JSONB array
  INSERT INTO public.chat_room_participants (room_id, user_id, role)
  SELECT 
    p_room_id,
    (participant->>'user_id')::UUID,
    participant->>'role'
  FROM jsonb_array_elements(p_participants) AS participant
  ON CONFLICT (room_id, user_id) DO NOTHING; -- Avoid duplicates
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION add_chat_room_participants TO authenticated;

-- Verify the function was created
SELECT 
  routine_name,
  routine_type,
  security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'add_chat_room_participants';

-- Expected result: You should see the function with DEFINER security type

