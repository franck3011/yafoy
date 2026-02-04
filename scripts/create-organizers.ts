import { createClient } from '@supabase/supabase-js';

// Configuration Supabase
const supabaseUrl = 'https://dvbgytmkysaztbdqosup.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseServiceKey) {
  console.error('❌ SUPABASE_SERVICE_ROLE_KEY manquante dans les variables d\'environnement');
  console.log('ℹ️  Pour obtenir cette clé:');
  console.log('   1. Allez sur https://supabase.com/dashboard/project/dvbgytmkysaztbdqosup/settings/api');
  console.log('   2. Copiez la clé "service_role" (secret)');
  console.log('   3. Exécutez: set SUPABASE_SERVICE_ROLE_KEY=votre_clé (Windows) ou export SUPABASE_SERVICE_ROLE_KEY=votre_clé (Linux/Mac)');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

interface Organizer {
  email: string;
  password: string;
  fullName: string;
}

const organizers: Organizer[] = [
  {
    email: 'organisateur1@gmail.com',
    password: '0103509662',
    fullName: 'Organisateur Chef 1'
  },
  {
    email: 'organisateur2@gmail.com',
    password: '0103509662',
    fullName: 'Organisateur Chef 2'
  }
];

async function createOrganizerAccount(organizer: Organizer) {
  console.log(`\n📝 Création du compte: ${organizer.email}`);

  try {
    // 1. Créer l'utilisateur dans Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: organizer.email,
      password: organizer.password,
      email_confirm: true, // Confirmer l'email automatiquement
      user_metadata: {
        full_name: organizer.fullName,
        role: 'organizer'
      }
    });

    if (authError) {
      // Si l'utilisateur existe déjà, essayer de le récupérer
      if (authError.message.includes('already registered')) {
        console.log(`   ⚠️  L'utilisateur existe déjà, récupération...`);
        
        const { data: users, error: listError } = await supabase.auth.admin.listUsers();
        if (listError) throw listError;
        
        const existingUser = users.users.find(u => u.email === organizer.email);
        if (!existingUser) throw new Error('Utilisateur existant introuvable');
        
        console.log(`   ✅ Utilisateur trouvé: ${existingUser.id}`);
        return existingUser.id;
      }
      throw authError;
    }

    if (!authData.user) {
      throw new Error('Échec de la création de l\'utilisateur');
    }

    const userId = authData.user.id;
    console.log(`   ✅ Compte Auth créé - ID: ${userId}`);

    // 2. Vérifier si le profil existe déjà
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (!existingProfile) {
      // Créer le profil
      const { error: profileError } = await supabase
        .from('profiles')
        .insert({
          user_id: userId,
          full_name: organizer.fullName,
          phone: null,
          location: null,
          avatar_url: null
        });

      if (profileError) throw profileError;
      console.log(`   ✅ Profil créé`);
    } else {
      console.log(`   ℹ️  Profil existe déjà`);
    }

    // 3. Vérifier si le rôle existe déjà
    const { data: existingRole } = await supabase
      .from('user_roles')
      .select('*')
      .eq('user_id', userId)
      .eq('role', 'organizer')
      .single();

    if (!existingRole) {
      // Assigner le rôle 'organizer'
      const { error: roleError } = await supabase
        .from('user_roles')
        .insert({
          user_id: userId,
          role: 'organizer'
        });

      if (roleError) throw roleError;
      console.log(`   ✅ Rôle 'organizer' assigné`);
    } else {
      console.log(`   ℹ️  Rôle 'organizer' existe déjà`);
    }

    return userId;
  } catch (error: any) {
    console.error(`   ❌ Erreur:`, error.message);
    throw error;
  }
}

async function main() {
  console.log('🚀 Démarrage de la création des comptes organisateurs...\n');
  console.log('═══════════════════════════════════════════════════════');

  const results: { email: string; userId?: string; error?: string }[] = [];

  for (const organizer of organizers) {
    try {
      const userId = await createOrganizerAccount(organizer);
      results.push({ email: organizer.email, userId });
    } catch (error: any) {
      results.push({ email: organizer.email, error: error.message });
    }
  }

  console.log('\n═══════════════════════════════════════════════════════');
  console.log('\n📊 Résumé de la création des comptes:\n');

  results.forEach((result, index) => {
    console.log(`${index + 1}. ${result.email}`);
    if (result.userId) {
      console.log(`   ✅ Créé avec succès - ID: ${result.userId}`);
    } else {
      console.log(`   ❌ Échec: ${result.error}`);
    }
  });

  const successCount = results.filter(r => r.userId).length;
  const failureCount = results.filter(r => r.error).length;

  console.log(`\n✨ ${successCount} compte(s) créé(s) avec succès`);
  if (failureCount > 0) {
    console.log(`⚠️  ${failureCount} échec(s)`);
  }

  console.log('\n🔐 Credentials:');
  organizers.forEach(org => {
    console.log(`   Email: ${org.email}`);
    console.log(`   Mot de passe: ${org.password}\n`);
  });
}

main()
  .then(() => {
    console.log('✅ Script terminé');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Erreur fatale:', error);
    process.exit(1);
  });
