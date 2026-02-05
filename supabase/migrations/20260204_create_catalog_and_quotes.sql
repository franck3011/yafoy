-- Créer la table du catalogue de produits
CREATE TABLE IF NOT EXISTS public.product_catalog (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC(10,2),
  unit_type TEXT DEFAULT 'per_person', -- 'per_person', 'per_unit', 'fixed'
  image_url TEXT,
  provider_id UUID REFERENCES auth.users(id),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les recherches
CREATE INDEX IF NOT EXISTS idx_product_catalog_category ON public.product_catalog(category);
CREATE INDEX IF NOT EXISTS idx_product_catalog_name ON public.product_catalog(name);
CREATE INDEX IF NOT EXISTS idx_product_catalog_provider ON public.product_catalog(provider_id);

-- Créer la table des devis
CREATE TABLE IF NOT EXISTS public.quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id UUID REFERENCES auth.users(id) NOT NULL,
  client_id UUID REFERENCES auth.users(id) NOT NULL,
  room_id UUID REFERENCES public.chat_rooms(id),
  items JSONB NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL,
  commission NUMERIC(10,2) NOT NULL,
  total NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'draft',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT quotes_status_check CHECK (status IN ('draft', 'sent', 'accepted', 'rejected', 'expired'))
);

-- Index pour la table quotes
CREATE INDEX IF NOT EXISTS idx_quotes_organizer ON public.quotes(organizer_id);
CREATE INDEX IF NOT EXISTS idx_quotes_client ON public.quotes(client_id);
CREATE INDEX IF NOT EXISTS idx_quotes_room ON public.quotes(room_id);
CREATE INDEX IF NOT EXISTS idx_quotes_status ON public.quotes(status);

-- Trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_catalog_updated_at
    BEFORE UPDATE ON public.product_catalog
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quotes_updated_at
    BEFORE UPDATE ON public.quotes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security)
ALTER TABLE public.product_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

-- Policies pour product_catalog
CREATE POLICY "Anyone can view active products"
ON public.product_catalog FOR SELECT
USING (is_active = TRUE);

CREATE POLICY "Providers can manage their products"
ON public.product_catalog FOR ALL
USING (auth.uid() = provider_id);

-- Policies pour quotes
CREATE POLICY "Users can view their own quotes"
ON public.quotes FOR SELECT
USING (auth.uid() = organizer_id OR auth.uid() = client_id);

CREATE POLICY "Organizers can create quotes"
ON public.quotes FOR INSERT
WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "Organizers can update their quotes"
ON public.quotes FOR UPDATE
USING (auth.uid() = organizer_id);

-- Seed initial de produits de test
INSERT INTO public.product_catalog (name, category, description, base_price, unit_type) VALUES
-- Pâtisserie
('Gâteau 1 étage classique', 'patisserie', 'Gâteau simple avec glaçage', 1500, 'per_person'),
('Gâteau 2 étages personnalisé', 'patisserie', 'Gâteau avec décoration personnalisée', 2000, 'per_person'),
('Gâteau 3 étages premium', 'patisserie', 'Gâteau de luxe avec décoration complexe', 3000, 'per_person'),
('Cupcakes assortis', 'patisserie', 'Assortiment de mini-gâteaux', 500, 'per_unit'),
('Macarons', 'patisserie', 'Macarons artisanaux', 300, 'per_unit'),

-- Traiteur
('Buffet standard', 'traiteur', 'Buffet avec entrées, plats et desserts', 5000, 'per_person'),
('Buffet premium', 'traiteur', 'Buffet gastronomique', 8000, 'per_person'),
('Cocktail dînatoire', 'traiteur', 'Assortiment de canapés et boissons', 4000, 'per_person'),

-- Décoration
('Décoration florale table', 'decoration', 'Arrangements floraux pour tables', 15000, 'fixed'),
('Arche florale', 'decoration', 'Grande arche de fleurs pour cérémonie', 50000, 'fixed'),
('Ballons décoration', 'decoration', 'Lot de 100 ballons avec arche', 25000, 'fixed'),
('Nappe et housses de chaises', 'decoration', 'Location de nappes et housses', 500, 'per_unit'),

-- Location
('Chaises pliantes', 'location', 'Location de chaises standard', 500, 'per_unit'),
('Tables rondes (10 pers)', 'location', 'Tables rondes pour 10 personnes', 5000, 'per_unit'),
('Tente (50 pers)', 'location', 'Tente pour 50 personnes', 100000, 'fixed'),
('Sono et lumières', 'location', 'Pack audiovisuel complet', 150000, 'fixed'),

-- Animation
('DJ professionnel', 'animation', 'DJ avec matériel pour 5h', 100000, 'fixed'),
('Groupe musical', 'animation', 'Groupe live 3h', 200000, 'fixed'),
('Photographe', 'animation', 'Photographe professionnel 6h', 150000, 'fixed'),
('Vidéaste', 'animation', 'Vidéaste avec montage', 200000, 'fixed')
ON CONFLICT DO NOTHING;
