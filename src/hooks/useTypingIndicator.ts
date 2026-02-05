import { useState, useEffect, useRef } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/hooks/useAuth';

interface TypingUser {
    userId: string;
    userName: string;
}

export const useTypingIndicator = (roomId: string | null) => {
    const { user } = useAuth();
    const [typingUsers, setTypingUsers] = useState<TypingUser[]>([]);
    const typingTimeoutRef = useRef<NodeJS.Timeout | null>(null);
    const channelRef = useRef<ReturnType<typeof supabase.channel> | null>(null);

    useEffect(() => {
        if (!roomId || !user) return;

        // Subscribe to typing events
        channelRef.current = supabase
            .channel(`room-${roomId}-typing`)
            .on('broadcast', { event: 'typing' }, (payload: any) => {
                const { userId, userName } = payload.payload;

                // Don't show our own typing indicator
                if (userId === user.id) return;

                setTypingUsers(prev => {
                    // Check if user is already in the list
                    const exists = prev.find(u => u.userId === userId);
                    if (exists) return prev;
                    return [...prev, { userId, userName }];
                });

                // Remove typing indicator after 3 seconds of inactivity
                setTimeout(() => {
                    setTypingUsers(prev => prev.filter(u => u.userId !== userId));
                }, 3000);
            })
            .on('broadcast', { event: 'stop_typing' }, (payload: any) => {
                const { userId } = payload.payload;
                setTypingUsers(prev => prev.filter(u => u.userId !== userId));
            })
            .subscribe();

        return () => {
            if (channelRef.current) {
                supabase.removeChannel(channelRef.current);
            }
        };
    }, [roomId, user]);

    const broadcastTyping = () => {
        if (!roomId || !user || !channelRef.current) return;

        channelRef.current.send({
            type: 'broadcast',
            event: 'typing',
            payload: {
                userId: user.id,
                userName: user.user_metadata?.full_name || user.email || 'Utilisateur'
            }
        });

        // Clear previous timeout
        if (typingTimeoutRef.current) {
            clearTimeout(typingTimeoutRef.current);
        }

        // Set timeout to stop typing after 3 seconds
        typingTimeoutRef.current = setTimeout(() => {
            broadcastStopTyping();
        }, 3000);
    };

    const broadcastStopTyping = () => {
        if (!roomId || !user || !channelRef.current) return;

        channelRef.current.send({
            type: 'broadcast',
            event: 'stop_typing',
            payload: { userId: user.id }
        });
    };

    return {
        typingUsers,
        broadcastTyping,
        broadcastStopTyping
    };
};
