-- Mettre à jour les mots de passe des organisateurs
-- Mot de passe: 0103509662

UPDATE auth.users
SET encrypted_password = crypt('0103509662', gen_salt('bf')),
    email_confirmed_at = now(),
    updated_at = now()
WHERE email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com');

-- Vérifier le résultat
SELECT email, encrypted_password, email_confirmed_at 
FROM auth.users 
WHERE email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com');
