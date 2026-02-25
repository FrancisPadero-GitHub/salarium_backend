DROP VIEW IF EXISTS public.v_job_financial_breakdown;
create or replace view public.v_job_financial_breakdown as
select
  j.id,
  j.job_date,
  j.status,
  j.region,
  j.technician_id,

  j.subtotal as gross,
  j.parts_total_cost,
  (j.subtotal - j.parts_total_cost) as net,

  j.tip_amount,
  j.total_amount as total_collected,

  (j.total_amount - j.parts_total_cost) as net_plus_tip

from public.jobs j;