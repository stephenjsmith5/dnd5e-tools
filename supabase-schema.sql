-- D&D 5e Tools — Supabase schema
-- Run this in the Supabase SQL editor after creating a project.

create table if not exists characters (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade not null,
  local_id    text not null,              -- matches CharStore genId() key
  name        text,
  class_id    text,
  level       integer default 1,
  builder_data jsonb,                     -- full builder state blob
  tracker_data jsonb,                     -- full tracker char blob
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- Each user can have one row per local_id (upsert key)
create unique index if not exists characters_user_local
  on characters (user_id, local_id);

-- Row-level security: users can only see/edit their own characters
alter table characters enable row level security;

create policy "Users manage own characters"
  on characters for all
  using (auth.uid() = user_id);

-- Auto-update updated_at on every row change
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

create trigger characters_updated_at
  before update on characters
  for each row execute procedure set_updated_at();

-- ── Sessions (Realtime group play) ────────────────────────────────────────────

create table if not exists sessions (
  id          text primary key,              -- human-readable code e.g. "STORM-42"
  created_by  uuid references auth.users(id) on delete set null,
  name        text default 'Session',
  created_at  timestamptz default now()
);

alter table sessions enable row level security;

create policy "Authenticated users can read sessions"
  on sessions for select using (auth.uid() is not null);

create policy "Authenticated users can create sessions"
  on sessions for insert with check (auth.uid() = created_by);

-- Roll history so late joiners can see what happened earlier in the session
create table if not exists session_rolls (
  id          uuid primary key default gen_random_uuid(),
  session_id  text references sessions(id) on delete cascade not null,
  user_id     uuid references auth.users(id) on delete cascade not null,
  char_name   text not null,
  label       text not null,
  formula     text not null,
  total       integer not null,
  is_crit     boolean default false,
  is_miss     boolean default false,
  dmg_total   integer,
  created_at  timestamptz default now()
);

alter table session_rolls enable row level security;

create policy "Authenticated users can read session rolls"
  on session_rolls for select using (auth.uid() is not null);

create policy "Authenticated users can insert their own rolls"
  on session_rolls for insert with check (auth.uid() = user_id);
