
-- Drop dependent views and constraints before dropping jobs table
DROP VIEW IF EXISTS public.v_job_split_inhouse;
DROP VIEW IF EXISTS public.v_job_split_subcontractor;
DROP VIEW IF EXISTS public.v_job_financial_breakdown;
DROP VIEW IF EXISTS public.job_financials;
ALTER TABLE IF EXISTS public.parts DROP CONSTRAINT IF EXISTS parts_job_id_fkey;

DROP TABLE IF EXISTS public.jobs;

DROP TYPE IF EXISTS payment_mode_enum;
CREATE TYPE payment_mode_enum AS ENUM ('credit card', 'cash', 'check', 'zelle');

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

  payment_mode payment_mode_enum,
  cash_on_hand numeric(12,2) not null default 0.00, -- new column

  status text not null default 'pending',
  notes text,

  created_at timestamptz not null default now()
);

-- Restore foreign key constraint
ALTER TABLE public.parts ADD CONSTRAINT parts_job_id_fkey FOREIGN KEY (job_id) REFERENCES public.jobs(id) ON DELETE SET NULL;

-- This updates jobs table to include cash_on_hand column for tracking cash payments.
-- The payment_mode column is now an ENUM type for better data integrity.


-- Updates views

-- Recreate views
CREATE VIEW public.job_financials AS
SELECT
  j.id,
  j.subtotal AS gross,
  j.parts_total_cost,
  (j.subtotal - j.parts_total_cost) AS net,
  j.tip_amount,
  j.total_amount,
  j.status,
  j.technician_id,
  j.cash_on_hand,
  (j.subtotal - j.cash_on_hand) AS balance
FROM public.jobs j;

CREATE OR REPLACE VIEW public.v_job_financial_breakdown AS
SELECT
  j.id,
  j.job_date,
  j.status,
  j.region,
  j.technician_id,

  j.subtotal AS gross,
  j.parts_total_cost,
  (j.subtotal - j.parts_total_cost) AS net,

  j.tip_amount,
  j.total_amount AS total_collected,

  (j.total_amount - j.parts_total_cost) AS net_plus_tip,

  j.cash_on_hand,
  (j.subtotal - j.cash_on_hand) AS balance
FROM public.jobs j;

-- Recreate dependent views
create or replace view public.v_job_split_subcontractor as
select
  f.*,
  (f.net * 0.50) as subcontractor_pay,
  (f.net * 0.50) as company_profit
from public.v_job_financial_breakdown f;

create or replace view public.v_job_split_inhouse as
select
  f.*,
  (f.net * 0.75) as technician_pay,
  (f.net * 0.25) as company_profit
from public.v_job_financial_breakdown f;