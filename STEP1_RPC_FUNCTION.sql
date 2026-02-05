-- ============================================
-- STEP 1: Create RPC Function
-- Execute this FIRST
-- ============================================
CREATE OR REPLACE FUNCTION add_chat_room_participants(
  p_room_id UUID,
  p_participants JSONB
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.chat_room_participants (room_id, user_id, role)
  SELECT 
    p_room_id,
    (participant->>'user_id')::UUID,
    participant->>'role'
  FROM jsonb_array_elements(p_participants) AS participant
  ON CONFLICT (room_id, user_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION add_chat_room_participants TO authenticated;

-- Verify it was created
SELECT routine_name, security_type
FROM information_schema.routines
WHERE routine_name = 'add_chat_room_participants';
