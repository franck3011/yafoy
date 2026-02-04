import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Phone, MessageCircle, User, Calendar, MapPin } from 'lucide-react';

interface PreConversationScreenProps {
    organizerName: string;
    organizerPhone?: string;
    eventType: string;
    eventDate?: string;
    eventLocation?: string;
    onStartChat: () => void;
    onCall: () => void;
}

export const PreConversationScreen = ({
    organizerName,
    organizerPhone,
    eventType,
    eventDate,
    eventLocation,
    onStartChat,
    onCall,
}: PreConversationScreenProps) => {
    return (
        <div className="max-w-2xl mx-auto space-y-6 p-4">
            {/* Header Card */}
            <Card className="border-primary/20 bg-gradient-to-br from-background to-primary/5">
                <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-2xl">
                        <User className="h-6 w-6 text-primary" />
                        Votre Organisateur
                    </CardTitle>
                    <CardDescription>
                        Votre réservation a été créée avec succès
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                    {/* Organizer Info */}
                    <div className="p-4 bg-muted/50 rounded-lg space-y-3">
                        <div className="flex items-center gap-3">
                            <div className="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
                                <User className="h-6 w-6 text-primary" />
                            </div>
                            <div>
                                <p className="font-semibold text-lg">{organizerName}</p>
                                <p className="text-sm text-muted-foreground">Organisateur Chef</p>
                            </div>
                        </div>

                        {/* Event Details */}
                        <div className="space-y-2 pt-3 border-t">
                            <div className="flex items-center gap-2 text-sm">
                                <Calendar className="h-4 w-4 text-muted-foreground" />
                                <span className="text-muted-foreground">Type d'événement :</span>
                                <span className="font-medium">{eventType}</span>
                            </div>
                            {eventDate && (
                                <div className="flex items-center gap-2 text-sm">
                                    <Calendar className="h-4 w-4 text-muted-foreground" />
                                    <span className="text-muted-foreground">Date :</span>
                                    <span className="font-medium">{new Date(eventDate).toLocaleDateString('fr-FR')}</span>
                                </div>
                            )}
                            {eventLocation && (
                                <div className="flex items-center gap-2 text-sm">
                                    <MapPin className="h-4 w-4 text-muted-foreground" />
                                    <span className="text-muted-foreground">Lieu :</span>
                                    <span className="font-medium">{eventLocation}</span>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="space-y-3 pt-4">
                        <p className="text-sm text-muted-foreground text-center">
                            Comment souhaitez-vous continuer ?
                        </p>

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                            {/* APPELER Button */}
                            <Button
                                size="lg"
                                variant="outline"
                                className="h-16 flex flex-col gap-2 hover:bg-primary/10 hover:border-primary"
                                onClick={onCall}
                            >
                                <Phone className="h-6 w-6" />
                                <span className="font-semibold">APPELER</span>
                            </Button>

                            {/* DISCUTER Button */}
                            <Button
                                size="lg"
                                className="h-16 flex flex-col gap-2 bg-primary hover:bg-primary/90"
                                onClick={onStartChat}
                            >
                                <MessageCircle className="h-6 w-6" />
                                <span className="font-semibold">DISCUTER AVEC L'ASSISTANCE</span>
                            </Button>
                        </div>

                        {organizerPhone && (
                            <p className="text-xs text-center text-muted-foreground">
                                Téléphone : {organizerPhone}
                            </p>
                        )}
                    </div>

                    {/* Info Notice */}
                    <div className="mt-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
                        <p className="text-sm text-blue-700 dark:text-blue-300">
                            💡 Votre organisateur est là pour vous accompagner dans la préparation de votre événement.
                            N'hésitez pas à le contacter pour toute question.
                        </p>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};
