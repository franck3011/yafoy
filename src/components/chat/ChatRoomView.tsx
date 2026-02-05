import { useState, useRef, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
  Send,
  Image as ImageIcon,
  Paperclip,
  Mic,
  MicOff,
  Loader2,
  Users,
  Play,
  Pause,
  AlertCircle,
  Pen
} from 'lucide-react';
import { ElectronicSignature } from './ElectronicSignature';
import { useChatRoom } from '@/hooks/useChatRoom';
import { useAuth } from '@/hooks/useAuth';
import { useTypingIndicator } from '@/hooks/useTypingIndicator';
import { cn } from '@/lib/utils';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { validateChatMessage } from '@/utils/chatValidation';
import { useToast } from '@/hooks/use-toast';

interface ChatRoomViewProps {
  roomId: string;
  participants?: { id: string; full_name: string | null; avatar_url: string | null; role: string }[];
}

export const ChatRoomView = ({ roomId, participants = [] }: ChatRoomViewProps) => {
  const { user } = useAuth();
  const { toast } = useToast();
  const { room, messages, isLoading, isSending, sendMessage, uploadFile } = useChatRoom(roomId);
  const { typingUsers, broadcastTyping, broadcastStopTyping } = useTypingIndicator(roomId);
  const [input, setInput] = useState('');
  const [inputError, setInputError] = useState<string | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordingTime, setRecordingTime] = useState(0);
  const [playingVoice, setPlayingVoice] = useState<string | null>(null);
  const [isSigningOpen, setIsSigningOpen] = useState(false);
  const [isSigning, setIsSigning] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const imageInputRef = useRef<HTMLInputElement>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const recordingIntervalRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (scrollRef.current) {
      const scrollElement = scrollRef.current.querySelector('[data-radix-scroll-area-viewport]');
      if (scrollElement) {
        scrollElement.scrollTop = scrollElement.scrollHeight;
      }
    }
  }, [messages]);

  const handleInputChange = (value: string) => {
    setInput(value);
    // Clear error when user starts typing
    if (inputError) {
      setInputError(null);
    }

    // Broadcast typing indicator
    if (value.length > 0) {
      broadcastTyping();
    } else {
      broadcastStopTyping();
    }
  };

  const handleSendText = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log('🚀 [ChatRoomView] handleSendText appelé', { input: input.trim(), isSending });

    if (!input.trim() || isSending) {
      console.log('⚠️ [ChatRoomView] Message vide ou envoi en cours');
      return;
    }

    // Validate message
    const validation = validateChatMessage(input.trim());
    console.log('✅ [ChatRoomView] Validation:', validation);

    if (!validation.isValid) {
      setInputError(validation.message || 'Message invalide');
      toast({
        title: 'Message non autorisé',
        description: validation.message,
        variant: 'destructive',
      });
      return;
    }

    console.log('📤 [ChatRoomView] Envoi du message...');
    const success = await sendMessage(input.trim(), 'text');
    console.log('📬 [ChatRoomView] Résultat envoi:', success);

    if (success) {
      setInput('');
      setInputError(null);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>, type: 'image' | 'file') => {
    const file = e.target.files?.[0];
    if (!file) return;

    const url = await uploadFile(file);
    if (url) {
      await sendMessage('', type, url, file.name, file.size);
    }
    e.target.value = '';
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      mediaRecorderRef.current = new MediaRecorder(stream);
      audioChunksRef.current = [];

      mediaRecorderRef.current.ondataavailable = (e) => {
        audioChunksRef.current.push(e.data);
      };

      mediaRecorderRef.current.onstop = async () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
        const url = await uploadFile(new File([audioBlob], `voice-${Date.now()}.webm`, { type: 'audio/webm' }));
        if (url) {
          await sendMessage('', 'voice', url, undefined, undefined, recordingTime);
        }
        setRecordingTime(0);
        stream.getTracks().forEach(track => track.stop());
      };

      mediaRecorderRef.current.start();
      setIsRecording(true);

      recordingIntervalRef.current = setInterval(() => {
        setRecordingTime(prev => prev + 1);
      }, 1000);
    } catch (error) {
      console.error('Error starting recording:', error);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      if (recordingIntervalRef.current) {
        clearInterval(recordingIntervalRef.current);
      }
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const playVoice = (url: string) => {
    if (playingVoice === url) {
      setPlayingVoice(null);
    } else {
      setPlayingVoice(url);
      const audio = new Audio(url);
      audio.onended = () => setPlayingVoice(null);
      audio.play();
    }
  };

  const handleSign = async (signatureDataUrl: string) => {
    try {
      setIsSigning(true);

      // Convert data URL to Blob
      const res = await fetch(signatureDataUrl);
      const blob = await res.blob();
      const file = new File([blob], `signature-${Date.now()}.png`, { type: 'image/png' });

      // Upload signature image
      const url = await uploadFile(file);

      if (url) {
        // Send signature message
        await sendMessage(
          'Accord signé électroniquement',
          'image',
          url,
          'Signature',
          file.size
        );

        setIsSigningOpen(false);
        toast({
          title: 'Signature envoyée',
          description: 'Votre accord a été signé avec succès',
          className: 'bg-green-600 text-white',
        });
      }
    } catch (error) {
      console.error('Error sending signature:', error);
      toast({
        title: 'Erreur',
        description: "Impossible d'envoyer la signature",
        variant: 'destructive',
      });
    } finally {
      setIsSigning(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <Card className="flex flex-col h-full">
      <CardHeader className="pb-3 border-b">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{room?.name || 'Chat'}</CardTitle>
          {participants.length > 0 && (
            <div className="flex items-center gap-2">
              <Users className="h-4 w-4 text-muted-foreground" />
              <span className="text-sm text-muted-foreground">{participants.length}</span>
              <div className="flex -space-x-2">
                {participants.slice(0, 5).map((p) => (
                  <Avatar key={p.id} className="h-6 w-6 border-2 border-background">
                    <AvatarImage src={p.avatar_url || undefined} />
                    <AvatarFallback className="text-xs">
                      {p.full_name?.[0]?.toUpperCase() || '?'}
                    </AvatarFallback>
                  </Avatar>
                ))}
              </div>
            </div>
          )}
        </div>
      </CardHeader>

      <CardContent className="flex-1 flex flex-col p-0 overflow-hidden">
        <ScrollArea className="flex-1 px-4" ref={scrollRef}>
          <div className="space-y-4 py-4 min-h-full flex flex-col justify-end">
            {messages.length === 0 && (
              <div className="text-center py-8">
                <Users className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                <p className="text-muted-foreground">
                  Démarrez la conversation
                </p>
              </div>
            )}

            {messages.map((msg) => {
              const isMe = msg.sender_id === user?.id;
              const senderName = msg.sender?.full_name || 'Utilisateur';

              return (
                <div
                  key={msg.id}
                  className={cn(
                    'flex gap-3',
                    isMe ? 'justify-end' : 'justify-start'
                  )}
                >
                  {!isMe && (
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={msg.sender?.avatar_url || undefined} />
                      <AvatarFallback className="text-xs">
                        {senderName[0]?.toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                  )}

                  <div className={cn('max-w-[70%]')}>
                    <div className={cn('flex flex-col', isMe ? 'items-end' : 'items-start')}>
                      <span className="text-xs text-muted-foreground mb-1 block">
                        {isMe ? 'Moi' : senderName}
                      </span>

                      <div
                        className={cn(
                          'rounded-2xl px-4 py-2 shadow-sm relative',
                          isMe
                            ? 'bg-orange-500 text-white rounded-tr-none'
                            : 'bg-gray-200 text-gray-900 dark:bg-gray-700 dark:text-white rounded-tl-none'
                        )}
                      >
                        {msg.message_type === 'text' && (
                          <p className="text-sm whitespace-pre-wrap">{msg.content}</p>
                        )}

                        {msg.message_type === 'image' && msg.file_url && (
                          <img
                            src={msg.file_url}
                            alt="Image"
                            className="max-w-full rounded cursor-pointer"
                            onClick={() => window.open(msg.file_url!, '_blank')}
                          />
                        )}

                        {msg.message_type === 'file' && msg.file_url && (
                          <a
                            href={msg.file_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 underline"
                          >
                            <Paperclip className="h-4 w-4" />
                            {msg.file_name || 'Fichier'}
                          </a>
                        )}

                        {msg.message_type === 'voice' && msg.file_url && (
                          <button
                            onClick={() => playVoice(msg.file_url!)}
                            className="flex items-center gap-2"
                          >
                            {playingVoice === msg.file_url ? (
                              <Pause className="h-4 w-4" />
                            ) : (
                              <Play className="h-4 w-4" />
                            )}
                            <span className="text-sm">
                              Note vocale {msg.voice_duration ? `(${formatTime(msg.voice_duration)})` : ''}
                            </span>
                          </button>
                        )}
                      </div>

                      <p className="text-xs text-muted-foreground mt-1">
                        {format(new Date(msg.created_at), 'HH:mm', { locale: fr })}
                      </p>
                    </div>
                  </div>

                  {isMe && (
                    <Avatar className="h-8 w-8">
                      <AvatarFallback className="text-xs bg-secondary">Moi</AvatarFallback>
                    </Avatar>
                  )}
                </div>
              );
            })}
          </div>
        </ScrollArea>

        {/* Input Area */}
        <div className="p-4 border-t">
          <form onSubmit={handleSendText} className="flex gap-2">
            <input
              type="file"
              ref={imageInputRef}
              className="hidden"
              accept="image/*"
              onChange={(e) => handleFileUpload(e, 'image')}
            />
            <input
              type="file"
              ref={fileInputRef}
              className="hidden"
              onChange={(e) => handleFileUpload(e, 'file')}
            />

            <Button
              type="button"
              variant="outline"
              size="icon"
              onClick={() => imageInputRef.current?.click()}
            >
              <ImageIcon className="h-4 w-4" />
            </Button>

            <Button
              type="button"
              variant="outline"
              size="icon"
              onClick={() => fileInputRef.current?.click()}
            >
              <Paperclip className="h-4 w-4" />
            </Button>

            <Button
              type="button"
              variant="outline"
              size="icon"
              className="bg-primary/5 hover:bg-primary/10 border-primary/20"
              onClick={() => setIsSigningOpen(true)}
              title="Signer l'accord"
            >
              <Pen className="h-4 w-4 text-primary" />
            </Button>

            <Button
              type="button"
              variant={isRecording ? 'destructive' : 'outline'}
              size="icon"
              onClick={isRecording ? stopRecording : startRecording}
            >
              {isRecording ? (
                <span className="text-xs">{formatTime(recordingTime)}</span>
              ) : (
                <Mic className="h-4 w-4" />
              )}
            </Button>

            <div className="flex-1 flex flex-col">
              <Input
                value={input}
                onChange={(e) => handleInputChange(e.target.value)}
                placeholder="Écrivez un message..."
                disabled={isSending || isRecording}
                className={cn("flex-1", inputError && "border-destructive")}
              />
              {inputError && (
                <p className="text-xs text-destructive mt-1 flex items-center gap-1">
                  <AlertCircle className="h-3 w-3" />
                  {inputError}
                </p>
              )}
            </div>

            <Button type="submit" disabled={isSending || !input.trim() || isRecording}>
              {isSending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
            </Button>
          </form>
        </div>
      </CardContent>
      <ElectronicSignature
        isOpen={isSigningOpen}
        onClose={() => setIsSigningOpen(false)}
        onSign={handleSign}
        isSigning={isSigning}
      />
    </Card>
  );
};
