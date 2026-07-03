-- GA4-shaped analytics tables — dummy-data edition for students without a
-- Google tag. The shape mirrors what a real nightly GA4 sync writes (see the
-- production pattern: an edge function upserting daily rollups keyed by
-- snapshot_date). If the student later installs a real Google tag, a real sync
-- can upsert into these exact tables — no dashboard changes needed.

-- ── Engagement: sessions & quality by channel, per day ───────────────
-- channel is GA4's sessionDefaultChannelGroup; channel = '' is the special
-- all-traffic aggregate row (one per day). bounce_rate is a percent (0-100),
-- avg_session_duration is seconds.
create table if not exists ga4_engagement_daily (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  channel text not null default '',
  sessions integer not null default 0,
  engaged_sessions integer not null default 0,
  total_users integer not null default 0,
  new_users integer not null default 0,
  bounce_rate numeric(6,2) not null default 0,
  avg_session_duration numeric(8,2) not null default 0,
  created_at timestamptz not null default now(),
  unique (snapshot_date, channel)
);
create index if not exists idx_ga4_engagement_daily_date
  on ga4_engagement_daily (snapshot_date desc);

-- ── Top pages: views per page path, per day ──────────────────────────
create table if not exists ga4_top_pages_daily (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  page_path text not null,
  views integer not null default 0,
  users integer not null default 0,
  created_at timestamptz not null default now(),
  unique (snapshot_date, page_path)
);
create index if not exists idx_ga4_top_pages_daily_date
  on ga4_top_pages_daily (snapshot_date desc);

-- ── Events: GA4 eventName counts, per day ────────────────────────────
create table if not exists ga4_events_daily (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  event_name text not null,
  event_count integer not null default 0,
  created_at timestamptz not null default now(),
  unique (snapshot_date, event_name)
);
create index if not exists idx_ga4_events_daily_date
  on ga4_events_daily (snapshot_date desc);

-- ── RLS: public read, service write ──────────────────────────────────
-- The student's dashboard reads with the anon key (no auth in the class app),
-- and this is intentionally fake data — public read is fine here. Writes stay
-- restricted to service_role (a future real sync writes via service_role).
alter table ga4_engagement_daily enable row level security;
alter table ga4_top_pages_daily  enable row level security;
alter table ga4_events_daily     enable row level security;

create policy "public read ga4_engagement_daily"
  on ga4_engagement_daily for select using (true);
create policy "service write ga4_engagement_daily"
  on ga4_engagement_daily for all to service_role using (true) with check (true);

create policy "public read ga4_top_pages_daily"
  on ga4_top_pages_daily for select using (true);
create policy "service write ga4_top_pages_daily"
  on ga4_top_pages_daily for all to service_role using (true) with check (true);

create policy "public read ga4_events_daily"
  on ga4_events_daily for select using (true);
create policy "service write ga4_events_daily"
  on ga4_events_daily for all to service_role using (true) with check (true);
