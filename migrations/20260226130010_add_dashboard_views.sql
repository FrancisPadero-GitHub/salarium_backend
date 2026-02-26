-- Enhanced job-level financial breakdown and dashboard views

-- This migration adds richer job breakdown data (including technician and commission)
-- plus aggregate views for charts and dashboard cards.

-- 1) Enhanced job-level financial breakdown
-- Drop dependent split views and the old breakdown view so we can safely
-- change the column layout without column name/order conflicts.
DROP VIEW IF EXISTS public.v_job_split_inhouse;
DROP VIEW IF EXISTS public.v_job_split_subcontractor;
DROP VIEW IF EXISTS public.v_job_financial_breakdown;

CREATE VIEW public.v_job_financial_breakdown AS
WITH job_data AS (
  SELECT
    j.id,
    j.job_date,
    j.address,
    j.region,
    j.status,
    j.created_at,
    j.payment_mode,
    j.technician_id,
    j.parts_total_cost,
    j.tip_amount,
    j.subtotal,
    j.total_amount,
    j.cash_on_hand,
    j.deleted_at,
    t.name AS technician_name,
    t.default_commission_rate,
    (j.subtotal - j.parts_total_cost) AS net_revenue,
    COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0) AS technician_commission
  FROM public.jobs j
  LEFT JOIN public.technicians t
    ON j.technician_id = t.id
)
SELECT
  jd.id,
  jd.job_date,
  jd.address,
  jd.region,
  jd.status,
  jd.created_at,
  jd.payment_mode,
  jd.technician_id,
  jd.technician_name,
  jd.default_commission_rate,

  -- money columns
  jd.subtotal AS subtotal,
  jd.subtotal AS gross,
  jd.parts_total_cost,
  jd.net_revenue AS net,
  jd.technician_commission AS commission,
  (jd.net_revenue - jd.technician_commission) AS company_net,

  jd.tip_amount,
  jd.total_amount AS total_collected,
  (jd.total_amount - jd.parts_total_cost) AS net_plus_tip,

  jd.cash_on_hand,
  (jd.subtotal - jd.cash_on_hand) AS balance
FROM job_data jd
WHERE jd.deleted_at IS NULL;

-- 2) Job revenue view for "Top Jobs by Revenue" charts
CREATE OR REPLACE VIEW public.v_jobs_revenue AS
SELECT
  j.id,
  j.job_date,
  j.address,
  j.region,
  j.status,
  j.created_at,
  j.payment_mode,
  j.technician_id,
  t.name AS technician_name,
  t.default_commission_rate,

  (j.subtotal - j.parts_total_cost) AS net_revenue,
  COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0) AS technician_commission,
  (j.subtotal - j.parts_total_cost)
    - COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0) AS company_net,

  j.subtotal AS subtotal,
  j.total_amount AS total_collected,
  j.tip_amount,
  j.parts_total_cost
FROM public.jobs j
LEFT JOIN public.technicians t
  ON j.technician_id = t.id
WHERE j.status = 'done'
  AND j.deleted_at IS NULL;


-- 3) Monthly financials for year-to-date / trend charts
CREATE OR REPLACE VIEW public.v_monthly_financials AS
WITH job_data AS (
  SELECT
    j.job_date,
    j.status,
    j.deleted_at,
    j.subtotal,
    j.parts_total_cost,
    (j.subtotal - j.parts_total_cost) AS net_revenue,
    COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0) AS technician_commission
  FROM public.jobs j
  LEFT JOIN public.technicians t
    ON j.technician_id = t.id
)
SELECT
  date_trunc('month', job_date) AS month,
  to_char(date_trunc('month', job_date), 'YYYY-MM') AS year_month,

  COUNT(*) AS total_jobs,
  COALESCE(SUM(subtotal), 0) AS total_gross,
  COALESCE(SUM(parts_total_cost), 0) AS total_parts_cost,
  COALESCE(SUM(net_revenue), 0) AS total_net_revenue,
  COALESCE(SUM(technician_commission), 0) AS total_commissions,
  COALESCE(SUM(net_revenue - technician_commission), 0) AS total_company_net
FROM job_data
WHERE status = 'done'
  AND deleted_at IS NULL
GROUP BY
  date_trunc('month', job_date),
  to_char(date_trunc('month', job_date), 'YYYY-MM')
ORDER BY month;


-- 4) Single-row dashboard KPIs for cards
CREATE OR REPLACE VIEW public.v_job_dashboard_cards AS
WITH job_data AS (
  SELECT
    j.id,
    j.job_date,
    j.status,
    j.deleted_at,
    j.subtotal,
    j.parts_total_cost,
    (j.subtotal - j.parts_total_cost) AS net_revenue,
    COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0) AS technician_commission
  FROM public.jobs j
  LEFT JOIN public.technicians t
    ON j.technician_id = t.id
)
SELECT
  -- total jobs (all time, completed)
  COUNT(id) FILTER (WHERE status = 'done' AND deleted_at IS NULL) AS total_jobs,

  -- total gross (all time)
  COALESCE(SUM(subtotal) FILTER (WHERE status = 'done' AND deleted_at IS NULL), 0) AS total_gross,

  -- total commissions paid to technicians (all time)
  COALESCE(SUM(technician_commission) FILTER (WHERE status = 'done' AND deleted_at IS NULL), 0) AS total_commissions,

  -- total company net (all time)
  COALESCE(SUM(net_revenue - technician_commission) FILTER (WHERE status = 'done' AND deleted_at IS NULL), 0) AS total_company_net,

  -- year-to-date gross revenue (based on job_date)
  COALESCE(
    SUM(subtotal)
      FILTER (
        WHERE status = 'done'
          AND deleted_at IS NULL
          AND job_date >= date_trunc('year', CURRENT_DATE)
      ),
    0
  ) AS ytd_gross_revenue,

  -- average revenue per completed job (gross)
  CASE
    WHEN COUNT(id) FILTER (WHERE status = 'done' AND deleted_at IS NULL) > 0 THEN
      COALESCE(SUM(subtotal) FILTER (WHERE status = 'done' AND deleted_at IS NULL), 0)
      / COUNT(id) FILTER (WHERE status = 'done' AND deleted_at IS NULL)
    ELSE 0
  END AS avg_revenue_per_job,

  -- active technicians (based on deleted_at)
  (SELECT COUNT(*) FROM public.technicians t WHERE t.deleted_at IS NULL) AS active_technicians
FROM job_data;
