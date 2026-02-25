DROP VIEW IF EXISTS public.v_job_split_subcontractor;
create or replace view public.v_job_split_subcontractor as
select
  f.*,
  (f.net * 0.50) as subcontractor_pay,
  (f.net * 0.50) as company_profit
from public.v_job_financial_breakdown f;