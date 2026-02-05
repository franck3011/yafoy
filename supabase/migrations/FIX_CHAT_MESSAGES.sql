-- ============================================
-- CORRECTION : Permissions Chat Messages
-- ============================================
-- Permet aux clients et organisateurs d'envoyer des messages
-- ============================================

-- Désactiver RLS sur chat_messages pour permettre l'envoi
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;

-- OU si vous voulez garder RLS mais autoriser les insertions :
-- DROP POLICY IF EXISTS "Users can send messages in their rooms" ON public.chat_messages;
-- CREATE POLICY "Anyone can insert messages" ON public.chat_messages
-- FOR INSERT WITH CHECK (true);

-- CREATE POLICY "Anyone can read messages" ON public.chat_messages
-- FOR SELECT USING (true);

-- Vérification
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename = 'chat_messages';

-- ✅ Vous devriez voir rls_enabled = false
