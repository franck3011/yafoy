import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Search, Package } from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';

interface Product {
    id: string;
    name: string;
    category: string;
    description: string;
    base_price: number;
    unit_type: string;
}

interface ProductCatalogProps {
    onSelectProduct: (product: Product) => void;
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

export const ProductCatalog = ({ onSelectProduct }: ProductCatalogProps) => {
    const [searchTerm, setSearchTerm] = useState('');
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchProducts();
    }, []);

    const fetchProducts = async () => {
        try {
            const { data, error } = await supabase
                .from('product_catalog')
                .select('*')
                .eq('is_active', true)
                .order('category', { ascending: true })
                .order('name', { ascending: true });

            if (error) throw error;
            setProducts(data || []);
        } catch (error) {
            console.error('Error fetching products:', error);
        } finally {
            setLoading(false);
        }
    };

    const filteredProducts = products.filter(
        (product) =>
            product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            product.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
            product.description?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const groupedProducts = filteredProducts.reduce((acc, product) => {
        if (!acc[product.category]) {
            acc[product.category] = [];
        }
        acc[product.category].push(product);
        return acc;
    }, {} as Record<string, Product[]>);

    return (
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    <Package className="h-5 w-5" />
                    Catalogue de Produits
                </CardTitle>
                <div className="relative">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder="Rechercher un article..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="pl-8"
                    />
                </div>
            </CardHeader>
            <CardContent className="max-h-[600px] overflow-y-auto">
                {loading ? (
                    <p className="text-center text-muted-foreground">Chargement...</p>
                ) : Object.keys(groupedProducts).length === 0 ? (
                    <p className="text-center text-muted-foreground">Aucun produit trouvé</p>
                ) : (
                    <div className="space-y-4">
                        {Object.entries(groupedProducts).map(([category, categoryProducts]) => (
                            <div key={category}>
                                <h3 className="font-semibold mb-2 flex items-center gap-2">
                                    <Badge variant="outline">{CATEGORY_LABELS[category] || category}</Badge>
                                    <span className="text-xs text-muted-foreground">({categoryProducts.length})</span>
                                </h3>
                                <div className="space-y-2">
                                    {categoryProducts.map((product) => (
                                        <div
                                            key={product.id}
                                            onClick={() => onSelectProduct(product)}
                                            className="p-3 border rounded-lg hover:bg-accent cursor-pointer transition-colors"
                                        >
                                            <div className="flex justify-between items-start">
                                                <div className="flex-1">
                                                    <p className="font-medium text-sm">{product.name}</p>
                                                    {product.description && (
                                                        <p className="text-xs text-muted-foreground mt-1">{product.description}</p>
                                                    )}
                                                </div>
                                                <div className="text-right ml-2">
                                                    <p className="font-semibold text-sm">{product.base_price?.toLocaleString()} FCFA</p>
                                                    <p className="text-xs text-muted-foreground">
                                                        {product.unit_type === 'per_person' && '/pers'}
                                                        {product.unit_type === 'per_unit' && '/unité'}
                                                        {product.unit_type === 'fixed' && 'forfait'}
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </CardContent>
        </Card>
    );
};
