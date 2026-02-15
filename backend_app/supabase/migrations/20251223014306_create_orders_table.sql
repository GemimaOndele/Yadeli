-- Table des commandes Yadeli (format compatible avec l'app Flutter)
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  category TEXT NOT NULL,
  total_price NUMERIC(10, 2) NOT NULL,
  pickup_data JSONB DEFAULT '{}',
  delivery_data JSONB DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour les requêtes par client
CREATE INDEX IF NOT EXISTS idx_orders_client_id ON public.orders(client_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);

-- RLS activé (les Edge Functions utilisent le service_role qui bypass)
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Politique : les utilisateurs peuvent voir leurs propres commandes
CREATE POLICY "Users can view own orders"
  ON public.orders FOR SELECT
  USING (auth.uid() = client_id);
