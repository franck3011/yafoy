-- ============================================
-- SCRIPT SIMPLIFIÉ : Configuration Organisateurs
-- ============================================
-- Copiez-collez CE SCRIPT UNIQUE dans Supabase SQL Editor
-- Il fait TOUT automatiquement en une seule fois
-- ============================================

-- IMPORTANT : Avant d'exécuter ce script :
-- 1. Allez sur https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/auth/users
-- 2. Créez MANUELLEMENT les 2 utilisateurs :
--    - organisateur1@gmail.com / 0103509662 (cochez "Auto Confirm User")
--    - organisateur2@gmail.com / 0103509662 (cochez "Auto Confirm User")
-- 3. Puis exécutez ce script ci-dessous

-- ============================================
-- ÉTAPE 1 : Ajouter 'organizer' à l'ENUM
-- ============================================
DO $$ 
BEGIN
    -- Vérifier si 'organizer' existe déjà
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e
        JOIN pg_type t ON e.enumtypid = t.oid
        WHERE t.typname = 'user_role' AND e.enumlabel = 'organizer'
    ) THEN
        ALTER TYPE user_role ADD VALUE 'organizer';
        RAISE NOTICE '✅ Valeur organizer ajoutée à user_role';
    ELSE
        RAISE NOTICE 'ℹ️ organizer existe déjà dans user_role';
    END IF;
END $$;

-- ============================================
-- ÉTAPE 2 : Créer profils et assigner rôles
-- ============================================
DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupération des IDs
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Vérification
  IF org1_id IS NULL THEN
    RAISE WARNING '❌ organisateur1@gmail.com non trouvé - créez-le dans le Dashboard d''abord !';
  END IF;
  
  IF org2_id IS NULL THEN
    RAISE WARNING '❌ organisateur2@gmail.com non trouvé - créez-le dans le Dashboard d''abord !';
  END IF;

  -- Configuration Organisateur 1
  IF org1_id IS NOT NULL THEN
    -- Profil
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org1_id, 'Organisateur Chef 1')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 1';
    
    -- Rôle
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org1_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE '✅ Organisateur 1 (organisateur1@gmail.com) configuré !';
  END IF;

  -- Configuration Organisateur 2
  IF org2_id IS NOT NULL THEN
    -- Profil
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org2_id, 'Organisateur Chef 2')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 2';
    
    -- Rôle
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org2_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE '✅ Organisateur 2 (organisateur2@gmail.com) configuré !';
  END IF;
END $$;

-- ============================================
-- ÉTAPE 3 : Vérification finale
-- ============================================
SELECT 
    u.email,
    p.full_name,
    ur.role,
    u.email_confirmed_at IS NOT NULL as "confirmé"
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.user_id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email LIKE 'organisateur%@gmail.com'
ORDER BY u.email;

-- ============================================
-- RÉSULTAT ATTENDU :
-- Vous devriez voir 2 lignes avec :
-- - email: organisateur1@gmail.com / organisateur2@gmail.com
-- - full_name: Organisateur Chef 1 / Organisateur Chef 2
-- - role: organizer
-- - confirmé: true
-- ============================================
