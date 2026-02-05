-- 1. Créer les utilisateurs dans auth.users
-- Note: On utilise une fonction pour créer l'utilisateur s'il n'existe pas
DO $$
DECLARE
  org1_id uuid := gen_random_uuid();
  org2_id uuid := gen_random_uuid();
  org1_email text := 'organisateur1@gmail.com';
  org2_email text := 'organisateur2@gmail.com';
  password_hash text := crypt('0103509662', gen_salt('bf'));
BEGIN
  -- Organisateur 1
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = org1_email) THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      aud,
      role
    ) VALUES (
      org1_id,
      '00000000-0000-0000-0000-000000000000',
      org1_email,
      password_hash,
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Organisateur Chef 1","role":"organizer"}',
      'authenticated',
      'authenticated'
    );
    
    -- Créer le profil
    INSERT INTO public.profiles (user_id, full_name)
    VALUES (org1_id, 'Organisateur Chef 1');
    
    -- Assigner le rôle
    INSERT INTO public.user_roles (user_id, role)
    VALUES (org1_id, 'organizer');
    
    RAISE NOTICE 'Organisateur 1 créé avec succès';
  ELSE
    RAISE NOTICE 'Organisateur 1 existe déjà';
  END IF;

  -- Organisateur 2
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = org2_email) THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      aud,
      role
    ) VALUES (
      org2_id,
      '00000000-0000-0000-0000-000000000000',
      org2_email,
      password_hash,
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Organisateur Chef 2","role":"organizer"}',
      'authenticated',
      'authenticated'
    );
    
    -- Créer le profil
    INSERT INTO public.profiles (user_id, full_name)
    VALUES (org2_id, 'Organisateur Chef 2');
    
    -- Assigner le rôle
    INSERT INTO public.user_roles (user_id, role)
    VALUES (org2_id, 'organizer');
    
    RAISE NOTICE 'Organisateur 2 créé avec succès';
  ELSE
    RAISE NOTICE 'Organisateur 2 existe déjà';
  END IF;
END $$;
