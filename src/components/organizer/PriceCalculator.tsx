import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Calculator, Plus, Trash2 } from 'lucide-react';

interface PriceItem {
    id: string;
    name: string;
    category: string;
    quantity: number;
    unitPrice: number;
    total: number;
}

interface PriceCalculatorProps {
    onGenerateQuote: (items: PriceItem[], total: number) => void;
}

const CATEGORIES = [
    { value: 'patisserie', label: 'Pâtisserie' },
    { value: 'traiteur', label: 'Traiteur' },
    { value: 'decoration', label: 'Décoration' },
    { value: 'location', label: 'Location' },
    { value: 'animation', label: 'Animation' },
    { value: 'boissons', label: 'Boissons' },
    { value: 'transport', label: 'Transport' },
    { value: 'hebergement', label: 'Hébergement' },
    { value: 'autre', label: 'Autre' },
];

export const PriceCalculator = ({ onGenerateQuote }: PriceCalculatorProps) => {
    const [items, setItems] = useState<PriceItem[]>([]);
    const [currentItem, setCurrentItem] = useState({
        name: '',
        category: 'patisserie',
        quantity: 1,
        unitPrice: 0,
    });

    const commission = 0.05; // 5%

    const addItem = () => {
        if (!currentItem.name || currentItem.unitPrice <= 0) return;

        const total = currentItem.quantity * currentItem.unitPrice;
        const newItem: PriceItem = {
            id: crypto.randomUUID(),
            ...currentItem,
            total,
        };

        setItems([...items, newItem]);
        setCurrentItem({ name: '', category: 'patisserie', quantity: 1, unitPrice: 0 });
    };

    const removeItem = (id: string) => {
        setItems(items.filter(item => item.id !== id));
    };

    const subtotal = items.reduce((sum, item) => sum + item.total, 0);
    const commissionAmount = subtotal * commission;
    const grandTotal = subtotal + commissionAmount;

    const handleGenerateQuote = () => {
        onGenerateQuote(items, grandTotal);
    };

    return (
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    <Calculator className="h-5 w-5" />
                    Calculateur de Prix
                </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
                {/* Formulaire d'ajout */}
                <div className="space-y-3 p-4 bg-muted/50 rounded-lg">
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label htmlFor="category">Catégorie</Label>
                            <Select
                                value={currentItem.category}
                                onValueChange={(value) => setCurrentItem({ ...currentItem, category: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                    {CATEGORIES.map((cat) => (
                                        <SelectItem key={cat.value} value={cat.value}>
                                            {cat.label}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>

                        <div>
                            <Label htmlFor="name">Article</Label>
                            <Input
                                id="name"
                                placeholder="Ex: Gâteau 3 étages"
                                value={currentItem.name}
                                onChange={(e) => setCurrentItem({ ...currentItem, name: e.target.value })}
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <Label htmlFor="quantity">Quantité / Nb Personnes</Label>
                            <Input
                                id="quantity"
                                type="number"
                                min="1"
                                value={currentItem.quantity}
                                onChange={(e) => setCurrentItem({ ...currentItem, quantity: parseInt(e.target.value) || 1 })}
                            />
                        </div>

                        <div>
                            <Label htmlFor="unitPrice">Prix unitaire (FCFA)</Label>
                            <Input
                                id="unitPrice"
                                type="number"
                                min="0"
                                step="100"
                                value={currentItem.unitPrice}
                                onChange={(e) => setCurrentItem({ ...currentItem, unitPrice: parseFloat(e.target.value) || 0 })}
                            />
                        </div>
                    </div>

                    <Button onClick={addItem} className="w-full" disabled={!currentItem.name || currentItem.unitPrice <= 0}>
                        <Plus className="h-4 w-4 mr-2" />
                        Ajouter
                    </Button>
                </div>

                {/* Liste des articles */}
                {items.length > 0 && (
                    <div className="space-y-2">
                        <Label>Articles ajoutés</Label>
                        {items.map((item) => (
                            <div key={item.id} className="flex items-center justify-between p-2 bg-background border rounded">
                                <div className="flex-1">
                                    <p className="font-medium text-sm">{item.name}</p>
                                    <p className="text-xs text-muted-foreground">
                                        {item.quantity} × {item.unitPrice.toLocaleString()} FCFA
                                    </p>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className="font-semibold">{item.total.toLocaleString()} FCFA</span>
                                    <Button variant="ghost" size="icon" onClick={() => removeItem(item.id)}>
                                        <Trash2 className="h-4 w-4 text-destructive" />
                                    </Button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}

                {/* Résumé */}
                {items.length > 0 && (
                    <div className="space-y-2 p-4 bg-primary/5 rounded-lg border-2 border-primary/20">
                        <div className="flex justify-between text-sm">
                            <span>Sous-total</span>
                            <span>{subtotal.toLocaleString()} FCFA</span>
                        </div>
                        <div className="flex justify-between text-sm text-muted-foreground">
                            <span>Commission YAFOY (5%)</span>
                            <span>+ {commissionAmount.toLocaleString()} FCFA</span>
                        </div>
                        <div className="flex justify-between text-lg font-bold pt-2 border-t">
                            <span>TOTAL</span>
                            <span className="text-primary">{grandTotal.toLocaleString()} FCFA</span>
                        </div>

                        <Button onClick={handleGenerateQuote} className="w-full mt-2">
                            Générer le Devis
                        </Button>
                    </div>
                )}
            </CardContent>
        </Card>
    );
};
