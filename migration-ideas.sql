-- Run this ONCE in Supabase: SQL Editor > New query > paste > Run.
-- Allows items to exist without a date, so they can sit in the general
-- "Ideas" list until you assign them to a specific day.

alter table day_items
  alter column item_date drop not null;
