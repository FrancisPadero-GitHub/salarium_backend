DROP TABLE IF EXISTS public.estimates;
create table public.estimates (
  id uuid primary key default gen_random_uuid(),

  estimate_date date not null,
  address text,
  description text,
  amount numeric(12,2) not null,

  technician_id uuid references public.technicians(id) on delete set null,

  status text not null default 'pending',
  handled_by text,
  notes text,

  created_at timestamptz not null default now()
);