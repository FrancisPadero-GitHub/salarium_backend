create or replace view public.v_technician_monthly_summary as
select
  t.id as technician_id,
  t.name,

  date_trunc('month', j.job_date) as month,
  to_char(date_trunc('month', j.job_date), 'YYYY-MM') as year_month,

  count(j.id) as total_jobs,

  coalesce(sum(j.subtotal), 0) as total_gross,
  coalesce(sum(j.parts_total_cost), 0) as total_parts_cost,
  coalesce(sum(j.subtotal - j.parts_total_cost), 0) as total_net,

  coalesce(
    sum((j.subtotal - j.parts_total_cost) * t.default_commission_rate ),
    0
  ) as total_earned,

  coalesce(
    sum((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate )),
    0
  ) as total_company_earned

from technicians t
left join jobs j
  on j.technician_id = t.id
  and j.status = 'done'

group by
  t.id,
  t.name,
  date_trunc('month', j.job_date);