DROP VIEW IF EXISTS public.v_job_split_inhouse;
create or replace view public.v_job_split_inhouse as
select
  f.*,
  (f.net * 0.75) as technician_pay,
  (f.net * 0.25) as company_profit
from public.v_job_financial_breakdown f;