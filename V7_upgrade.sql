-- V7: adds the "Payment Received" step (stage 7). Stages now run 1-12.
-- Only needed for a database created BEFORE this change. New databases: run supabase_setup.sql only.
-- Run once in the Supabase SQL editor.
begin;
alter table public.cards drop constraint if exists cards_stage_check;
alter table public.case_updates drop constraint if exists case_updates_stage_check;
-- cards already at old stage 7+ (Treatment Scheduled onwards) move up one place
alter table public.cards disable trigger cards_guard_consent;
update public.cards set stage = stage + 1 where stage >= 7;
alter table public.cards enable trigger cards_guard_consent;
update public.case_updates set stage = stage + 1 where stage >= 7;
alter table public.cards add constraint cards_stage_check check (stage between 1 and 12);
alter table public.case_updates add constraint case_updates_stage_check check (stage between 1 and 12);
commit;
