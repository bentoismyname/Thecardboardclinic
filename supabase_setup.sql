-- CARDBOARD CLINIC | Supabase SQL backend
-- Run once in your own Supabase project's SQL Editor.
-- Uses Supabase Auth for customer/staff email+password sign-in.
-- Staff create cards; customers have READ access only to their own cards,
-- and can record a ONE-TIME decision on their issued quote.
-- IMPORTANT: Never put your service_role key in the public HTML.

create extension if not exists pgcrypto;

create table if not exists public.staff (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_staff()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.staff where user_id=auth.uid()) $$;

create table if not exists public.pricing_services (
  code text primary key,
  label text not null,
  detail text not null default '',
  base numeric(12,2) not null check (base >= 0),
  category text not null check (category in ('care','restore')),
  sort_order integer not null default 100,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.pricing_tiers (
  id smallint primary key,
  label text not null,
  min_value numeric(14,2) not null,
  max_value numeric(14,2),
  multiplier numeric(8,3),
  check(max_value is null or max_value >= min_value),
  check(multiplier is null or multiplier > 0)
);

create table if not exists public.clinic_settings (
  id smallint primary key default 1 check (id=1),
  capacity integer not null default 25 check (capacity between 1 and 1000),
  weekly_rate integer not null default 5 check (weekly_rate between 1 and 200),
  updated_at timestamptz not null default now()
);

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  ref text unique not null,
  client_name text not null,
  owner_email text not null,
  card_name text not null,
  set_name text not null default '',
  card_number text not null default '',
  card_year text not null default '',
  declared_value numeric(14,2) not null default 0 check (declared_value >= 0),
  market_value numeric(14,2) not null default 0 check (market_value >= 0),
  treatment_codes text[] not null default '{}',
  priority_service boolean not null default false,
  quote_amount numeric(14,2) check (quote_amount >= 0),
  quote_status text not null default 'pending' check(quote_status in ('pending','issued','approved','declined')),
  quote_notes text not null default '',
  notes text not null default '',
  stage smallint not null default 1 check (stage between 1 and 11),
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists cards_owner_email_idx on public.cards (lower(owner_email));
create index if not exists cards_open_idx on public.cards (closed_at);

create table if not exists public.case_updates (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references public.cards(id) on delete cascade,
  stage smallint not null check(stage between 1 and 11),
  message text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists case_updates_case_id_idx on public.case_updates (case_id,created_at desc);

create table if not exists public.case_photos (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null references public.cards(id) on delete cascade,
  phase text not null check(phase in ('before','during','after')),
  storage_path text not null unique,
  created_at timestamptz not null default now()
);
create index if not exists case_photos_case_id_idx on public.case_photos (case_id);

create table if not exists public.quote_decisions (
  id uuid primary key default gen_random_uuid(),
  case_id uuid not null unique references public.cards(id) on delete cascade,
  decision text not null check (decision in ('approved','declined')),
  created_at timestamptz not null default now()
);

create table if not exists public.client_reviews (
  id uuid primary key default gen_random_uuid(),
  display_name text not null,
  review_source text not null,
  review_text text not null,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create or replace function public.update_timestamp()
returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end $$;
drop trigger if exists cards_updated_at on public.cards;
create trigger cards_updated_at before update on public.cards for each row execute procedure public.update_timestamp();
drop trigger if exists clinic_settings_updated_at on public.clinic_settings;
create trigger clinic_settings_updated_at before update on public.clinic_settings for each row execute procedure public.update_timestamp();
drop trigger if exists pricing_services_updated_at on public.pricing_services;
create trigger pricing_services_updated_at before update on public.pricing_services for each row execute procedure public.update_timestamp();

-- Initial launch prices are recommendations, not third-party market tariffs.
insert into public.pricing_services(code,label,detail,base,category,sort_order) values
('assessment','Preliminary Photo Assessment','Initial visual opinion from supplied photos',0,'care',1),
('report','Physical Condition Report','Written inspection and treatment recommendations',15,'care',2),
('surface','Surface Cleaning','Dust and accessible surface contamination',25,'care',3),
('residue','Residue / Adhesive Removal','Case-dependent accessible adhesive residue',35,'care',4),
('edge','Edge / Corner Lift Reduction','Lifted layers; not whitening or lost print',40,'restore',5),
('warp','Warping / Curling Treatment','Case-by-case shape and curl assessment',45,'restore',6),
('dent','Dent / Indent Reduction','Pressure marks and small dings',50,'restore',7),
('crease','Minor Crease Reduction','Visible fold or crease; outcomes vary',70,'restore',8),
('complex','Complex Crease / Layer Separation','Specialist treatment; custom above baseline',100,'restore',9),
('slab','Graded Slab Extraction','Removal only with owner consent and accepted risk',20,'care',10)
on conflict(code) do nothing;

insert into public.pricing_tiers(id,label,min_value,max_value,multiplier) values
(1,'Below S$200',0,199.99,1),(2,'S$200–S$999',200,999.99,1.2),
(3,'S$1,000–S$4,999',1000,4999.99,1.5),(4,'S$5,000+',5000,null,null)
on conflict(id) do nothing;
insert into public.clinic_settings(id,capacity,weekly_rate) values(1,25,5) on conflict(id) do nothing;

-- Roles & Row Level Security: clients CANNOT insert or edit case records.
alter table public.staff enable row level security;
alter table public.cards enable row level security;
alter table public.case_updates enable row level security;
alter table public.case_photos enable row level security;
alter table public.quote_decisions enable row level security;
alter table public.pricing_services enable row level security;
alter table public.pricing_tiers enable row level security;
alter table public.clinic_settings enable row level security;
alter table public.client_reviews enable row level security;

grant usage on schema public to anon, authenticated;
grant select on public.pricing_services, public.pricing_tiers, public.clinic_settings, public.client_reviews to anon, authenticated;
grant select on public.staff, public.cards, public.case_updates, public.case_photos, public.quote_decisions to authenticated;
grant insert,update,delete on public.cards, public.case_updates, public.case_photos, public.pricing_services, public.pricing_tiers, public.clinic_settings, public.client_reviews to authenticated;
grant insert on public.quote_decisions to authenticated;
grant execute on function public.is_staff() to authenticated;

-- Staff marker is readable only by its own Auth user.
drop policy if exists staff_self on public.staff;
create policy staff_self on public.staff for select to authenticated using (user_id=auth.uid());

-- Public published rate and queue settings, with staff-only edits.
drop policy if exists pricing_read on public.pricing_services;
create policy pricing_read on public.pricing_services for select to anon,authenticated using(true);
drop policy if exists pricing_staff_insert on public.pricing_services;
create policy pricing_staff_insert on public.pricing_services for insert to authenticated with check (public.is_staff());
drop policy if exists pricing_staff_update on public.pricing_services;
create policy pricing_staff_update on public.pricing_services for update to authenticated using (public.is_staff()) with check(public.is_staff());
drop policy if exists tiers_read on public.pricing_tiers;
create policy tiers_read on public.pricing_tiers for select to anon,authenticated using(true);
drop policy if exists tiers_staff_update on public.pricing_tiers;
create policy tiers_staff_update on public.pricing_tiers for update to authenticated using(public.is_staff()) with check(public.is_staff());
drop policy if exists settings_read on public.clinic_settings;
create policy settings_read on public.clinic_settings for select to anon,authenticated using(true);
drop policy if exists settings_staff_update on public.clinic_settings;
create policy settings_staff_update on public.clinic_settings for update to authenticated using(public.is_staff()) with check(public.is_staff());

-- Owner may see only cards where the login email matches the staff-registered email.
drop policy if exists cards_owner_staff_select on public.cards;
create policy cards_owner_staff_select on public.cards for select to authenticated
 using(public.is_staff() or lower(owner_email)=lower(coalesce(auth.jwt()->>'email','')));
drop policy if exists cards_staff_insert on public.cards;
create policy cards_staff_insert on public.cards for insert to authenticated with check(public.is_staff());
drop policy if exists cards_staff_update on public.cards;
create policy cards_staff_update on public.cards for update to authenticated using(public.is_staff()) with check(public.is_staff());
drop policy if exists cards_staff_delete on public.cards;
create policy cards_staff_delete on public.cards for delete to authenticated using(public.is_staff());

-- Status updates and images are restricted to staff or the associated owner.
drop policy if exists updates_owner_staff_select on public.case_updates;
create policy updates_owner_staff_select on public.case_updates for select to authenticated
 using(public.is_staff() or exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))));
