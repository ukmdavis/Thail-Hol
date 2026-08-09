-- ============================================================
--  MIGRATION: move from passcodes to real Supabase Auth
--  Run ONCE in Supabase: SQL Editor > New query > paste all > Run.
--
--  After running, follow the "First organiser" step at the bottom.
-- ============================================================

-- ---------- 1. Profiles: one row per signed-up user ----------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'viewer'
    check (role in ('viewer','editor','organiser')),
  created_at timestamptz default now()
);

-- Automatically create a profile when someone signs up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- 2. Helper functions used by the security rules ----------
create or replace function public.user_role()
returns text language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'viewer');
$$;

create or replace function public.can_edit()
returns boolean language sql stable security definer set search_path = public as $$
  select public.user_role() in ('editor','organiser');
$$;

create or replace function public.is_organiser()
returns boolean language sql stable security definer set search_path = public as $$
  select public.user_role() = 'organiser';
$$;

-- Is this holiday visible to the current user?
-- Unrevealed surprise trips are only visible to organisers.
create or replace function public.holiday_visible(hid uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.holidays h
    where h.id = hid
      and (
        public.is_organiser()
        or h.is_secret is not true
        or h.reveal_at is null
        or h.reveal_at <= now()
      )
  );
$$;

-- ---------- 3. Replace the old wide-open policies ----------
drop policy if exists "public access" on holidays;
drop policy if exists "public access" on flights;
drop policy if exists "public access" on stays;
drop policy if exists "public access" on day_items;
drop policy if exists "public access" on photos;

alter table profiles enable row level security;

-- Profiles: you can read your own; organisers can read and change all.
create policy "read own profile" on profiles
  for select using (id = auth.uid() or public.is_organiser());
create policy "organiser manages profiles" on profiles
  for update using (public.is_organiser()) with check (public.is_organiser());

-- Holidays
create policy "signed in can read holidays" on holidays
  for select using (
    auth.uid() is not null
    and (
      public.is_organiser()
      or is_secret is not true
      or reveal_at is null
      or reveal_at <= now()
    )
  );
create policy "editors can write holidays" on holidays
  for all using (public.can_edit()) with check (public.can_edit());

-- Child tables: readable if the parent holiday is visible, writable by editors.
create policy "signed in can read flights" on flights
  for select using (auth.uid() is not null and public.holiday_visible(holiday_id));
create policy "editors can write flights" on flights
  for all using (public.can_edit()) with check (public.can_edit());

create policy "signed in can read stays" on stays
  for select using (auth.uid() is not null and public.holiday_visible(holiday_id));
create policy "editors can write stays" on stays
  for all using (public.can_edit()) with check (public.can_edit());

create policy "signed in can read day_items" on day_items
  for select using (auth.uid() is not null and public.holiday_visible(holiday_id));
create policy "editors can write day_items" on day_items
  for all using (public.can_edit()) with check (public.can_edit());

create policy "signed in can read photos" on photos
  for select using (auth.uid() is not null and public.holiday_visible(holiday_id));
create policy "editors can write photos" on photos
  for all using (public.can_edit()) with check (public.can_edit());

-- ---------- 4. Storage: lock the photo bucket down too ----------
drop policy if exists "public upload trip photos" on storage.objects;
drop policy if exists "public read trip photos" on storage.objects;
drop policy if exists "public delete trip photos" on storage.objects;

create policy "signed in read trip photos" on storage.objects
  for select using (bucket_id = 'trip-photos' and auth.uid() is not null);
create policy "editors upload trip photos" on storage.objects
  for insert with check (bucket_id = 'trip-photos' and public.can_edit());
create policy "editors delete trip photos" on storage.objects
  for delete using (bucket_id = 'trip-photos' and public.can_edit());

-- IMPORTANT: also switch the bucket itself to private.
--   Storage > trip-photos > Settings > untick "Public bucket".
-- The app now uses time-limited signed URLs to display images.


-- ============================================================
--  FIRST ORGANISER
--  1. Deploy the new files, open the site, and sign in with your
--     own email. This creates your account (role defaults to viewer).
--  2. Come back here and run, with your email:
--
--       update profiles set role = 'organiser' where email = 'you@example.com';
--
--  3. Reload the site. You can then set everyone else's role from
--     the "Manage Trips" page — no SQL needed again.
-- ============================================================
