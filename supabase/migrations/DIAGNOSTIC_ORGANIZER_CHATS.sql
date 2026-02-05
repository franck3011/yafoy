-- ============================================
-- DIAGNOSTIC COMPLET - CONVERSATIONS ORGANISATEURS
-- ============================================
-- Ce script vérifie pourquoi le dashboard organisateur
-- n'affiche pas les conversations
-- ============================================

-- ============================================
-- PARTIE 1: VÉRIFICATION DES ORGANISATEURS
-- ============================================

SELECT '=== PARTIE 1: ORGANISATEURS DANS LE SYSTÈME ===' as section;

-- 1.1 Liste des organisateurs
SELECT 
    'Organisateurs' as type,
    u.id,
    u.email,
    p.full_name,
    ur.role,
    u.created_at
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.user_id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE ur.role = 'organizer'
ORDER BY u.created_at DESC;

-- ============================================
-- PARTIE 2: ATTRIBUTIONS CLIENT-ORGANISATEUR
-- ============================================

SELECT '=== PARTIE 2: ATTRIBUTIONS CLIENT-ORGANISATEUR ===' as section;

-- 2.1 Toutes les attributions actives
SELECT 
    'Attributions actives' as type,
    coa.id as attribution_id,
    coa.client_id,
    client_p.full_name as client_name,
    client_u.email as client_email,
    coa.organizer_id,
    org_p.full_name as organizer_name,
    org_u.email as organizer_email,
    coa.status,
    coa.assigned_at
FROM public.client_organizer_assignments coa
LEFT JOIN auth.users client_u ON coa.client_id = client_u.id
LEFT JOIN public.profiles client_p ON coa.client_id = client_p.user_id
LEFT JOIN auth.users org_u ON coa.organizer_id = org_u.id
LEFT JOIN public.profiles org_p ON coa.organizer_id = org_p.user_id
WHERE coa.status = 'active'
ORDER BY coa.assigned_at DESC;

-- ============================================
-- PARTIE 3: ROOMS DE CHAT
-- ============================================

SELECT '=== PARTIE 3: ROOMS DE CHAT EXISTANTES ===' as section;

-- 3.1 Toutes les rooms de chat
SELECT 
    'Rooms de chat' as type,
    cr.id as room_id,
    cr.name as room_name,
    cr.created_at,
    COUNT(DISTINCT crp.user_id) as participant_count
FROM public.chat_rooms cr
LEFT JOIN public.chat_room_participants crp ON cr.id = crp.room_id
GROUP BY cr.id, cr.name, cr.created_at
ORDER BY cr.created_at DESC;

-- ============================================
-- PARTIE 4: PARTICIPANTS DES ROOMS
-- ============================================

SELECT '=== PARTIE 4: PARTICIPANTS DES ROOMS DE CHAT ===' as section;

-- 4.1 Détails des participants pour chaque room
SELECT 
    'Participants' as type,
    cr.name as room_name,
    crp.room_id,
    crp.user_id,
    p.full_name,
    u.email,
    crp.role as role_in_room,
    ur.role as user_role
FROM public.chat_room_participants crp
JOIN public.chat_rooms cr ON crp.room_id = cr.id
LEFT JOIN auth.users u ON crp.user_id = u.id
LEFT JOIN public.profiles p ON crp.user_id = p.user_id
LEFT JOIN public.user_roles ur ON crp.user_id = ur.user_id
ORDER BY cr.name, crp.role;

-- ============================================
-- PARTIE 5: VÉRIFICATION DES PERMISSIONS RLS
-- ============================================

SELECT '=== PARTIE 5: STATUS DES PERMISSIONS RLS ===' as section;

-- 5.1 Status RLS sur les tables critiques
SELECT 
    'RLS Status' as type,
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
AND tablename IN (
    'chat_rooms',
    'chat_room_participants',
    'chat_messages',
    'client_organizer_assignments',
    'user_roles',
    'profiles'
)
ORDER BY tablename;

-- ============================================
-- PARTIE 6: REQUÊTE SIMULÉE DU COMPOSANT
-- ============================================

SELECT '=== PARTIE 6: TEST DE LA REQUÊTE DU COMPOSANT ===' as section;

-- 6.1 Pour chaque organisateur, simuler la requête du composant OrganizerChatSection
-- Cette requête devrait retourner les rooms comme le fait le composant

WITH organizer_users AS (
    SELECT user_id 
    FROM public.user_roles 
    WHERE role = 'organizer'
)
SELECT 
    'Requête composant' as type,
    org.user_id as organizer_id,
    org_p.full_name as organizer_name,
    crp.room_id,
    cr.name as room_name,
    cr.created_at as room_created_at
FROM organizer_users org
LEFT JOIN public.profiles org_p ON org.user_id = org_p.user_id
LEFT JOIN public.chat_room_participants crp ON crp.user_id = org.user_id
LEFT JOIN public.chat_rooms cr ON cr.id = crp.room_id
ORDER BY org.user_id, cr.created_at DESC;

-- ============================================
-- PARTIE 7: DIAGNOSTIC DES PROBLÈMES
-- ============================================

SELECT '=== PARTIE 7: RÉSUMÉ DU DIAGNOSTIC ===' as section;

-- 7.1 Compter les éléments clés
SELECT 
    'Résumé' as type,
    (SELECT COUNT(*) FROM public.user_roles WHERE role = 'organizer') as nb_organisateurs,
    (SELECT COUNT(*) FROM public.client_organizer_assignments WHERE status = 'active') as nb_attributions_actives,
    (SELECT COUNT(*) FROM public.chat_rooms) as nb_rooms_total,
    (SELECT COUNT(DISTINCT crp.room_id) 
     FROM public.chat_room_participants crp
     JOIN public.user_roles ur ON crp.user_id = ur.user_id
     WHERE ur.role = 'organizer') as nb_rooms_avec_organisateurs,
    (SELECT COUNT(*) FROM public.chat_messages) as nb_messages_total;

-- ============================================
-- FIN DU DIAGNOSTIC
-- ============================================
