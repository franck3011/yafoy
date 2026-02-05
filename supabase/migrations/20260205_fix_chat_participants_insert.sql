-- ============================================
-- FIX: Disable RLS on chat_room_participants
-- ============================================
-- Problem: 400 error when inserting participants
-- The RLS policies are too restrictive
-- Solution: Disable RLS to allow insertions
-- ============================================

ALTER TABLE public.chat_room_participants DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'chat_room_participants';

