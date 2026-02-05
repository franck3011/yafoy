import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { FileText, Send } from 'lucide-react';

interface QuoteItem {
    id: string;
    name: string;
    category: string;
    quantity: number;
    unitPrice: number;
    total: number;
}

interface QuoteGeneratorProps {
    items: QuoteItem[];
    total: number;
    onSendToClient: (quoteData: any) => void;
    clientName?: string;
}

const CATEGORY_LABELS: Record<string, string> = {
    patisserie: 'Pâtisserie',
    traiteur: 'Traiteur',
    decoration: 'Décoration',
    location: 'Location',
    animation: 'Animation',
    boissons: 'Boissons',
    transport: 'Transport',
    hebergement: 'Hébergement',
    autre: 'Autre',
};

export const QuoteGenerator = ({ items, total, onSendToClient, clientName }: QuoteGeneratorProps) => {
    const commission = 0.05;
    const subtotal = items.reduce((sum, item) => sum + item.total, 0);
    const commissionAmount = subtotal * commission;

    const handleSend = () => {
        const quoteData = {
            items,
            subtotal,
            commission: commissionAmount,
            total,
            createdAt: new Date().toISOString(),
        };
        onSendToClient(quoteData);
    };

    if (items.length === 0) {
        return null;
    }

    return (
        <Card className="border-primary/50">
            <CardHeader className="bg-primary/5">
                <CardTitle className="flex items-center gap-2 text-lg">
                    <FileText className="h-5 w-5" />
                    Devis {clientName && `pour ${clientName}`}
                </CardTitle>
            </CardHeader>
            <CardContent className="pt-6">
                {/* En-tête du devis */}
                <div className="mb-4 pb-4 border-b">
                    <p className="text-sm text-muted-foreground">
                        Devis généré le {new Date().toLocaleDateString('fr-FR', {
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric'
                        })}
                    </p>
                </div>

                {/* Liste des articles */}
                <div className="space-y-3 mb-4">
                    {items.map((item) => (
                        <div key={item.id} className="flex justify-between items-start pb-2 border-b border-dashed">
                            <div className="flex-1">
                                <div className="flex items-center gap-2 mb-1">
                                    <p className="font-medium">{item.name}</p>
                                    <Badge variant="secondary" className="text-xs">
                                        {CATEGORY_LABELS[item.category]}
                                    </Badge>
                                </div>
                                <p className="text-sm text-muted-foreground">
                                    Quantité: {item.quantity} × {item.unitPrice.toLocaleString()} FCFA
                                </p>
                            </div>
                            <p className="font-semibold ml-2">{item.total.toLocaleString()} FCFA</p>
                        </div>
                    ))}
                </div>

                {/* Totaux */}
                <div className="space-y-2 pt-4 border-t-2">
                    <div className="flex justify-between text-sm">
                        <span>Sous-total</span>
                        <span>{subtotal.toLocaleString()} FCFA</span>
                    </div>
                    <div className="flex justify-between text-sm text-muted-foreground">
                        <span>Frais de service YAFOY (5%)</span>
                        <span>+ {commissionAmount.toLocaleString()} FCFA</span>
                    </div>
                    <div className="flex justify-between text-xl font-bold pt-3 border-t-2 border-primary">
                        <span>TOTAL TTC</span>
                        <span className="text-primary">{total.toLocaleString()} FCFA</span>
                    </div>
                </div>

                {/* Bouton d'action */}
                <Button onClick={handleSend} className="w-full mt-6" size="lg">
                    <Send className="h-4 w-4 mr-2" />
                    Envoyer le devis au client
                </Button>

                {/* Note */}
                <p className="text-xs text-center text-muted-foreground mt-4">
                    Ce devis sera envoyé directement dans la conversation avec le client
                </p>
            </CardContent>
        </Card>
    );
};
