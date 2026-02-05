-- SCRIPT DE DIAGNOSTIC COMPLET
-- Exécutez ce script et copiez-moi TOUT le résultat

-- 1. Vérifier si les utilisateurs existent
SELECT 'UTILISATEURS' as check_type, email, id, email_confirmed_at 
FROM auth.users 
WHERE email LIKE 'organisateur%@gmail.com';

-- 2. Vérifier les profils
SELECT 'PROFILS' as check_type, p.user_id, p.full_name
FROM public.profiles p
WHERE p.user_id IN (
  SELECT id FROM auth.users WHERE email LIKE 'organisateur%@gmail.com'
);

-- 3. Vérifier les rôles
SELECT 'ROLES' as check_type, ur.user_id, ur.role
FROM public.user_roles ur
WHERE ur.user_id IN (
  SELECT id FROM auth.users WHERE email LIKE 'organisateur%@gmail.com'
);

-- 4. Vérifier RLS sur user_roles
SELECT 'RLS_STATUS' as check_type, 
       relname as table_name,
       relrowsecurity as rls_enabled
FROM pg_class
WHERE relname = 'user_roles';

-- 5. Tout ensemble
SELECT 
  u.email,
  u.id as user_id,
  p.full_name,
  ur.role,
  u.email_confirmed_at IS NOT NULL as confirmed
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.user_id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email LIKE 'organisateur%@gmail.com';
