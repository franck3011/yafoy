-- ============================================
-- DIAGNOSTIC: Vérifier les participants du chat
-- ============================================

-- 1. Voir tous les chat rooms récents
SELECT 
    id,
    name,
    created_by,
    created_at
FROM chat_rooms
ORDER BY created_at DESC
LIMIT 5;

-- 2. Pour un chat room spécifique, voir tous les participants
-- Remplacez 'ROOM_ID_HERE' par l'ID du chat room que vous testez
SELECT 
    crp.room_id,
    crp.user_id,
    crp.role,
    p.full_name,
    au.email
FROM chat_room_participants crp
LEFT JOIN profiles p ON p.user_id = crp.user_id
LEFT JOIN auth.users au ON au.id = crp.user_id
-- WHERE crp.room_id = 'ROOM_ID_HERE'  -- Décommentez et remplacez
ORDER BY crp.role;

-- 3. Tester la fonction is_chat_room_participant
-- Remplacez les valeurs et décommentez pour tester
-- SELECT public.is_chat_room_participant('ROOM_ID_HERE', 'USER_ID_HERE');

-- 4. Vérifier si la fonction RPC existe
SELECT routine_name, security_type
FROM information_schema.routines
WHERE routine_name = 'add_chat_room_participants';
