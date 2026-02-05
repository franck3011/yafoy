-- Étape 1 : Vérifier les valeurs actuelles de l'ENUM user_role
SELECT enumlabel 
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid 
WHERE pg_type.typname = 'user_role';
