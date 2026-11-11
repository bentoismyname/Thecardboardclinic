
-- V6 Cardboard Clinic consent and counter migration. Run AFTER V5 upgrade.
-- Historical baseline is 53 previously completed cards; newly closed records add separately.
update public.clinic_settings set historical_completed=53 where id=1 and historical_completed=0;

create table if not exists public.case_consents (
 id uuid primary key default gen_random_uuid(),
 case_id uuid not null references public.cards(id) on delete cascade,
 agreement_version text not null,
 scope_snapshot text not null,
 signer_name text not null check(length(trim(signer_name))>=2),
 signer_capacity text not null default 'Owner',
 marketing_consent boolean not null default false,
 acknowledgements integer[] not null,
 created_at timestamptz not null default now(),
 admin_verified_at timestamptz,
 verified_by uuid references auth.users(id),
 unique(case_id,scope_snapshot,agreement_version),
 constraint consent_all_acknowledged check(acknowledgements = array[1,2,3,4,5,6,7])
);
create index if not exists case_consents_case_id_idx on public.case_consents(case_id);
alter table public.case_consents enable row level security;
grant select,insert,update on public.case_consents to authenticated;
drop policy if exists consent_read on public.case_consents;
create policy consent_read on public.case_consents for select to authenticated using(
 public.is_staff() or exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))));
drop policy if exists consent_sign on public.case_consents;
create policy consent_sign on public.case_consents for insert to authenticated with check(
 admin_verified_at is null and verified_by is null and
 exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email','')) and c.quote_status='issued' and c.quote_amount is not null));
drop policy if exists consent_verify_staff on public.case_consents;
create policy consent_verify_staff on public.case_consents for update to authenticated using(public.is_staff()) with check(public.is_staff());

-- Compare actual current card scope to the signed snapshot server-side.
create or replace function public.card_consent_scope(c public.cards)
returns text language sql stable as $$
 select json_build_object('quote_amount',c.quote_amount,'treatment_codes',(select coalesce(json_agg(v order by v),'[]'::json) from unnest(c.treatment_codes) as v),'priority_service',c.priority_service,'quote_notes',c.quote_notes,'market_value',c.market_value)::text;
$$;
-- Snapshot may be compared through JSONB instead of JSON field order.
create or replace function public.guard_treatment_consent() returns trigger language plpgsql security definer set search_path=public as $$
declare valid_count integer;
begin
 if new.stage>=7 then
  select count(*) into valid_count from public.case_consents a
  where a.case_id=new.id and a.admin_verified_at is not null
    and a.agreement_version='CC-CONSENT-2026-11-v1'
    and a.scope_snapshot::jsonb=public.card_consent_scope(new)::jsonb;
  if valid_count=0 then raise exception 'Signed and admin-verified consent for the current quotation is required before scheduling or treatment.'; end if;
 end if;
 return new;
end $$;
drop trigger if exists cards_guard_consent on public.cards;
create trigger cards_guard_consent before insert or update on public.cards for each row execute function public.guard_treatment_consent();

-- Strict: a consent may only be verified if the scope still matches.
create or replace function public.guard_consent_record() returns trigger language plpgsql security definer set search_path=public as $$
declare c public.cards;
begin
 select * into c from public.cards where id=new.case_id;
 if c.id is null then raise exception 'Card not found'; end if;
 if new.scope_snapshot::jsonb<>public.card_consent_scope(c)::jsonb then raise exception 'Consent must match the currently issued quotation'; end if;
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
drop trigger if exists case_consents_guard on public.case_consents;
create trigger case_consents_guard before insert or update on public.case_consents for each row execute function public.guard_consent_record();
