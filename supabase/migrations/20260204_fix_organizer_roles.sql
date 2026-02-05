-- Script de correction pour assigner les rôles aux utilisateurs existants
DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupérer les IDs des utilisateurs existants
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Correction pour Organisateur 1
  IF org1_id IS NOT NULL THEN
    -- S'assurer que le profil existe
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = org1_id) THEN
      INSERT INTO public.profiles (user_id, full_name) VALUES (org1_id, 'Organisateur Chef 1');
    END IF;

    -- S'assurer que le rôle existe
    IF NOT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = org1_id AND role = 'organizer') THEN
      INSERT INTO public.user_roles (user_id, role) VALUES (org1_id, 'organizer');
      RAISE NOTICE 'Rôle assigné à Organisateur 1';
    ELSE
      RAISE NOTICE 'Organisateur 1 a déjà le rôle';
    END IF;
  ELSE
    RAISE NOTICE 'Compte Organisateur 1 introuvable - Créez-le d''abord';
  END IF;

  -- Correction pour Organisateur 2
  IF org2_id IS NOT NULL THEN
    -- S'assurer que le profil existe
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = org2_id) THEN
      INSERT INTO public.profiles (user_id, full_name) VALUES (org2_id, 'Organisateur Chef 2');
    END IF;

    -- S'assurer que le rôle existe
    IF NOT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = org2_id AND role = 'organizer') THEN
      INSERT INTO public.user_roles (user_id, role) VALUES (org2_id, 'organizer');
      RAISE NOTICE 'Rôle assigné à Organisateur 2';
    ELSE
      RAISE NOTICE 'Organisateur 2 a déjà le rôle';
    END IF;
  ELSE
    RAISE NOTICE 'Compte Organisateur 2 introuvable - Créez-le d''abord';
  END IF;
END $$;
