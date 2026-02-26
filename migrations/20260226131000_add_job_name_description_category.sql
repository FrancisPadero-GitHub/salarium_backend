-- Add job_name, description, and category columns to the jobs table,
-- then refresh the views that expose job-level detail.

-- 1) Extend the jobs table
ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS job_name    TEXT NULL,
  ADD COLUMN IF NOT EXISTS description TEXT NULL,
  ADD COLUMN IF NOT EXISTS category    TEXT NULL;


DROP VIEW IF EXISTS public.v_job_financial_breakdown;

CREATE VIEW public.v_job_financial_breakdown AS
WITH job_data AS (
  SELECT
    j.id,
    j.job_date,
    j.job_name,
    j.description,
    j.category,
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
    t.name                   AS technician_name,
    t.default_commission_rate,
    (j.subtotal - j.parts_total_cost)                                                          AS net_revenue,
    COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0)      AS technician_commission
  FROM public.jobs j
  LEFT JOIN public.technicians t ON j.technician_id = t.id
)
SELECT
  jd.id,
  jd.job_date,
  jd.job_name,
  jd.description,
  jd.category,
  jd.address,
  jd.region,
  jd.status,
  jd.created_at,
  jd.payment_mode,
  jd.technician_id,
  jd.technician_name,
  jd.default_commission_rate,

  -- money columns
  jd.subtotal                                      AS subtotal,
  jd.subtotal                                      AS gross,
  jd.parts_total_cost,
  jd.net_revenue                                   AS net,
  jd.technician_commission                         AS commission,
  (jd.net_revenue - jd.technician_commission)      AS company_net,

  jd.tip_amount,
  jd.total_amount                                  AS total_collected,
  (jd.total_amount - jd.parts_total_cost)          AS net_plus_tip,

  jd.cash_on_hand,
  (jd.subtotal - jd.cash_on_hand)                  AS balance
FROM job_data jd
WHERE jd.deleted_at IS NULL;


DROP VIEW IF EXISTS public.v_jobs_revenue;
CREATE VIEW public.v_jobs_revenue AS
SELECT
  j.id,
  j.job_date,
  j.job_name,
  j.description,
  j.category,
  j.address,
  j.region,
  j.status,
  j.created_at,
  j.payment_mode,
  j.technician_id,
  t.name                                                                                        AS technician_name,
  t.default_commission_rate,

  (j.subtotal - j.parts_total_cost)                                                            AS net_revenue,
  COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0)        AS technician_commission,
  (j.subtotal - j.parts_total_cost)
    - COALESCE((j.subtotal - j.parts_total_cost) * (t.default_commission_rate / 100.0), 0)    AS company_net,

  j.subtotal        AS subtotal,
  j.total_amount    AS total_collected,
  j.tip_amount,
  j.parts_total_cost
FROM public.jobs j
LEFT JOIN public.technicians t ON j.technician_id = t.id
WHERE j.status     = 'done'
  AND j.deleted_at IS NULL;
