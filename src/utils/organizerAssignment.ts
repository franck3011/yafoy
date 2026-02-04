import { supabase } from '@/integrations/supabase/client';

/**
 * Assigne un organisateur à un client en utilisant un système de load balancing
 * Les organisateurs sont assignés de manière alternée pour équilibrer la charge
 * 
 * @param clientId - ID de l'utilisateur client
 * @returns ID de l'organisateur assigné
 */
export const assignOrganizer = async (clientId: string): Promise<string | null> => {
    try {
        // IDs des deux organisateurs (à récupérer depuis la base de données)
        const { data: organizers, error: organizersError } = await supabase
            .from('user_roles')
            .select('user_id')
            .eq('role', 'organizer');

        if (organizersError) {
            console.warn('Erreur lors de la récupération des organisateurs:', organizersError);
            return null;
        }

        if (!organizers || organizers.length === 0) {
            console.warn('Aucun organisateur trouvé dans le système');
            return null;
        }

        if (organizers.length < 2) {
            console.warn('Moins de 2 organisateurs disponibles, assignation au seul organisateur disponible');
            return organizers[0].user_id;
        }

        // Compter les clients actifs assignés à chaque organisateur
        const assignmentCounts = await Promise.all(
            organizers.map(async (org) => {
                const { count, error } = await supabase
                    .from('client_organizer_assignments')
                    .select('*', { count: 'exact', head: true })
                    .eq('organizer_id', org.user_id)
                    .eq('status', 'active');

                if (error) {
                    console.warn('Erreur lors du comptage des assignations:', error);
                    return {
                        organizerId: org.user_id,
                        activeClients: 0
                    };
                }

                return {
                    organizerId: org.user_id,
                    activeClients: count || 0
                };
            })
        );

        // Trier par nombre de clients et prendre celui avec le moins de clients
        assignmentCounts.sort((a, b) => a.activeClients - b.activeClients);
        const selectedOrganizer = assignmentCounts[0].organizerId;

        // Vérifier si le client a déjà une assignation active
        const { data: existingAssignment } = await supabase
            .from('client_organizer_assignments')
            .select('*')
            .eq('client_id', clientId)
            .eq('status', 'active')
            .single();

        if (existingAssignment) {
            console.log(`Client ${clientId} a déjà un organisateur assigné: ${existingAssignment.organizer_id}`);
            return existingAssignment.organizer_id;
        }

        // Créer une nouvelle assignation
        const { data: newAssignment, error: assignmentError } = await supabase
            .from('client_organizer_assignments')
            .insert({
                client_id: clientId,
                organizer_id: selectedOrganizer,
                status: 'active'
            })
            .select()
            .single();

        if (assignmentError) {
            console.warn('Erreur lors de la création de l\'assignation:', assignmentError);
            return selectedOrganizer; // Retourner l'organisateur même si l'assignation échoue
        }

        console.log(`Client ${clientId} assigné à l'organisateur ${selectedOrganizer}`);
        return selectedOrganizer;

    } catch (error) {
        console.error('Erreur lors de l\'assignation de l\'organisateur:', error);
        return null; // Retourner null au lieu de lancer une erreur
    }
};

/**
 * Récupère l'organisateur assigné à un client
 * 
 * @param clientId - ID de l'utilisateur client
 * @returns ID de l'organisateur assigné ou null si aucune assignation
 */
export const getAssignedOrganizer = async (clientId: string): Promise<string | null> => {
    try {
        const { data, error } = await supabase
            .from('client_organizer_assignments')
            .select('organizer_id')
            .eq('client_id', clientId)
            .eq('status', 'active')
            .single();

        if (error) {
            if (error.code === 'PGRST116') {
                // Aucune assignation trouvée
                return null;
            }
            throw error;
        }

        return data?.organizer_id || null;
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'organisateur:', error);
        return null;
    }
};

/**
 * Marque une assignation comme terminée
 * 
 * @param clientId - ID de l'utilisateur client
 */
export const completeAssignment = async (clientId: string): Promise<void> => {
    try {
        const { error } = await supabase
            .from('client_organizer_assignments')
            .update({ status: 'completed' })
            .eq('client_id', clientId)
            .eq('status', 'active');

        if (error) throw error;
    } catch (error) {
        console.error('Erreur lors de la finalisation de l\'assignation:', error);
        throw error;
    }
};

/**
 * Annule une assignation
 * 
 * @param clientId - ID de l'utilisateur client
 */
export const cancelAssignment = async (clientId: string): Promise<void> => {
    try {
        const { error } = await supabase
            .from('client_organizer_assignments')
            .update({ status: 'cancelled' })
            .eq('client_id', clientId)
            .eq('status', 'active');

        if (error) throw error;
    } catch (error) {
        console.error('Erreur lors de l\'annulation de l\'assignation:', error);
        throw error;
    }
};
