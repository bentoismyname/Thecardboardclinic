-- Cardboard Clinic V9: store the client's drawn signature on the consent form.
-- Run once in Supabase > SQL Editor. Safe to run again.
alter table public.case_consents add column if not exists signature_image text;
alter table public.case_consents drop constraint if exists case_consents_signature_image_check;
alter table public.case_consents add constraint case_consents_signature_image_check
  check(signature_image is null or (signature_image like 'data:image/png;base64,%' and length(signature_image)<400000));
-- signed forms stay locked, signature included
create or replace function public.guard_consent_record() returns trigger language plpgsql security definer set search_path=public as $$
declare c public.cards;
begin
 select * into c from public.cards where id=new.case_id;
 if c.id is null then raise exception 'Card not found'; end if;
 if tg_op='INSERT' then
  if new.admin_verified_at is not null then raise exception 'Cannot self-verify consent';end if;
 elsif tg_op='UPDATE' then
  if not public.is_staff() then raise exception 'Staff authorisation required'; end if;
  if (old.case_id,old.agreement_version,old.scope_snapshot,old.signer_name,old.signer_capacity,old.marketing_consent,old.acknowledgements,old.created_at,old.signature_image)
    is distinct from (new.case_id,new.agreement_version,new.scope_snapshot,new.signer_name,new.signer_capacity,new.marketing_consent,new.acknowledgements,new.created_at,new.signature_image)
  then raise exception 'Signed agreement records are immutable';end if;
  if old.admin_verified_at is not null then raise exception 'Already verified';end if;
  if new.admin_verified_at is null or new.verified_by<>auth.uid() then raise exception 'Staff verification identity required';end if;
 end if;
 return new;
end $$;
notify pgrst, 'reload schema';
