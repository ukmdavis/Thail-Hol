-- Run this in Supabase: Project > SQL Editor > New query > paste all > Run

create extension if not exists "pgcrypto";

create table holidays (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  destination text,
  depart_date date not null,
  return_date date not null,
  is_secret boolean default false,
  reveal_at timestamptz,
  lead_days integer default 45,   -- how many days before departure the timeline starts
  created_at timestamptz default now()
);

create table flights (
  id uuid primary key default gen_random_uuid(),
  holiday_id uuid references holidays(id) on delete cascade,
  direction text,              -- 'Outbound' or 'Return'
  airline text,
  flight_number text,
  from_airport text,
  to_airport text,
  depart_at timestamptz,
  arrive_at timestamptz,
  notes text
);

create table stays (
  id uuid primary key default gen_random_uuid(),
  holiday_id uuid references holidays(id) on delete cascade,
  name text,
  address text,
  checkin date,
  checkout date,
  notes text
);

create table day_items (
  id uuid primary key default gen_random_uuid(),
  holiday_id uuid references holidays(id) on delete cascade,
  item_date date,              -- null = sits in the general "Ideas" list
  type text check (type in ('task','note')) not null,
  text text not null,
  done boolean default false,
  created_at timestamptz default now()
);

-- Row Level Security: open access for this personal-use site.
-- Because the anon key is public in the browser, anyone with the URL
-- and key could read/write. Fine for a private family project link
-- you don't share publicly. Ask me later if you want a passcode gate.
alter table holidays enable row level security;
alter table flights enable row level security;
alter table stays enable row level security;
alter table day_items enable row level security;

create policy "public access" on holidays for all using (true) with check (true);
create policy "public access" on flights for all using (true) with check (true);
create policy "public access" on stays for all using (true) with check (true);
create policy "public access" on day_items for all using (true) with check (true);
