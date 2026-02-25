DROP TABLE IF EXISTS public.technicians;
create table public.technicians (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  default_commission_rate numeric(5,2) not null default 75.00, -- 75.00 means 75%
  created_at timestamptz not null default now()
);