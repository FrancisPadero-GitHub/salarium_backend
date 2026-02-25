DROP VIEW IF EXISTS public.job_financials;
create view public.job_financials as
select
  j.id,
  j.subtotal as gross,
  j.parts_total_cost,
  (j.subtotal - j.parts_total_cost) as net,
  j.tip_amount,
  j.total_amount,
  j.status,
  j.technician_id
from public.jobs j;