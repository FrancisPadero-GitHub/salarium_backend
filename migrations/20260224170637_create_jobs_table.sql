create table public.jobs (
  id uuid primary key default gen_random_uuid(),
  created_at timestamp with time zone default now(),
  technician_id uuid not null,
  subtotal numeric not null,
  parts numeric default 0,
  tips numeric default 0,
  total numeric generated always as (subtotal + parts + tips) stored
);