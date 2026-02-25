-- adds column on the technicians table
ALTER TABLE public.technicians
ADD COLUMN email text,
ADD COLUMN phone text,
ADD COLUMN hired_date date;