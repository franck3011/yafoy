-- ============================================
-- COMPLETE FIX: Real-time Client-Organizer Chat
-- Execute ALL of this in Supabase Dashboard SQL Editor
-- https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/sql
-- ============================================

-- ============================================
-- STEP 1: Create RPC Function to Add Participants
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

-- ============================================
-- STEP 2: Enable Realtime for Chat Tables
-- ============================================
-- Note: These commands will error if tables are already added, which is fine
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_room_participants;

-- ============================================
-- STEP 3: Verify RLS Policies for Messages
-- ============================================
-- Check current policies
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'chat_messages';

-- If no INSERT policy exists, create one
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'chat_messages' 
    AND cmd = 'INSERT'
  ) THEN
    CREATE POLICY "Participants can send messages"
    ON public.chat_messages
    FOR INSERT
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM public.chat_room_participants
        WHERE room_id = chat_messages.room_id 
        AND user_id = auth.uid()
      )
    );
  END IF;
END $$;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- 1. Check RPC function exists
SELECT routine_name, security_type
FROM information_schema.routines
WHERE routine_name = 'add_chat_room_participants';
-- Expected: 1 row with security_type = 'DEFINER'

-- 2. Check realtime is enabled
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
AND tablename IN ('chat_messages', 'chat_rooms', 'chat_room_participants');
-- Expected: 3 rows

-- 3. Check for organizers
SELECT p.user_id, p.full_name, p.email
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
WHERE ur.role = 'organizer';
-- If empty, you need to add organizer role to a user

-- ============================================
-- STEP 4: Add Organizer Role (if needed)
-- ============================================
-- First, find your user_id by checking your email
-- SELECT user_id, email FROM profiles WHERE email = 'your_email@example.com';

-- Then uncomment and run this with your actual user_id:
-- INSERT INTO user_roles (user_id, role) 
-- VALUES ('YOUR_USER_ID_HERE', 'organizer')
-- ON CONFLICT (user_id, role) DO NOTHING;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT 'Setup complete! Now refresh your app and test the chat.' AS status;
