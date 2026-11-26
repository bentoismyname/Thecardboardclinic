-- Cardboard Clinic V10: videos on card records, and staff can delete clients and portfolio stories.
-- Run once in Supabase > SQL Editor. Safe to run again.

-- 1. Card media: allow MP4 / MOV / WebM videos, up to 50 MB per file (photos are still checked at 8 MB on the website).
update storage.buckets
   set file_size_limit = 52428800,
       allowed_mime_types = array['image/jpeg','image/png','image/webp','video/mp4','video/quicktime','video/webm']
 where id = 'case-media';

-- 2. Staff may delete files (used when a client or a portfolio story is deleted).
drop policy if exists clinic_media_staff_delete on storage.objects;
create policy clinic_media_staff_delete on storage.objects for delete to authenticated
using (bucket_id = 'case-media' and public.is_staff());

drop policy if exists portfolio_media_staff_delete on storage.objects;
create policy portfolio_media_staff_delete on storage.objects for delete to authenticated
using (bucket_id = 'portfolio-public' and public.is_staff());

-- 3. Staff may delete card records (timelines, photos and consent forms go with them).
drop policy if exists cards_staff_delete on public.cards;
create policy cards_staff_delete on public.cards for delete to authenticated using (public.is_staff());
grant delete on public.cards to authenticated;

notify pgrst, 'reload schema';
