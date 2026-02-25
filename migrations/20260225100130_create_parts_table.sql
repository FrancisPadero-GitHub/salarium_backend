DROP TABLE IF EXISTS public.parts;
create table public.parts (
  id uuid primary key default gen_random_uuid(),

  job_id uuid not null references public.jobs(id) on delete cascade,

  name text not null,
  unit_cost numeric(12,2) not null,
  quantity integer not null check (quantity > 0),

  amount numeric(12,2) generated always as (unit_cost * quantity) stored,

  created_at timestamptz not null default now()
);