drop policy if exists updates_staff_insert on public.case_updates;
create policy updates_staff_insert on public.case_updates for insert to authenticated with check(public.is_staff());
drop policy if exists photos_owner_staff_select on public.case_photos;
create policy photos_owner_staff_select on public.case_photos for select to authenticated
 using(public.is_staff() or exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))));
drop policy if exists photos_staff_insert on public.case_photos;
create policy photos_staff_insert on public.case_photos for insert to authenticated with check(public.is_staff());

-- Quote approvals can only be submitted for one's own issued quote (one decision per case).
drop policy if exists decisions_owner_staff_select on public.quote_decisions;
create policy decisions_owner_staff_select on public.quote_decisions for select to authenticated
 using(public.is_staff() or exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))));
drop policy if exists decisions_owner_insert on public.quote_decisions;
create policy decisions_owner_insert on public.quote_decisions for insert to authenticated
 with check(exists(select 1 from public.cards c where c.id=case_id and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email','')) and c.quote_status='issued' and c.quote_amount is not null));

-- Published historical reviews can be viewed by visitors, but only staff can write them.
drop policy if exists reviews_public_select on public.client_reviews;
create policy reviews_public_select on public.client_reviews for select to anon,authenticated using(is_published or public.is_staff());
drop policy if exists reviews_staff_insert on public.client_reviews;
create policy reviews_staff_insert on public.client_reviews for insert to authenticated with check(public.is_staff());
drop policy if exists reviews_staff_update on public.client_reviews;
create policy reviews_staff_update on public.client_reviews for update to authenticated using(public.is_staff()) with check(public.is_staff());

-- PUBLIC QUEUE: Only counts open cases, exposes no identifiable data.
create or replace function public.public_queue_count()
returns integer language sql stable security definer set search_path=public
as $$ select count(*)::integer from public.cards where closed_at is null $$;
revoke all on function public.public_queue_count() from public;
grant execute on function public.public_queue_count() to anon,authenticated;

-- Secure image storage: no publicly listable or downloadable bucket.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('case-media','case-media',false,8388608,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=false,file_size_limit=8388608,allowed_mime_types=array['image/jpeg','image/png','image/webp'];

drop policy if exists clinic_media_select on storage.objects;
create policy clinic_media_select on storage.objects for select to authenticated
using(bucket_id='case-media' and (
 public.is_staff() or exists (
  select 1 from public.cards c
  where c.id::text=split_part(name,'/',1)
  and lower(c.owner_email)=lower(coalesce(auth.jwt()->>'email',''))
 )
));
drop policy if exists clinic_media_insert on storage.objects;
create policy clinic_media_insert on storage.objects for insert to authenticated
with check(bucket_id='case-media' and public.is_staff());

-- IMPORTANT - CREATE STAFF USERS MANUALLY:
-- 1) Supabase > Authentication > Users > Add User; use a confirmed staff email/password.
-- 2) Copy the staff user UUID from Authentication > Users.
-- 3) Run this statement after REPLACING the placeholder with that real UUID:
-- insert into public.staff(user_id) values ('YOUR-STAFF-USER-UUID') on conflict do nothing;
-- 4) Provision client accounts in Authentication > Users. Match the email EXACTLY
--    to the staff-created card's owner_email. Do not allow public signup.
-- 5) The HTML uses only URL + public anon/publishable key. NEVER expose a service_role key.

