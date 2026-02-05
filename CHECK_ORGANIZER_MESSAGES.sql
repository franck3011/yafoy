-- ============================================
-- DIAGNOSTIC: Vérifier la visibilité des conversations pour l'organisateur
-- ============================================

-- 1. Trouver l'ID de l'organisateur
SELECT p.user_id, p.full_name, au.email
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
JOIN auth.users au ON p.user_id = au.id
WHERE ur.role = 'organizer';

-- 2. Voir tous les chat rooms où l'organisateur est participant
-- Remplacez 'ORGANIZER_USER_ID' par l'ID trouvé ci-dessus
SELECT 
    cr.id as room_id,
    cr.name as room_name,
    cr.created_at,
    COUNT(cm.id) as message_count
FROM chat_rooms cr
JOIN chat_room_participants crp ON crp.room_id = cr.id
LEFT JOIN chat_messages cm ON cm.room_id = cr.id
WHERE crp.user_id = 'ORGANIZER_USER_ID'  -- Remplacez ici
GROUP BY cr.id, cr.name, cr.created_at
ORDER BY cr.created_at DESC;

-- 3. Pour un chat room spécifique, voir tous les messages
-- Remplacez 'ROOM_ID' par un ID de la requête précédente
SELECT 
    cm.id,
    cm.content,
    cm.created_at,
    p.full_name as sender_name,
    crp.role as sender_role
FROM chat_messages cm
JOIN profiles p ON p.user_id = cm.sender_id
JOIN chat_room_participants crp ON crp.user_id = cm.sender_id AND crp.room_id = cm.room_id
WHERE cm.room_id = 'ROOM_ID'  -- Remplacez ici
ORDER BY cm.created_at ASC;

-- 4. Vérifier si l'organisateur peut voir les messages (RLS)
-- Cette requête simule ce que voit l'organisateur
SELECT 
    cm.id,
    cm.content,
    cm.sender_id,
    cm.created_at
FROM chat_messages cm
WHERE EXISTS (
    SELECT 1 FROM chat_room_participants crp
    WHERE crp.room_id = cm.room_id
    AND crp.user_id = 'ORGANIZER_USER_ID'  -- Remplacez ici
)
ORDER BY cm.created_at DESC
LIMIT 20;
