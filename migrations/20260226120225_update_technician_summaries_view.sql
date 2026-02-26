DROP VIEW IF EXISTS public.v_technician_monthly_summary CASCADE;
DROP VIEW IF EXISTS public.v_technician_summary CASCADE;

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
  COALESCE(SUM(j.subtotal - j.parts_total_cost), 0) AS total_net,
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * t.default_commission_rate / 100), 0) AS total_earned,
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate / 100)), 0) AS total_company_earned

FROM public.technicians t
LEFT JOIN public.jobs j
  ON j.technician_id = t.id
  AND j.status = 'done'
  AND j.deleted_at IS NULL
WHERE t.deleted_at IS NULL
GROUP BY t.id, t.name, t.email, t.phone, t.hired_date, t.default_commission_rate;

CREATE OR REPLACE VIEW public.v_technician_monthly_summary AS
SELECT
  t.id AS technician_id,
  t.name,
  t.created_at,
  date_trunc('month', j.job_date) AS month,
  to_char(date_trunc('month', j.job_date), 'YYYY-MM') AS year_month,
  count(j.id) AS total_jobs,
  coalesce(sum(j.subtotal), 0) AS total_gross,
  coalesce(sum(j.parts_total_cost), 0) AS total_parts_cost,
  coalesce(sum(j.subtotal - j.parts_total_cost), 0) AS total_net,
  coalesce(sum((j.subtotal - j.parts_total_cost) * t.default_commission_rate / 100 ), 0) AS total_earned,
  coalesce(sum((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate / 100 )), 0) AS total_company_earned
FROM public.technicians t
LEFT JOIN public.jobs j
  ON j.technician_id = t.id
  AND j.status = 'done'
  AND j.deleted_at IS NULL
WHERE t.deleted_at IS NULL
GROUP BY t.id, t.name, t.created_at, date_trunc('month', j.job_date);