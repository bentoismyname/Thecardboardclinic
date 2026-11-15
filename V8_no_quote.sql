-- V8: no quotes. Clients sign the consent form as soon as their card is registered.
-- Run once in Supabase > SQL Editor.

drop policy if exists consent_sign on public.case_consents;
create policy consent_sign on public.case_consents for insert to authenticated with check(
 admin_verified_at is null and verified_by is null and
 exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))));

create or replace function public.guard_treatment_consent() returns trigger language plpgsql security definer set search_path=public as $$
declare valid_count integer;
begin
 if new.stage>=7 then
  select count(*) into valid_count from public.case_consents a
  where a.case_id=new.id and a.admin_verified_at is not null
    and a.agreement_version='CC-CONSENT-2026-11-v1';
  if valid_count=0 then raise exception 'A signed and admin-verified consent form is required before payment and treatment.'; end if;
 end if;
 return new;
end $$;

create or replace function public.guard_consent_record() returns trigger language plpgsql security definer set search_path=public as $$
declare c public.cards;
begin
 select * into c from public.cards where id=new.case_id;
 if c.id is null then raise exception 'Card not found'; end if;
 if tg_op='INSERT' then
  if new.admin_verified_at is not null then raise exception 'Cannot self-verify consent';end if;
 elsif tg_op='UPDATE' then
  if not public.is_staff() then raise exception 'Staff authorisation required'; end if;
  if (old.case_id,old.agreement_version,old.scope_snapshot,old.signer_name,old.signer_capacity,old.marketing_consent,old.acknowledgements,old.created_at)
    is distinct from (new.case_id,new.agreement_version,new.scope_snapshot,new.signer_name,new.signer_capacity,new.marketing_consent,new.acknowledgements,new.created_at)
  then raise exception 'Signed agreement records are immutable';end if;
  if old.admin_verified_at is not null then raise exception 'Already verified';end if;
  if new.admin_verified_at is null or new.verified_by<>auth.uid() then raise exception 'Staff verification identity required';end if;
 end if;
 return new;
end $$;
