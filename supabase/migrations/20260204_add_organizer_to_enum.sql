-- Ajouter 'organizer' à l'ENUM user_role
-- IMPORTANT: Exécutez d'abord le script check_enum_values.sql pour voir les valeurs actuelles

-- Option 1: Si l'ENUM existe, ajouter la valeur 'organizer'
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'organizer';

-- Vérification
SELECT enumlabel 
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid 
WHERE pg_type.typname = 'user_role'
ORDER BY enumsortorder;
