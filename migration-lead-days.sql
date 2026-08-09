-- Run this ONCE in Supabase: SQL Editor > New query > paste > Run.
-- Adds a per-trip setting for how many days before departure the
-- day-by-day timeline should start. Existing trips default to 45.

alter table holidays
  add column if not exists lead_days integer default 45;
