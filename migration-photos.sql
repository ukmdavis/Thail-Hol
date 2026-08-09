-- Run this ONCE in Supabase: SQL Editor > New query > paste > Run.
-- Adds photo support for trips.
--
-- IMPORTANT: before running this, create the storage bucket:
--   Supabase dashboard > Storage > New bucket
--   Name it exactly:  trip-photos
--   Tick "Public bucket" so the images can be displayed on your site.

create table if not exists photos (
  id uuid primary key default gen_random_uuid(),
  holiday_id uuid references holidays(id) on delete cascade,
  storage_path text not null,   -- path inside the trip-photos bucket
  caption text,
  item_date date,               -- optional: which day of the trip it belongs to
  created_at timestamptz default now()
);

alter table photos enable row level security;
create policy "public access" on photos for all using (true) with check (true);

-- Allow uploading, viewing and deleting files in the trip-photos bucket.
create policy "public upload trip photos"
  on storage.objects for insert
  with check (bucket_id = 'trip-photos');

create policy "public read trip photos"
  on storage.objects for select
  using (bucket_id = 'trip-photos');

create policy "public delete trip photos"
  on storage.objects for delete
  using (bucket_id = 'trip-photos');
