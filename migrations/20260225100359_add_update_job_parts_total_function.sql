-- Drop trigger and function if they exist (optional, for idempotency)
drop trigger if exists trigger_update_job_parts_total on public.parts;
drop function if exists public.update_job_parts_total;

create or replace function public.update_job_parts_total()
returns trigger as $$
begin
  update public.jobs
  set parts_total_cost = (
    select coalesce(sum(amount),0)
    from public.parts
    where job_id = coalesce(new.job_id, old.job_id)
  )
  where id = coalesce(new.job_id, old.job_id);

  return null;
end;
$$ language plpgsql;

-- Trigger

create trigger trigger_update_job_parts_total
after insert or update or delete on public.parts
for each row
execute function public.update_job_parts_total();