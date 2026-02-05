-- ============================================
-- FIX: Ajouter le rôle organizer au BON compte
-- ============================================

-- 1. Vérifier quel compte a le rôle organizer actuellement
SELECT p.user_id, p.full_name, au.email, ur.role
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
JOIN auth.users au ON p.user_id = au.id
WHERE ur.role = 'organizer';

-- 2. Ajouter le rôle organizer au compte assigné par le système
-- ID: 5644eb86-265e-4b55-9bcd-8a966b987b14
INSERT INTO user_roles (user_id, role)
VALUES ('5644eb86-265e-4b55-9bcd-8a966b987b14', 'organizer')
ON CONFLICT (user_id, role) DO NOTHING;

-- 3. Vérifier que les deux comptes ont maintenant le rôle organizer
SELECT p.user_id, p.full_name, au.email, ur.role
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
JOIN auth.users au ON p.user_id = au.id
WHERE ur.role = 'organizer'
ORDER BY p.created_at;

-- 4. Voir quel compte est dans la table client_organizer_assignments
SELECT 
    coa.client_id,
    coa.organizer_id,
    coa.assigned_at,
    p.full_name as organizer_name
FROM client_organizer_assignments coa
LEFT JOIN profiles p ON p.user_id = coa.organizer_id
ORDER BY coa.assigned_at DESC
LIMIT 5;
