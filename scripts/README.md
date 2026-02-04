# Scripts

Ce dossier contient des scripts utilitaires pour la gestion du système.

## create-organizers.ts

Script pour créer les comptes des organisateurs chef dans Supabase.

### Prérequis

Vous devez avoir la clé service_role de Supabase. Pour l'obtenir :
1. Allez sur https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/settings/api
2. Copiez la clé "service_role" (secret)

### Utilisation

**Windows (PowerShell):**
```powershell
$env:SUPABASE_SERVICE_ROLE_KEY="votre_clé_service_role"
npx tsx scripts/create-organizers.ts
```

**Windows (CMD):**
```cmd
set SUPABASE_SERVICE_ROLE_KEY=votre_clé_service_role
npx tsx scripts/create-organizers.ts
```

**Linux/Mac:**
```bash
export SUPABASE_SERVICE_ROLE_KEY="votre_clé_service_role"
npx tsx scripts/create-organizers.ts
```

### Ce que fait le script

1. Crée 2 comptes organisateurs dans Supabase Auth
2. Crée leurs profils dans la table `profiles`
3. Leur assigne le rôle `organizer` dans `user_roles`
4. Affiche un résumé des opérations effectuées

### Comptes créés

- **Organisateur 1**: organisateur1@gmail.com (mot de passe: 0103509662)
- **Organisateur 2**: organisateur2@gmail.com (mot de passe: 0103509662)
