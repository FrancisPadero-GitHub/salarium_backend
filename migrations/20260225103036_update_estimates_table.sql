-- name: Update estimates table to use enum for status
create type public.estimate_status as enum (
  'approved',
  'not_approved',
  'follow_up'
);

alter table public.estimates
alter column status drop default;

-- Alter the estimates table to change the status column to use the new enum type
alter table public.estimates
alter column status type public.estimate_status
using status::public.estimate_status;


-- Set the default value for the status column to 'follow_up'
alter table public.estimates
alter column status set default 'follow_up';

-- Add a new column to the jobs table to reference the estimates table
alter table public.jobs
add column estimate_id uuid unique references public.estimates(id) on delete cascade;


-- Function to sync estimates to jobs based on status changes
create or replace function public.sync_estimate_to_job()
returns trigger as $$
begin

  -- If approved → create job if it does not exist
  if new.status = 'approved' then

    insert into public.jobs (
      job_date,
      address,
      technician_id,
      subtotal,
      estimate_id,
      status
    )
    values (
      new.estimate_date,
      new.address,
      new.technician_id,
      new.amount,
      new.id,
      'pending'
    )
    on conflict (estimate_id) do nothing;

  end if;


  -- If changed to not_approved → delete job
  if new.status = 'not_approved' then

    delete from public.jobs
    where estimate_id = new.id;

  end if;

  return new;
end;
$$ language plpgsql;


-- its trigger to call the function on updates to the estimates table
create trigger trigger_sync_estimate_to_job
after update of status on public.estimates
for each row
execute function public.sync_estimate_to_job();