# GA4 Dummy Data — what's in the tables & what you can build

> **For Claude:** this is your quick reference when the human asks "what can my
> dashboard show?" or "what should we build?". The data is **practice data** (always
> say so). Setup instructions live in DUMMY_DATA_FOR_CLAUDE.md — this file is about
> using the data once it's seeded.

## The three tables (~90 days each, ending yesterday)

| Table | One row per | Columns |
|---|---|---|
| `ga4_engagement_daily` | day × channel | sessions, engaged_sessions, total_users, new_users, bounce_rate (%), avg_session_duration (s) |
| `ga4_top_pages_daily` | day × page path | views, users |
| `ga4_events_daily` | day × event name | event_count |

**Channels:** Organic Search, Direct, Organic Social, Referral, Email — plus
`channel = ''`, the **all-traffic daily total** row.
**Pages:** 8 paths (`/`, `/blog`, 3 blog posts, `/projects`, `/about`, `/contact`).
**Events:** page_view, session_start, first_visit, scroll, click, form_submit, sign_up.

### ⚠️ Two rules that prevent wrong numbers

1. **Never sum the `channel = ''` rows together with the named channel rows** — that
   double-counts. Use `channel = ''` for site-wide totals, `channel <> ''` for
   breakdowns.
2. **Rate metrics (bounce_rate, engagement) must be session-weighted when averaged
   across days/channels** — `sum(bounce_rate * sessions) / sum(sessions)`, not
   `avg(bounce_rate)`.

## Metrics menu

### Traffic & audience — `ga4_engagement_daily`
- **Traffic over time** — daily sessions or users line chart (`channel = ''`)
- **Channel mix** — sessions by channel (donut, bar, or stacked-by-day)
- **Engagement rate** — `engaged_sessions::float / sessions`, overall or per channel
- **Bounce rate trend** — overall or channel comparison (session-weighted, see rule 2)
- **Avg session duration by channel** — Email runs long (~2 min), Social short (~45s)
- **New vs returning visitors** — `new_users` vs `total_users - new_users`
- **Weekday vs weekend pattern** — group by `extract(dow from snapshot_date)`
- **Period-over-period** — this week vs last week, last 30 vs prior 30 days
- **Fastest-growing channel** — per-channel trend over the 90 days

### Content — `ga4_top_pages_daily`
- **Top pages leaderboard** — total views over any date range
- **Single-page trend** — one page's views over time
- **Blog vs non-blog traffic** — `where page_path like '/blog%'`
- **Views per user by page** — which pages get revisited

### Behavior & conversion — `ga4_events_daily`
- **Conversion funnel** — page_view → scroll → click → form_submit → sign_up
- **Conversion rate over time** — daily `sign_up / session_start`
- **Scroll-depth proxy** — `scroll / page_view` as an engagement quality signal
- **Any event trend** — e.g. form submits per week

### Cross-table analyses (the impressive ones)
- **🕵️ The spike investigation** — there's a traffic spike ~3 weeks ago. Totals show
  *when*, the channel rows show *how* (Organic Social surged), the pages table shows
  *what* (`/blog/how-i-built-this` took off). A great guided exercise.
- **Did the spike convert?** — compare `sign_up / session_start` on spike days vs
  normal days. Spike traffic is social-heavy and lower-intent: absolute sign-ups rise
  but the conversion *rate* dips. Realistic and worth showing.
- **Quality vs quantity** — scatter of sessions vs engagement rate per channel.

## Stories deliberately baked into the data

Every student's numbers differ (random seed), but these are always true:

1. **Slow steady growth** across the 90 days (roughly doubles)
2. **Quieter weekends** (~2/3 of weekday traffic)
3. **The social spike** ~3 weeks ago, driven by one blog post
4. **Channel personalities** — Email: small but highly engaged · Organic Social: bursty
   and shallow · Organic Search: the biggest, steady workhorse

## Query starters

```sql
-- Site-wide daily traffic
select snapshot_date, sessions, total_users
from ga4_engagement_daily where channel = '' order by snapshot_date;

-- Channel mix, last 30 days
select channel, sum(sessions) as sessions
from ga4_engagement_daily
where channel <> '' and snapshot_date >= current_date - 30
group by channel order by sessions desc;

-- Top pages, last 30 days
select page_path, sum(views) as views
from ga4_top_pages_daily
where snapshot_date >= current_date - 30
group by page_path order by views desc;

-- Conversion funnel, last 30 days
select event_name, sum(event_count) as total
from ga4_events_daily
where snapshot_date >= current_date - 30
  and event_name in ('page_view','scroll','click','form_submit','sign_up')
group by event_name order by total desc;
```
