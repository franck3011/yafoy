-- ============================================
-- TEST: Fonction RPC add_chat_room_participants
-- ============================================

-- 1. Vérifier que la fonction existe
SELECT 
    routine_name,
    routine_type,
    security_type,
    data_type
FROM information_schema.routines
WHERE routine_name = 'add_chat_room_participants';

-- 2. Tester la fonction avec des données fictives
-- D'abord, créez un chat room de test
INSERT INTO chat_rooms (name, created_by)
VALUES ('Test Room', auth.uid())
RETURNING id;

-- Copiez l'ID retourné ci-dessus et remplacez 'TEST_ROOM_ID' ci-dessous
-- Remplacez aussi 'YOUR_USER_ID' par votre user_id

-- 3. Tester l'ajout de participants via RPC
/*
SELECT add_chat_room_participants(
    'TEST_ROOM_ID'::uuid,
    '[
        {"user_id": "YOUR_USER_ID", "role": "client"},
        {"user_id": "ORGANIZER_USER_ID", "role": "organizer"}
    ]'::jsonb
);
*/

-- 4. Vérifier que les participants ont été ajoutés
/*
SELECT * FROM chat_room_participants 
WHERE room_id = 'TEST_ROOM_ID';
*/

-- 5. Tester si is_chat_room_participant fonctionne
/*
SELECT public.is_chat_room_participant('TEST_ROOM_ID'::uuid, 'YOUR_USER_ID'::uuid);
*/

-- 6. Nettoyer le test
/*
DELETE FROM chat_room_participants WHERE room_id = 'TEST_ROOM_ID';
DELETE FROM chat_rooms WHERE id = 'TEST_ROOM_ID';
*/
