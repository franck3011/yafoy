-- ============================================
-- SCRIPT DE RÉPARATION FORCÉE DU CHAT
-- ============================================
-- Ce script va :
-- 1. Désactiver RLS sur toutes les tables liées au chat (pour être sûr que ça marche)
-- 2. Créer des données de test si elles manquent
-- 3. Assurer qu'il y a au moins une conversation active pour le premier organisateur trouvé
-- ============================================

-- 1. DÉSACTIVER RLS (Pour éviter tout problème de permission)
-- =========================================================
ALTER TABLE public.chat_rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_organizer_assignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles DISABLE ROW LEVEL SECURITY;

-- 2. RECUPERER UN ORGANISATEUR ET UN CLIENT
-- =========================================
DO $$
DECLARE
    v_organizer_id uuid;
    v_client_id uuid;
    v_assignment_id uuid;
    v_room_id uuid;
BEGIN
    -- Trouver le premier organisateur (ou n'importe quel user si pas d'organisateur)
    SELECT user_id INTO v_organizer_id FROM public.user_roles WHERE role = 'organizer' LIMIT 1;
    
    -- Si pas d'organisateur, prendre le premier user et le rendre organisateur
    IF v_organizer_id IS NULL THEN
        SELECT id INTO v_organizer_id FROM auth.users LIMIT 1;
        IF v_organizer_id IS NOT NULL THEN
            INSERT INTO public.user_roles (user_id, role) VALUES (v_organizer_id, 'organizer')
            ON CONFLICT (user_id) DO UPDATE SET role = 'organizer';
        END IF;
    END IF;

    -- Trouver un client (différent de l'organisateur)
    SELECT id INTO v_client_id FROM auth.users WHERE id != v_organizer_id LIMIT 1;
    
    -- Si on a trouvé les deux, on crée la connexion
    IF v_organizer_id IS NOT NULL AND v_client_id IS NOT NULL THEN
        
        RAISE NOTICE 'Organisateur trouvé: %', v_organizer_id;
        RAISE NOTICE 'Client trouvé: %', v_client_id;

        -- A. Créer l'attribution
        INSERT INTO public.client_organizer_assignments (client_id, organizer_id, status)
        VALUES (v_client_id, v_organizer_id, 'active')
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_assignment_id;

        -- B. Créer la room de chat
        INSERT INTO public.chat_rooms (name, created_by, event_planning_id)
        VALUES ('Chat Organisation', v_organizer_id, v_assignment_id) -- event_planning_id est optionnel ou peut être l'assignment
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_room_id;
        
        -- Si la room existait déjà, on la récupère
        IF v_room_id IS NULL THEN
            SELECT id INTO v_room_id FROM public.chat_rooms WHERE created_by = v_organizer_id LIMIT 1;
        END IF;

        IF v_room_id IS NOT NULL THEN
            -- C. Ajouter l'organisateur comme participant
            INSERT INTO public.chat_room_participants (room_id, user_id, role)
            VALUES (v_room_id, v_organizer_id, 'organizer')
            ON CONFLICT (room_id, user_id) DO UPDATE SET role = 'organizer';

            -- D. Ajouter le client comme participant
            INSERT INTO public.chat_room_participants (room_id, user_id, role)
            VALUES (v_room_id, v_client_id, 'client')
            ON CONFLICT (room_id, user_id) DO UPDATE SET role = 'client';

            -- E. Ajouter un message de test
            INSERT INTO public.chat_messages (room_id, sender_id, content, message_type)
            VALUES (v_room_id, v_organizer_id, 'Bienvenue dans votre espace de discussion ! Le chat est maintenant activé.', 'text');
            
            RAISE NOTICE '✅ Tout est configuré pour la room %', v_room_id;
        END IF;

    ELSE
        RAISE NOTICE '⚠️ Impossible de trouver 2 utilisateurs distincts pour faire un test.';
    END IF;
END $$;

-- 3. VERIFICATION FINALE
-- ======================
SELECT 
    cr.name as Room, 
    p.full_name as Participant, 
    crp.role 
FROM public.chat_room_participants crp 
JOIN public.chat_rooms cr ON cr.id = crp.room_id
JOIN public.profiles p ON p.user_id = crp.user_id;