-- V4 upgrade: safe to run on existing installations.
alter table public.cards add column if not exists priority_service boolean not null default false;


-- V5: a transparent counter using historical cards + distinct closed records.
alter table public.clinic_settings add column if not exists historical_completed integer not null default 0 check (historical_completed >= 0);
create or replace function public.public_completed_count()
returns integer language sql stable security definer set search_path=public
as $$ select count(*)::integer from public.cards where closed_at is not null $$;
revoke all on function public.public_completed_count() from public;
grant execute on function public.public_completed_count() to anon,authenticated;

-- V5: independent consented PUBLIC portfolio: no private case relationship or private files exposed.
create table if not exists public.restoration_portfolio (
 id uuid primary key default gen_random_uuid(),
 card_name text not null,
 issue_summary text not null,
 treatment_summary text not null,
 outcome_notes text not null default '',
 before_path text not null,
 after_path text not null,
 is_published boolean not null default false,
 created_at timestamptz not null default now()
);
alter table public.restoration_portfolio enable row level security;
grant select on public.restoration_portfolio to anon,authenticated;
grant insert,update,delete on public.restoration_portfolio to authenticated;
drop policy if exists portfolio_public_read on public.restoration_portfolio;
create policy portfolio_public_read on public.restoration_portfolio for select to anon,authenticated using(is_published or public.is_staff());
drop policy if exists portfolio_staff_insert on public.restoration_portfolio;
create policy portfolio_staff_insert on public.restoration_portfolio for insert to authenticated with check(public.is_staff());
drop policy if exists portfolio_staff_update on public.restoration_portfolio;
create policy portfolio_staff_update on public.restoration_portfolio for update to authenticated using(public.is_staff()) with check(public.is_staff());
drop policy if exists portfolio_staff_delete on public.restoration_portfolio;
create policy portfolio_staff_delete on public.restoration_portfolio for delete to authenticated using(public.is_staff());

