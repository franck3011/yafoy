-- ============================================
-- VÉRIFICATION: Les messages sont-ils dans la bonne room ?
-- ============================================

-- 1. Voir le room_id de l'organisateur (d'après les logs: d68bd93d-6733-44e6-a1c7-e322a5c0e247)
SELECT 
    id,
    name,
    created_at
FROM chat_rooms
WHERE id = 'd68bd93d-6733-44e6-a1c7-e322a5c0e247';

-- 2. Voir TOUS les messages de cette room
SELECT 
    cm.id,
    cm.content,
    cm.sender_id,
    cm.created_at,
    p.full_name as sender_name
FROM chat_messages cm
LEFT JOIN profiles p ON p.user_id = cm.sender_id
WHERE cm.room_id = 'd68bd93d-6733-44e6-a1c7-e322a5c0e247'
ORDER BY cm.created_at DESC;

-- 3. Voir les participants de cette room
SELECT 
    crp.user_id,
    crp.role,
    p.full_name,
    au.email
FROM chat_room_participants crp
LEFT JOIN profiles p ON p.user_id = crp.user_id
LEFT JOIN auth.users au ON au.id = crp.user_id
WHERE crp.room_id = 'd68bd93d-6733-44e6-a1c7-e322a5c0e247';

-- 4. Voir TOUTES les rooms récentes et leurs messages
SELECT 
    cr.id as room_id,
    cr.name,
    COUNT(cm.id) as message_count,
    MAX(cm.created_at) as last_message_at
FROM chat_rooms cr
LEFT JOIN chat_messages cm ON cm.room_id = cr.id
GROUP BY cr.id, cr.name
ORDER BY cr.created_at DESC
LIMIT 10;
