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
  COALESCE(SUM(j.subtotal - j.parts_total_cost), 0) AS total_net,

  COALESCE(SUM(j.subtotal * (t.default_commission_rate / 100.0)), 0) AS total_earned

FROM public.technicians t
LEFT JOIN public.jobs j
  ON j.technician_id = t.id
  AND j.status = 'done'
GROUP BY t.id, t.name, t.email, t.phone, t.hired_date, t.default_commission_rate;
