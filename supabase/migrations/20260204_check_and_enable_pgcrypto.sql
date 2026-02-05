-- Activer l'extension nécessaire pour le hashage des mots de passe
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Vérifier si les utilisateurs existent
SELECT id, email, role, email_confirmed_at FROM auth.users WHERE email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com');

-- Vérifier les rôles
SELECT * FROM public.user_roles WHERE user_id IN (
  SELECT id FROM auth.users WHERE email IN ('organisateur1@gmail.com', 'organisateur2@gmail.com')
);
