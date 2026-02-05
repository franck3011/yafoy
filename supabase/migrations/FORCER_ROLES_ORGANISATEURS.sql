-- ============================================
-- FORCER L'INSERTION DES RÔLES ORGANISATEURS
-- ============================================
-- Ce script insère directement sans conditions

DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupération des IDs
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Supprimer les rôles existants pour ces utilisateurs (si conflit)
  DELETE FROM public.user_roles WHERE user_id IN (org1_id, org2_id);

  -- Insérer les rôles
  IF org1_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org1_id, 'organizer');
    RAISE NOTICE '✅ Rôle assigné à organisateur1';
  END IF;

  IF org2_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org2_id, 'organizer');
    RAISE NOTICE '✅ Rôle assigné à organisateur2';
  END IF;
END $$;

-- Vérification immédiate
SELECT 
  u.email,
  ur.role,
  p.full_name
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
LEFT JOIN public.profiles p ON u.id = p.user_id
WHERE u.email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com');

-- ✅ Vous devriez maintenant voir role = 'organizer' au lieu de NULL
