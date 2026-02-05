-- ============================================
-- FIX: Ajouter l'organisateur aux rooms manquantes
-- ============================================

-- 1. Voir toutes les rooms et leurs participants
SELECT 
    cr.id as room_id,
    cr.name,
    COUNT(DISTINCT crp.user_id) as participant_count,
    COUNT(cm.id) as message_count,
    STRING_AGG(DISTINCT crp.role, ', ') as roles_present
FROM chat_rooms cr
LEFT JOIN chat_room_participants crp ON crp.room_id = cr.id
LEFT JOIN chat_messages cm ON cm.room_id = cr.id
GROUP BY cr.id, cr.name
ORDER BY cr.created_at DESC;

-- 2. Ajouter l'organisateur à la room avec des messages
-- Room ID: 2bf276f2-7522-4596-915e-d6be4444f427
-- Organizer ID: abfe44e1-7691-4ad0-87f8-30d781a6ea95

INSERT INTO chat_room_participants (room_id, user_id, role)
VALUES (
    '2bf276f2-7522-4596-915e-d6be4444f427',
    'abfe44e1-7691-4ad0-87f8-30d781a6ea95',
    'organizer'
)
ON CONFLICT (room_id, user_id) DO NOTHING;

-- 3. Vérifier que l'organisateur est maintenant dans cette room
SELECT 
    crp.room_id,
    crp.user_id,
    crp.role,
    p.full_name
FROM chat_room_participants crp
LEFT JOIN profiles p ON p.user_id = crp.user_id
WHERE crp.room_id = '2bf276f2-7522-4596-915e-d6be4444f427';
