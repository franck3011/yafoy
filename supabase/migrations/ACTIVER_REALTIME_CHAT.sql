-- ============================================
-- ACTIVER REALTIME sur chat_messages
-- ============================================
-- Permet la mise à jour en temps réel des messages
-- ============================================

-- 1. Activer Realtime sur la table chat_messages
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- 2. Vérifier que Realtime est activé
SELECT 
    schemaname,
    tablename,
    pubname
FROM pg_publication_tables
WHERE tablename = 'chat_messages';

-- ✅ Vous devriez voir une ligne avec pubname = 'supabase_realtime'

-- 3. Optionnel : Activer aussi sur chat_rooms et chat_room_participants
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_room_participants;
