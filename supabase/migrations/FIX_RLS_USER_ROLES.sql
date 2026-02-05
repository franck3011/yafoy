-- ============================================
-- CORRECTION RLS pour user_roles
-- ============================================
-- Ce script désactive temporairement RLS pour permettre 
-- la lecture des organisateurs
-- ============================================

-- Désactiver RLS sur user_roles pour la lecture
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

-- Ou si vous voulez garder RLS mais autoriser la lecture :
-- DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
-- CREATE POLICY "Anyone can read user_roles" ON public.user_roles
-- FOR SELECT USING (true);

-- Vérification
SELECT 
    ur.user_id,
    ur.role,
    u.email,
    p.full_name
FROM public.user_roles ur
LEFT JOIN auth.users u ON ur.user_id = u.id
LEFT JOIN public.profiles p ON ur.user_id = p.user_id
WHERE ur.role = 'organizer';

-- Vous devriez voir les 2 organisateurs
