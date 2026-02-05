-- ============================================
-- DIAGNOSTIC: Check RLS Policies for Messages
-- ============================================

-- 1. Check all policies on chat_messages
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'chat_messages'
ORDER BY cmd, policyname;

-- 2. Check if user is a participant in any room
-- Replace 'YOUR_USER_ID' with the organizer's user_id
SELECT 
    crp.room_id,
    crp.user_id,
    crp.role,
    cr.name as room_name
FROM chat_room_participants crp
JOIN chat_rooms cr ON cr.id = crp.room_id
-- WHERE crp.user_id = 'YOUR_USER_ID'  -- Uncomment and replace
ORDER BY cr.created_at DESC;

-- 3. Try to insert a test message (will fail if RLS blocks it)
-- Replace these values:
-- - YOUR_ROOM_ID: the chat room ID
-- - YOUR_USER_ID: your user ID
-- Uncomment to test:
/*
INSERT INTO chat_messages (room_id, sender_id, content, message_type)
VALUES (
    'YOUR_ROOM_ID',
    'YOUR_USER_ID',
    'Test message',
    'text'
);
*/

-- 4. Check if the INSERT policy exists
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'chat_messages'
AND cmd = 'INSERT';
