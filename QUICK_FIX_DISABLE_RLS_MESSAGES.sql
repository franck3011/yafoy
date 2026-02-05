-- ============================================
-- SOLUTION RAPIDE: Désactiver RLS sur chat_messages
-- ============================================
-- ATTENTION: Ceci désactive la sécurité sur les messages
-- À utiliser UNIQUEMENT pour tester et déboguer
-- ============================================

-- Désactiver RLS sur chat_messages
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- Vérifier que c'est désactivé
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'chat_messages';
-- Expected: rls_enabled = false

-- ============================================
-- Après avoir testé que les messages passent,
-- vous pourrez réactiver RLS et corriger les politiques
-- ============================================
