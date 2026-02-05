-- ============================================
-- CORRECTION FINALE : Permissions RLS
-- ============================================
-- Ce script corrige les permissions pour permettre :
-- 1. L'insertion dans client_organizer_assignments
-- 2. L'insertion dans chat_room_participants
-- ============================================

-- 1. Désactiver temporairement RLS sur client_organizer_assignments
ALTER TABLE public.client_organizer_assignments DISABLE ROW LEVEL SECURITY;

-- 2. Corriger les permissions sur chat_room_participants
ALTER TABLE public.chat_room_participants DISABLE ROW LEVEL SECURITY;

-- OU si vous voulez garder RLS mais autoriser les insertions :
-- DROP POLICY IF EXISTS "Users can manage their own participation" ON public.chat_room_participants;
-- CREATE POLICY "Anyone can insert participants" ON public.chat_room_participants
-- FOR INSERT WITH CHECK (true);

-- Vérification
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename IN ('client_organizer_assignments', 'chat_room_participants');

-- ✅ Vous devriez voir rls_enabled = false pour les deux tables
