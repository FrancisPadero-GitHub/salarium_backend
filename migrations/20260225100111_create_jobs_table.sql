DROP TABLE IF EXISTS public.jobs;
create table public.jobs (
  id uuid primary key default gen_random_uuid(),

  job_date date not null,
  address text,
  region text,

  technician_id uuid references public.technicians(id) on delete set null,

  parts_total_cost numeric(12,2) not null default 0.00,
  tip_amount numeric(12,2) not null default 0.00,
  subtotal numeric(12,2) not null,
  total_amount numeric(12,2) generated always as (subtotal + tip_amount) stored,

  payment_mode text,
  status text not null default 'pending',
  notes text,

  created_at timestamptz not null default now()
);