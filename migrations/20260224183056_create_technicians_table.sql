CREATE TABLE IF NOT EXISTS public.technicians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  default_commission_rate DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);