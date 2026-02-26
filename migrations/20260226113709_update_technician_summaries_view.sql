
CREATE OR REPLACE VIEW public.v_technician_summary AS
SELECT
  t.id AS technician_id,
  t.name,
  t.email,
  t.phone,
  t.hired_date,
  t.created_at,
  t.default_commission_rate AS commission_rate,

  COUNT(j.id) AS total_jobs,

  COALESCE(SUM(j.subtotal), 0) AS total_gross,
  COALESCE(SUM(j.parts_total_cost), 0) AS total_parts_cost,

  -- net revenue is gross minus parts cost
  COALESCE(SUM(j.subtotal - j.parts_total_cost), 0) AS total_net,

  -- net revenue multiplied by commission rate to get total earned
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * t.default_commission_rate / 100), 0) AS total_earned,

  -- net revenue multiplied by 1 - commission rate to get total earned by company
  -- 1 - 0.75 = 0.25 (which directly gives us the company's share of the net revenue)
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate / 100)), 0) AS total_company_earned

FROM public.technicians t
LEFT JOIN public.jobs j
  ON j.technician_id = t.id
  AND j.status = 'done'
  AND j.deleted_at IS NULL
GROUP BY t.id, t.name, t.email, t.phone, t.hired_date, t.default_commission_rate;


-- Monthly summary of technician performance, including total jobs, gross/net earnings, and company share.
create or replace view public.v_technician_monthly_summary as
select
  t.id as technician_id,
  t.name,
  t.created_at,
  date_trunc('month', j.job_date) as month,
  to_char(date_trunc('month', j.job_date), 'YYYY-MM') as year_month,

  count(j.id) as total_jobs,

  coalesce(sum(j.subtotal), 0) as total_gross,
  coalesce(sum(j.parts_total_cost), 0) as total_parts_cost,
  coalesce(sum(j.subtotal - j.parts_total_cost), 0) as total_net,

  coalesce(
    sum((j.subtotal - j.parts_total_cost) * t.default_commission_rate / 100 ),
    0
  ) as total_earned,

  coalesce(
    sum((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate / 100 )),
    0
  ) as total_company_earned

from technicians t
left join jobs j
  on j.technician_id = t.id
  and j.status = 'done'
  and j.deleted_at IS NULL
group by
  t.id,
  t.name,
  t.created_at,
  date_trunc('month', j.job_date);