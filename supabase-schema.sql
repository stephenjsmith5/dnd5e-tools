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

-- ── Campaigns (persistent DM-owned groups) ───────────────────────────────────

create table if not exists campaigns (
  id          uuid primary key default gen_random_uuid(),
  created_by  uuid references auth.users(id) on delete cascade not null,
  name        text not null,
  invite_code text unique not null,  -- 6-char alphanumeric, shown to players
  created_at  timestamptz default now()
);

alter table campaigns enable row level security;

create policy "Authenticated users can read campaigns"
  on campaigns for select using (auth.uid() is not null);

create policy "DM can create campaigns"
  on campaigns for insert with check (auth.uid() = created_by);

create policy "DM can delete own campaigns"
  on campaigns for delete using (auth.uid() = created_by);

-- Track which users/characters are in each campaign
create table if not exists campaign_members (
  campaign_id uuid references campaigns(id) on delete cascade not null,
  user_id     uuid references auth.users(id) on delete cascade not null,
  char_name   text,
  joined_at   timestamptz default now(),
  primary key (campaign_id, user_id)
);

alter table campaign_members enable row level security;

create policy "Authenticated users can view campaign members"
  on campaign_members for select using (auth.uid() is not null);

create policy "Users can join campaigns"
  on campaign_members for insert with check (auth.uid() = user_id);

create policy "Users can leave campaigns"
  on campaign_members for delete using (auth.uid() = user_id);

-- ── Campaign character state (per player per campaign) ───────────────────────

create table if not exists campaign_character_state (
  campaign_id  uuid references campaigns(id) on delete cascade not null,
  user_id      uuid references auth.users(id) on delete cascade not null,
  char_name    text,
  char_data    jsonb not null,
  updated_at   timestamptz default now(),
  primary key (campaign_id, user_id)
);

alter table campaign_character_state enable row level security;

create policy "Players can read own state; DM can read all in own campaign"
  on campaign_character_state for select
  using (
    auth.uid() = user_id or
    exists (select 1 from campaigns where id = campaign_id and created_by = auth.uid())
  );

create policy "Players can insert own state"
  on campaign_character_state for insert
  with check (auth.uid() = user_id);

create policy "Players can update own state"
  on campaign_character_state for update
  using (auth.uid() = user_id);

create policy "DM can update any player state in own campaign"
  on campaign_character_state for update
  using (exists (select 1 from campaigns where id = campaign_id and created_by = auth.uid()));

-- Auto-update updated_at
create trigger campaign_char_state_updated_at
  before update on campaign_character_state
  for each row execute procedure set_updated_at();

-- ── Campaign activity feed ────────────────────────────────────────────────────

create table if not exists campaign_activity (
  id           uuid primary key default gen_random_uuid(),
  campaign_id  uuid references campaigns(id) on delete cascade not null,
  user_id      uuid references auth.users(id) on delete cascade,
  char_name    text,
  action_type  text not null,  -- 'join','hp_change','condition','rest','roll','resource','cast','dm_action'
  description  text not null,
  data         jsonb,
  created_at   timestamptz default now()
);

alter table campaign_activity enable row level security;

create policy "Campaign participants can read activity"
  on campaign_activity for select using (auth.uid() is not null);

create policy "Authenticated users can insert activity"
  on campaign_activity for insert with check (auth.uid() = user_id or auth.uid() is not null);

-- ── Campaign change requests (approval queue) ─────────────────────────────────

create table if not exists campaign_change_requests (
  id           uuid primary key default gen_random_uuid(),
  campaign_id  uuid references campaigns(id) on delete cascade not null,
  user_id      uuid references auth.users(id) on delete cascade not null,
  char_name    text,
  change_type  text not null,  -- 'level_up','add_item','gold_change','ability_score','feat','short_rest','long_rest'
  description  text not null,
  change_data  jsonb not null,
  status       text default 'pending',  -- 'pending','approved','rejected'
  dm_message   text,
  created_at   timestamptz default now(),
  resolved_at  timestamptz
);

alter table campaign_change_requests enable row level security;

create policy "Players can read own requests; DM can read all in own campaign"
  on campaign_change_requests for select
  using (
    auth.uid() = user_id or
    exists (select 1 from campaigns where id = campaign_id and created_by = auth.uid())
  );

create policy "Players can insert own requests"
  on campaign_change_requests for insert with check (auth.uid() = user_id);

create policy "DM can update requests in own campaign"
  on campaign_change_requests for update
  using (exists (select 1 from campaigns where id = campaign_id and created_by = auth.uid()));

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
