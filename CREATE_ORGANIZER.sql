-- ============================================
-- CREATE ORGANIZER USER
-- Execute this in Supabase Dashboard SQL Editor
-- ============================================

-- First, check if you already have an organizer user
SELECT 
    p.user_id,
    p.full_name,
    p.email,
    ur.role
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
WHERE ur.role = 'organizer';

-- If no organizer exists, you need to:
-- 1. Create a user account via Supabase Auth (Dashboard > Authentication > Users > Add User)
--    OR sign up normally on your app
-- 2. Get the user_id from that new account
-- 3. Then run this (replace YOUR_USER_ID with the actual UUID):

-- INSERT INTO user_roles (user_id, role) 
-- VALUES ('YOUR_USER_ID', 'organizer')
-- ON CONFLICT (user_id, role) DO NOTHING;

-- Verify the organizer was added
SELECT 
    p.user_id,
    p.full_name,
    p.email,
    ur.role
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
WHERE ur.role = 'organizer';
