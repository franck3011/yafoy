-- ============================================
-- SOLUTION COMPLÈTE: Désactiver RLS sur chat_messages
-- ============================================
-- Ceci permet à la fois l'envoi ET la réception des messages
-- ============================================

-- Désactiver RLS sur chat_messages (si pas déjà fait)
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- Désactiver aussi sur chat_rooms pour que tout le monde voit les rooms
ALTER TABLE public.chat_rooms DISABLE ROW LEVEL SECURITY;

-- Vérifier que c'est désactivé
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename IN ('chat_messages', 'chat_rooms')
ORDER BY tablename;
-- Expected: rls_enabled = false pour les deux tables
