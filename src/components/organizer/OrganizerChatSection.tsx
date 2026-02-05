import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { MessageSquare, Users } from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';
import { ChatRoomView } from '@/components/chat/ChatRoomView';

interface OrganizerChatSectionProps {
    userId: string;
}

interface ChatRoom {
    id: string;
    name: string;
    created_at: string;
}

export const OrganizerChatSection = ({ userId }: OrganizerChatSectionProps) => {
    const [rooms, setRooms] = useState<ChatRoom[]>([]);
    const [selectedRoomId, setSelectedRoomId] = useState<string | null>(null);
    const [participants, setParticipants] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!userId) {
            setLoading(false);
            return;
        }
        fetchOrganizerRooms();
    }, [userId]);

    const fetchOrganizerRooms = async () => {
        try {
            console.log('🔍 [OrganizerChatSection] Récupération des rooms pour userId:', userId);

            // 1. Récupérer les IDs des rooms où l'organisateur est participant
            const { data: participationData, error: partError } = await supabase
                .from('chat_room_participants')
                .select('room_id')
                .eq('user_id', userId);

            console.log('📋 [OrganizerChatSection] Participations récupérées:', {
                count: participationData?.length || 0,
                data: participationData,
                error: partError
            });

            if (partError) throw partError;

            if (!participationData || participationData.length === 0) {
                console.warn('⚠️ [OrganizerChatSection] Aucune participation trouvée pour cet organisateur');
                setRooms([]);
                setLoading(false);
                return;
            }

            const roomIds = participationData.map(p => p.room_id);
            console.log('🔑 [OrganizerChatSection] IDs des rooms:', roomIds);

            // 2. Récupérer les détails des rooms avec le dernier message
            const { data: roomsData, error: roomsError } = await supabase
                .from('chat_rooms')
                .select(`
                    id, 
                    name, 
                    created_at
                `)
                .in('id', roomIds);

            if (roomsError) throw roomsError;

            // 3. Pour chaque room, récupérer le dernier message
            const roomsWithLastMessage = await Promise.all(
                (roomsData || []).map(async (room) => {
                    const { data: lastMessage } = await supabase
                        .from('chat_messages')
                        .select('created_at')
                        .eq('room_id', room.id)
                        .order('created_at', { ascending: false })
                        .limit(1)
                        .maybeSingle();

                    return {
                        ...room,
                        last_message_at: lastMessage?.created_at || room.created_at,
                    };
                })
            );

            // 4. Trier par activité récente (dernier message)
            const sortedRooms = roomsWithLastMessage.sort((a, b) =>
                new Date(b.last_message_at).getTime() - new Date(a.last_message_at).getTime()
            );

            console.log('💬 [OrganizerChatSection] Rooms récupérées et triées:', {
                count: sortedRooms.length,
                data: sortedRooms,
            });

            setRooms(sortedRooms);

            // Sélectionner automatiquement la room avec l'activité la plus récente
            if (sortedRooms.length > 0 && !selectedRoomId) {
                console.log('✅ [OrganizerChatSection] Sélection automatique de la room la plus active:', sortedRooms[0].id);
                selectRoom(sortedRooms[0].id);
            }
        } catch (error) {
            console.error('❌ [OrganizerChatSection] Erreur lors de la récupération des rooms:', error);
        } finally {
            setLoading(false);
        }
    };

    const selectRoom = async (roomId: string) => {
        console.log('🎯 [OrganizerChatSection] Sélection de la room:', roomId);
        setSelectedRoomId(roomId);

        try {
            // 1. Récupérer les participants
            const { data: participantsData, error: partError } = await supabase
                .from('chat_room_participants')
                .select('user_id, role')
                .eq('room_id', roomId);

            console.log('👥 [OrganizerChatSection] Participants:', {
                count: participantsData?.length || 0,
                data: participantsData,
                error: partError
            });

            if (partError) throw partError;

            if (participantsData && participantsData.length > 0) {
                const userIds = participantsData.map(p => p.user_id);

                // 2. Récupérer les profils séparément (car la jointure directe peut échouer)
                const { data: profilesData, error: profError } = await supabase
                    .from('profiles')
                    .select('user_id, full_name, avatar_url')
                    .in('user_id', userIds);

                console.log('👤 [OrganizerChatSection] Profils:', {
                    count: profilesData?.length || 0,
                    data: profilesData,
                    error: profError
                });

                if (profError) throw profError;

                const profilesMap = (profilesData || []).reduce((acc, profile) => {
                    acc[profile.user_id] = profile;
                    return acc;
                }, {} as Record<string, any>);

                const formattedParticipants = participantsData.map(p => ({
                    id: p.user_id,
                    full_name: profilesMap[p.user_id]?.full_name || 'Utilisateur inconnu',
                    avatar_url: profilesMap[p.user_id]?.avatar_url || null,
                    role: p.role,
                }));

                console.log('✅ [OrganizerChatSection] Participants formatés:', formattedParticipants);
                setParticipants(formattedParticipants);
            }
        } catch (error) {
            console.error('❌ [OrganizerChatSection] Erreur lors de la récupération des participants:', error);
        }
    };

    if (loading) {
        return (
            <Card className="h-full flex items-center justify-center">
                <CardContent>
                    <p className="text-muted-foreground">Chargement...</p>
                </CardContent>
            </Card>
        );
    }

    if (rooms.length === 0) {
        return (
            <Card className="h-full flex items-center justify-center">
                <CardContent className="text-center py-16">
                    <Users className="h-16 w-16 mx-auto text-muted-foreground/50 mb-4" />
                    <p className="text-lg font-medium text-muted-foreground">Aucune conversation trouvée</p>
                    <p className="text-sm text-muted-foreground/70 mb-4">
                        Les réservations des clients apparaîtront ici dès qu'elles seront créées.
                    </p>
                    <div className="bg-muted p-4 rounded-lg text-xs text-left max-w-sm mx-auto">
                        <p className="font-semibold mb-2">Conseils pour l'affichage :</p>
                        <ul className="list-disc pl-4 space-y-1">
                            <li>Vérifiez qu'une réservation a été effectuée par un client</li>
                            <li>Assurez-vous d'être bien assigné comme organisateur</li>
                            <li>Rechargez la page si vous venez de vous connecter</li>
                        </ul>
                    </div>
                </CardContent>
            </Card>
        );
    }

    // Layout style Messenger: Liste à gauche, Chat à droite
    return (
        <div className="h-full flex gap-4">
            {/* Sidebar gauche: Liste des conversations */}
            <Card className="w-64 flex-shrink-0 flex flex-col">
                <CardHeader className="pb-3 border-b">
                    <CardTitle className="flex items-center gap-2 text-base">
                        <MessageSquare className="h-4 w-4" />
                        Conversations ({rooms.length})
                    </CardTitle>
                </CardHeader>
                <CardContent className="flex-1 overflow-y-auto p-2">
                    <div className="space-y-1">
                        {rooms.map(room => (
                            <button
                                key={room.id}
                                onClick={() => selectRoom(room.id)}
                                className={`w-full text-left p-3 rounded-lg transition-colors ${selectedRoomId === room.id
                                    ? 'bg-primary text-primary-foreground'
                                    : 'hover:bg-accent'
                                    }`}
                            >
                                <p className="font-medium text-sm truncate">{room.name}</p>
                                <p className="text-xs opacity-70 mt-1">
                                    {new Date(room.created_at).toLocaleDateString('fr-FR', {
                                        day: 'numeric',
                                        month: 'short'
                                    })}
                                </p>
                            </button>
                        ))}
                    </div>
                </CardContent>
            </Card>

            {/* Zone principale: Chat actif */}
            <div className="flex-1 min-w-0">
                {selectedRoomId ? (
                    <ChatRoomView roomId={selectedRoomId} participants={participants} />
                ) : (
                    <Card className="h-full flex items-center justify-center">
                        <CardContent className="text-center">
                            <MessageSquare className="h-16 w-16 mx-auto text-muted-foreground/50 mb-4" />
                            <p className="text-lg font-medium text-muted-foreground">
                                Sélectionnez une conversation
                            </p>
                            <p className="text-sm text-muted-foreground/70">
                                Choisissez un client dans la liste pour commencer
                            </p>
                        </CardContent>
                    </Card>
                )}
            </div>
        </div>
    );
};
