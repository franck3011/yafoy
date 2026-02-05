-- ============================================
-- SCRIPT ULTRA-SIMPLIFIÉ : Organisateurs
-- ============================================
-- Pas besoin d'ENUM ! La colonne 'role' est TEXT
-- ============================================

-- AVANT D'EXÉCUTER :
-- 1. Créez les 2 utilisateurs dans Dashboard Supabase :
--    https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/auth/users
--    - organisateur1@gmail.com / 0103509662 (✅ Auto Confirm User)
--    - organisateur2@gmail.com / 0103509662 (✅ Auto Confirm User)
-- 2. Puis exécutez ce script

DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupération des IDs
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Vérifications
  IF org1_id IS NULL THEN
    RAISE WARNING '❌ organisateur1@gmail.com introuvable - créez-le d''abord !';
    RETURN;
  END IF;
  
  IF org2_id IS NULL THEN
    RAISE WARNING '❌ organisateur2@gmail.com introuvable - créez-le d''abord !';
    RETURN;
  END IF;

  -- Organisateur 1
  INSERT INTO public.profiles (user_id, full_name) 
  VALUES (org1_id, 'Organisateur Chef 1')
  ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 1';
  
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (org1_id, 'organizer')
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RAISE NOTICE '✅ Organisateur 1 configuré !';

  -- Organisateur 2
  INSERT INTO public.profiles (user_id, full_name) 
  VALUES (org2_id, 'Organisateur Chef 2')
  ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 2';
  
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (org2_id, 'organizer')
  ON CONFLICT (user_id, role) DO NOTHING;
  
  RAISE NOTICE '✅ Organisateur 2 configuré !';
END $$;

-- Vérification
SELECT 
    u.email,
    p.full_name,
    ur.role
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.user_id
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com');

-- ✅ Vous devriez voir 2 lignes avec role = 'organizer'
