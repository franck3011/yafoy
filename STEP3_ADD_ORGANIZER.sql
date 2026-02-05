-- ============================================
-- STEP 3: Check and Add Organizer
-- Execute this AFTER Step 2
-- ============================================

-- First, find all users (with email from auth.users)
SELECT p.user_id, au.email, p.full_name 
FROM profiles p
JOIN auth.users au ON p.user_id = au.id
ORDER BY p.created_at DESC 
LIMIT 10;

-- Check if any organizers exist
SELECT p.user_id, p.full_name, au.email
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
JOIN auth.users au ON p.user_id = au.id
WHERE ur.role = 'organizer';

-- If no organizer exists, add the role to YOUR user
-- Replace 'your_email@example.com' with your actual email
-- Then uncomment and run:

-- INSERT INTO user_roles (user_id, role) 
-- SELECT p.user_id, 'organizer'
-- FROM profiles p
-- JOIN auth.users au ON p.user_id = au.id
-- WHERE au.email = 'your_email@example.com'
-- ON CONFLICT (user_id, role) DO NOTHING;

-- Verify organizer was added
SELECT p.user_id, p.full_name, au.email
FROM profiles p
JOIN user_roles ur ON p.user_id = ur.user_id
JOIN auth.users au ON p.user_id = au.id
WHERE ur.role = 'organizer';
