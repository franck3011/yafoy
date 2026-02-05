-- ============================================
-- NETTOYAGE: Supprimer les anciennes rooms et recommencer
-- ============================================

-- 1. Voir toutes les rooms actuelles
SELECT 
    cr.id,
    cr.name,
    cr.created_at,
    COUNT(crp.user_id) as participant_count,
    COUNT(cm.id) as message_count
FROM chat_rooms cr
LEFT JOIN chat_room_participants crp ON crp.room_id = cr.id
LEFT JOIN chat_messages cm ON cm.room_id = cr.id
GROUP BY cr.id, cr.name, cr.created_at
ORDER BY cr.created_at DESC;

-- 2. Supprimer TOUTES les anciennes rooms pour repartir à zéro
DELETE FROM chat_messages WHERE room_id IN (SELECT id FROM chat_rooms);
DELETE FROM chat_room_participants WHERE room_id IN (SELECT id FROM chat_rooms);
DELETE FROM chat_rooms;

-- 3. Vérifier que tout est supprimé
SELECT COUNT(*) as remaining_rooms FROM chat_rooms;
SELECT COUNT(*) as remaining_participants FROM chat_room_participants;
SELECT COUNT(*) as remaining_messages FROM chat_messages;
