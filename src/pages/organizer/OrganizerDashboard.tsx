import { useState } from 'react';
import { useAuth } from '@/hooks/useAuth';
import { PriceCalculator } from '@/components/organizer/PriceCalculator';
import { ProductCatalog } from '@/components/organizer/ProductCatalog';
import { QuoteGenerator } from '@/components/organizer/QuoteGenerator';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Calculator, MessageSquare, Package } from 'lucide-react';
import { OrganizerChatSection } from '@/components/organizer/OrganizerChatSection';
import { DashboardLayout } from '@/components/dashboard/DashboardLayout';

// Types pour le calculateur et les devis
interface PriceItem {
    id: string;
    name: string;
    category: string;
    quantity: number;
    unitPrice: number;
    total: number;
}

interface Product {
    id: string;
    name: string;
    category: string;
    description: string;
    base_price: number;
    unit_type: string;
}

export const OrganizerDashboard = () => {
    const { user } = useAuth();
    const [quoteItems, setQuoteItems] = useState<PriceItem[]>([]);
    const [quoteTotal, setQuoteTotal] = useState(0);
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);

    // Callback quand un produit est sélectionné dans le catalogue
    const handleProductSelect = (product: Product) => {
        setSelectedProduct(product);
        // Auto-scroll vers le calculateur (optionnel)
    };

    // Callback quand le devis est généré
    const handleGenerateQuote = (items: PriceItem[], total: number) => {
        setQuoteItems(items);
        setQuoteTotal(total);
    };

    // Callback pour envoyer le devis au client
    const handleSendQuote = async (quoteData: any) => {
        // TODO: Envoyer le devis dans le chat actif
        console.log('Envoi du devis:', quoteData);
        // Ici, on créera un message spécial de type "quote" dans le chat
    };

    return (
        <DashboardLayout>
            <div className="space-y-6 h-full overflow-hidden">
                {/* Header Section */}
                <div className="flex flex-col gap-1 flex-shrink-0">
                    <h1 className="text-2xl font-bold tracking-tight">Dashboard Organisateur</h1>
                    <p className="text-muted-foreground">
                        Gestion des réservations et conversations clients
                    </p>
                </div>

                {/* Main Layout - 2 colonnes optimisées */}
                <div className="h-[calc(100vh-180px)]">
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full">
                        {/* Colonne Gauche: Chat avec clients (2/3 de l'espace) */}
                        <div className="lg:col-span-2 h-full min-h-[500px]">
                            <OrganizerChatSection userId={user?.id || ''} />
                        </div>

                        {/* Colonne Droite: Outils de travail (Tabs) */}
                        <div className="h-full overflow-y-auto pr-2">
                            <Tabs defaultValue="calculator" className="w-full">
                                <TabsList className="grid w-full grid-cols-3">
                                    <TabsTrigger value="calculator">
                                        <Calculator className="h-4 w-4 mr-2" />
                                        Calcul
                                    </TabsTrigger>
                                    <TabsTrigger value="catalog">
                                        <Package className="h-4 w-4 mr-2" />
                                        Catalogue
                                    </TabsTrigger>
                                    <TabsTrigger value="quote" disabled={quoteItems.length === 0}>
                                        Devis
                                    </TabsTrigger>
                                </TabsList>

                                <TabsContent value="calculator" className="mt-4">
                                    <PriceCalculator onGenerateQuote={handleGenerateQuote} />
                                </TabsContent>

                                <TabsContent value="catalog" className="mt-4">
                                    <ProductCatalog onSelectProduct={handleProductSelect} />
                                </TabsContent>

                                <TabsContent value="quote" className="mt-4">
                                    <QuoteGenerator
                                        items={quoteItems}
                                        total={quoteTotal}
                                        onSendToClient={handleSendQuote}
                                        clientName="Client en cours"
                                    />
                                </TabsContent>
                            </Tabs>
                        </div>
                    </div>
                </div>
            </div>
        </DashboardLayout>
    );
};

export default OrganizerDashboard;
