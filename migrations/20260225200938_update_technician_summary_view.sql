CREATE OR REPLACE VIEW public.v_technician_summary AS
SELECT
  t.id AS technician_id,
  t.name,
  t.email,
  t.phone,
  t.hired_date,
  t.default_commission_rate AS commission_rate,

  COUNT(j.id) AS total_jobs,

  COALESCE(SUM(j.subtotal), 0) AS total_gross,
  COALESCE(SUM(j.parts_total_cost), 0) AS total_parts_cost,

  -- net revenue is gross minus parts cost
  COALESCE(SUM(j.subtotal - j.parts_total_cost), 0) AS total_net,

  -- net revenue multiplied by commission rate to get total earned
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * t.default_commission_rate), 0) AS total_earned,

  -- net revenue multiplied by 1 - commission rate to get total earned by company
  -- 1 - 0.75 = 0.25 (which directly gives us the company's share of the net revenue)
  COALESCE(SUM((j.subtotal - j.parts_total_cost) * (1 - t.default_commission_rate)), 0) AS total_company_earned

FROM public.technicians t
LEFT JOIN public.jobs j
  ON j.technician_id = t.id
  AND j.status = 'done'
GROUP BY t.id, t.name, t.email, t.phone, t.hired_date, t.default_commission_rate;
