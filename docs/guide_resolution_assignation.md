# 🔧 Guide de Résolution : Assignation des Organisateurs

## Problème
L'assignation des organisateurs ne fonctionne pas car :
1. L'ENUM `user_role` ne contient pas la valeur 'organizer'
2. Les comptes organisateurs n'ont donc pas pu recevoir leur rôle

## Solution (Ordre strict à respecter)

### Étape 1 : Vérifier les valeurs de l'ENUM
Exécutez dans Supabase SQL Editor :
```sql
SELECT enumlabel 
FROM pg_enum 
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid 
WHERE pg_type.typname = 'user_role'
ORDER BY enumsortorder;
```

**Résultat attendu** : Vous devriez voir les valeurs existantes (probablement 'client', 'provider', 'admin', etc.)

---

### Étape 2 : Ajouter 'organizer' à l'ENUM
Exécutez le script `supabase/migrations/20260204_add_organizer_to_enum.sql` :
```sql
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'organizer';
```

---

### Étape 3 : Créer les comptes organisateurs via Dashboard
1. Allez sur https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/auth/users
2. Cliquez "Add user" > "Create new user"
3. Pour **organisateur1@gmail.com** :
   - Email: `organisateur1@gmail.com`
   - Password: `0103509662`
   - ✅ Cochez "Auto Confirm User"
4. Répétez pour **organisateur2@gmail.com**

---

### Étape 4 : Assigner les rôles
Exécutez ce script SQL (qui utilise maintenant la valeur 'organizer' ajoutée) :
```sql
DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupérer les IDs
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Organisateur 1
  IF org1_id IS NOT NULL THEN
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org1_id, 'Organisateur Chef 1')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 1';
    
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org1_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE 'Organisateur 1 configuré avec succès';
  END IF;

  -- Organisateur 2
  IF org2_id IS NOT NULL THEN
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org2_id, 'Organisateur Chef 2')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 2';
    
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org2_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE 'Organisateur 2 configuré avec succès';
  END IF;
END $$;
```

---

### Étape 5 : Vérification
Vérifiez que tout fonctionne :
```sql
-- Vérifier les organisateurs
SELECT u.email, ur.role, p.full_name
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
LEFT JOIN public.profiles p ON u.id = p.user_id
WHERE ur.role = 'organizer';
```

**Résultat attendu** : Vous devriez voir 2 lignes (organisateur1 et organisateur2)

---

### Étape 6 : Test
1. Déconnectez-vous de l'application
2. Créez une nouvelle réservation en tant que client
3. Vérifiez dans la console du navigateur (F12) les logs :
   ```
   Client xxx assigné à l'organisateur yyy
   ```
4. Vérifiez dans Supabase > Table `client_organizer_assignments` :
   ```sql
   SELECT * FROM client_organizer_assignments ORDER BY assigned_at DESC LIMIT 10;
   ```

---

## En cas d'échec persistant

Si après toutes ces étapes l'assignation échoue toujours, exécutez ce script de diagnostic :
```sql
-- Diagnostic complet
SELECT 'Organisateurs avec rôle' as check_type, count(*) as count
FROM public.user_roles WHERE role = 'organizer'
UNION ALL
SELECT 'Comptes organisateurs', count(*)
FROM auth.users WHERE email LIKE 'organisateur%@gmail.com'
UNION ALL
SELECT 'Assignations actives', count(*)
FROM public.client_organizer_assignments WHERE status = 'active';
```

Et partagez-moi le résultat.
