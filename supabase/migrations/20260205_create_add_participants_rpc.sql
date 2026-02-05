-- ============================================
-- Create RPC function to add participants (bypasses RLS)
-- ============================================

-- Function to add multiple participants to a chat room
CREATE OR REPLACE FUNCTION add_chat_room_participants(
  p_room_id UUID,
  p_participants JSONB
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
BEGIN
  -- Insert each participant from the JSONB array
  INSERT INTO public.chat_room_participants (room_id, user_id, role)
  SELECT 
    p_room_id,
    (participant->>'user_id')::UUID,
    participant->>'role'
  FROM jsonb_array_elements(p_participants) AS participant;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION add_chat_room_participants TO authenticated;
