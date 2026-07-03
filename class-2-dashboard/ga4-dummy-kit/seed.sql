-- Seed ~90 days of realistic-looking GA4-shaped dummy data.
--
-- Safe to re-run: clears the three tables first, then regenerates. Uses
-- random(), so every student's data is slightly different but always tells
-- the same story:
--   * steady slow growth over the 90 days
--   * quieter weekends
--   * a traffic spike ~3 weeks ago, driven by one blog post
--     ('/blog/how-i-built-this') doing well on social — visible in the
--     channel mix, the pages table, AND the daily totals.

begin;

delete from ga4_events_daily;
delete from ga4_top_pages_daily;
delete from ga4_engagement_daily;

-- ── 1. Per-channel engagement ────────────────────────────────────────
with days as (
  select
    (current_date - offs)::date as snapshot_date,
    offs,
    (90 - offs) as day_index,
    extract(dow from current_date - offs)::int as dow
  from generate_series(1, 90) as offs
),
daily as (
  select
    days.*,
    -- base traffic: growth + weekend dip + noise + the spike (days 19-22 ago)
    greatest(10, round(
      (35 + day_index * 0.45)
      * (case when dow in (0, 6) then 0.68 else 1.0 end)
      * (0.85 + random() * 0.30)
      * (case when offs = 22 then 1.6
              when offs = 21 then 3.1
              when offs = 20 then 2.0
              when offs = 19 then 1.3
              else 1.0 end)
    ))::int as total_sessions
  from days
),
channels(channel, share, eng_rate, base_dur) as (
  values
    ('Organic Search', 0.38, 0.62,  95.0),
    ('Direct',         0.27, 0.55,  70.0),
    ('Organic Social', 0.18, 0.42,  45.0),
    ('Referral',       0.10, 0.58,  85.0),
    ('Email',          0.07, 0.70, 120.0)
),
per_channel as (
  select
    d.snapshot_date,
    c.channel,
    greatest(1, round(
      d.total_sessions * c.share
      -- the spike came from social, so social over-indexes on those days
      * (case when c.channel = 'Organic Social' and d.offs between 19 and 22
              then 2.6 else 1.0 end)
      * (0.80 + random() * 0.40)
    ))::int as sessions,
    least(0.92, c.eng_rate * (0.90 + random() * 0.20)) as eng,
    c.base_dur * (0.80 + random() * 0.40) as dur
  from daily d cross join channels c
),
with_users as (
  select
    pc.*,
    greatest(1, round(pc.sessions * (0.72 + random() * 0.16)))::int as total_users
  from per_channel pc
)
insert into ga4_engagement_daily
  (snapshot_date, channel, sessions, engaged_sessions, total_users, new_users,
   bounce_rate, avg_session_duration)
select
  snapshot_date,
  channel,
  sessions,
  least(sessions, round(sessions * eng)::int),
  total_users,
  least(total_users, round(total_users * (0.45 + random() * 0.30))::int),
  round(((1 - eng) * 100)::numeric, 2),
  round(dur::numeric, 2)
from with_users;

-- ── 2. All-traffic aggregate row (channel = '') ──────────────────────
insert into ga4_engagement_daily
  (snapshot_date, channel, sessions, engaged_sessions, total_users, new_users,
   bounce_rate, avg_session_duration)
select
  snapshot_date,
  '',
  sum(sessions),
  sum(engaged_sessions),
  sum(total_users),
  sum(new_users),
  round((sum(bounce_rate * sessions) / nullif(sum(sessions), 0))::numeric, 2),
  round((sum(avg_session_duration * sessions) / nullif(sum(sessions), 0))::numeric, 2)
from ga4_engagement_daily
where channel <> ''
group by snapshot_date;

-- ── 3. Top pages ─────────────────────────────────────────────────────
with agg as (
  select snapshot_date, sessions, (current_date - snapshot_date) as offs
  from ga4_engagement_daily
  where channel = ''
),
pages(page_path, weight) as (
  values
    ('/',                      0.30),
    ('/blog/how-i-built-this', 0.14),
    ('/blog',                  0.12),
    ('/projects',              0.10),
    ('/about',                 0.09),
    ('/blog/lessons-learned',  0.09),
    ('/blog/first-post',       0.08),
    ('/contact',               0.08)
)
insert into ga4_top_pages_daily (snapshot_date, page_path, views, users)
select
  a.snapshot_date,
  p.page_path,
  v.views,
  greatest(1, round(v.views * (0.70 + random() * 0.20))::int)
from agg a
cross join pages p
cross join lateral (
  select greatest(1, round(
    a.sessions * 2.3 * p.weight
    -- the spike post gets the extra traffic on the spike days
    * (case when p.page_path = '/blog/how-i-built-this'
             and a.offs between 19 and 22
            then 2.8 else 1.0 end)
    * (0.80 + random() * 0.40)
  ))::int as views
) v;

-- ── 4. Events ────────────────────────────────────────────────────────
with agg as (
  select snapshot_date, sessions, new_users
  from ga4_engagement_daily
  where channel = ''
),
ev(event_name) as (
  values ('page_view'), ('session_start'), ('first_visit'),
         ('scroll'), ('click'), ('form_submit'), ('sign_up')
)
insert into ga4_events_daily (snapshot_date, event_name, event_count)
select
  a.snapshot_date,
  ev.event_name,
  greatest(0, round(case ev.event_name
    when 'page_view'     then a.sessions * (2.10 + random() * 0.50)
    when 'session_start' then a.sessions::double precision
    when 'first_visit'   then a.new_users::double precision
    when 'scroll'        then a.sessions * (1.10 + random() * 0.40)
    when 'click'         then a.sessions * (0.60 + random() * 0.30)
    when 'form_submit'   then a.sessions * (0.020 + random() * 0.015)
    when 'sign_up'       then a.sessions * (0.008 + random() * 0.008)
  end)::int)
from agg a cross join ev;

commit;
