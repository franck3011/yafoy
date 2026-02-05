# 🔑 Guide: Créer les Comptes Organisateurs (Méthode Manuelle Garantie)

## ⚠️ Pourquoi cette méthode ?
Les scripts SQL automatiques ont échoué à cause du hashage de mot de passe. La création manuelle via le Dashboard garantit que Supabase gère correctement l'authentification.

---

## 📋 Étape 1 : Créer les utilisateurs dans le Dashboard

1. Ouvrez votre navigateur et allez sur :
   ```
   https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/auth/users
   ```

2. Cliquez sur le bouton **"Add user"** en haut à droite

3. Sélectionnez **"Create new user"**

4. Remplissez pour l'**Organisateur 1** :
   - **Email**: `organisateur1@gmail.com`
   - **Password**: `0103509662`
   - ✅ **Cochez "Auto Confirm User"** (très important !)
   - Cliquez sur **"Create user"**

5. Répétez l'opération pour l'**Organisateur 2** :
   - **Email**: `organisateur2@gmail.com`
   - **Password**: `0103509662`
   - ✅ **Cochez "Auto Confirm User"**
   - Cliquez sur **"Create user"**

---

## 📋 Étape 2 : Assigner les rôles via SQL

Une fois les 2 comptes créés, allez dans **SQL Editor** et exécutez ce script :

```sql
-- Assigner les rôles et créer les profils
DO $$
DECLARE
  org1_id uuid;
  org2_id uuid;
BEGIN
  -- Récupérer les IDs des utilisateurs créés manuellement
  SELECT id INTO org1_id FROM auth.users WHERE email = 'organisateur1@gmail.com';
  SELECT id INTO org2_id FROM auth.users WHERE email = 'organisateur2@gmail.com';

  -- Organisateur 1
  IF org1_id IS NOT NULL THEN
    -- Créer/Mettre à jour le profil
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org1_id, 'Organisateur Chef 1')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 1';
    
    -- Assigner le rôle
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org1_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE 'Organisateur 1 configuré avec succès';
  ELSE
    RAISE NOTICE 'ERREUR: Organisateur 1 non trouvé - créez-le via le Dashboard d''abord';
  END IF;

  -- Organisateur 2
  IF org2_id IS NOT NULL THEN
    -- Créer/Mettre à jour le profil
    INSERT INTO public.profiles (user_id, full_name) 
    VALUES (org2_id, 'Organisateur Chef 2')
    ON CONFLICT (user_id) DO UPDATE SET full_name = 'Organisateur Chef 2';
    
    -- Assigner le rôle
    INSERT INTO public.user_roles (user_id, role) 
    VALUES (org2_id, 'organizer')
    ON CONFLICT (user_id, role) DO NOTHING;
    
    RAISE NOTICE 'Organisateur 2 configuré avec succès';
  ELSE
    RAISE NOTICE 'ERREUR: Organisateur 2 non trouvé - créez-le via le Dashboard d''abord';
  END IF;
END $$;
```

---

## 📋 Étape 3 : Tester la connexion

1. Allez sur votre application : `http://localhost:8080`
2. Cliquez sur "Se connecter"
3. Utilisez :
   - **Email**: `organisateur1@gmail.com`
   - **Mot de passe**: `0103509662`

Si cela ne fonctionne toujours pas, c'est que l'utilisateur n'a pas été créé correctement dans le Dashboard.

---

## ❓ Dépannage

Si après avoir créé les utilisateurs manuellement la connexion échoue encore :

1. Vérifiez dans **Authentication > Users** que les emails sont bien listés
2. Vérifiez que la colonne "Confirmed At" a une date (pas vide)
3. Si "Confirmed At" est vide, cliquez sur l'utilisateur et cochez manuellement "Email Confirmed"

---

## ✅ Comment savoir que ça marche ?

Une fois connecté, l'organisateur devrait voir son nom en haut à droite de l'interface et avoir accès aux conversations des clients qui font des réservations.