-- Images for published case studies are publicly accessible by their URL.
-- Never put client-private images, names, addresses or case IDs in this bucket.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('portfolio-public','portfolio-public',true,8388608,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=8388608,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists portfolio_media_public_read on storage.objects;
create policy portfolio_media_public_read on storage.objects for select to anon,authenticated using(bucket_id='portfolio-public');
drop policy if exists portfolio_media_staff_upload on storage.objects;
create policy portfolio_media_staff_upload on storage.objects for insert to authenticated with check(bucket_id='portfolio-public' and public.is_staff());


-- V5: a transparent counter using historical cards + distinct closed records.
alter table public.clinic_settings add column if not exists historical_completed integer not null default 0 check (historical_completed >= 0);
create or replace function public.public_completed_count()
returns integer language sql stable security definer set search_path=public
as $$ select count(*)::integer from public.cards where closed_at is not null $$;
revoke all on function public.public_completed_count() from public;
grant execute on function public.public_completed_count() to anon,authenticated;

-- V5: independent consented PUBLIC portfolio: no private case relationship or private files exposed.
create table if not exists public.restoration_portfolio (
 id uuid primary key default gen_random_uuid(),
 card_name text not null,
 issue_summary text not null,
 treatment_summary text not null,
 outcome_notes text not null default '',
 before_path text not null,
 after_path text not null,
 is_published boolean not null default false,
 created_at timestamptz not null default now()
);
alter table public.restoration_portfolio enable row level security;
grant select on public.restoration_portfolio to anon,authenticated;
grant insert,update,delete on public.restoration_portfolio to authenticated;
drop policy if exists portfolio_public_read on public.restoration_portfolio;
create policy portfolio_public_read on public.restoration_portfolio for select to anon,authenticated using(is_published or public.is_staff());
drop policy if exists portfolio_staff_insert on public.restoration_portfolio;
create policy portfolio_staff_insert on public.restoration_portfolio for insert to authenticated with check(public.is_staff());
drop policy if exists portfolio_staff_update on public.restoration_portfolio;
create policy portfolio_staff_update on public.restoration_portfolio for update to authenticated using(public.is_staff()) with check(public.is_staff());
drop policy if exists portfolio_staff_delete on public.restoration_portfolio;
create policy portfolio_staff_delete on public.restoration_portfolio for delete to authenticated using(public.is_staff());

-- Images for published case studies are publicly accessible by their URL.
-- Never put client-private images, names, addresses or case IDs in this bucket.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('portfolio-public','portfolio-public',true,8388608,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=8388608,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists portfolio_media_public_read on storage.objects;
create policy portfolio_media_public_read on storage.objects for select to anon,authenticated using(bucket_id='portfolio-public');
drop policy if exists portfolio_media_staff_upload on storage.objects;
create policy portfolio_media_staff_upload on storage.objects for insert to authenticated with check(bucket_id='portfolio-public' and public.is_staff());


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
