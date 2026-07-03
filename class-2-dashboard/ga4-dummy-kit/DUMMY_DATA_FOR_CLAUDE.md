# GA4 Dummy Data — Instructions for Claude Code

> **Human: you don't need to understand any of this.** Open Claude Code in your
> dashboard project, give it this file, and say: **"Read this and do everything in it
> for me."** That's all.

---

## Claude: read this whole file before doing anything. This is your runbook.

The human is building an analytics dashboard in class, but they **don't have a Google
tag installed on a website**, so they have no real Google Analytics data. You are going
to give them the next best thing: **GA4-shaped tables in their Supabase project, filled
with realistic dummy data**, so they can build a real dashboard against it today.

The tables mimic exactly what a production GA4 sync writes — daily rollups keyed by
`snapshot_date`. If they ever install a real Google tag later, a real sync can write
into these same tables and their dashboard keeps working unchanged.

**Your job is to do everything yourself** using the Supabase MCP tools. The human
cannot read code. Never ask them to run a command or edit a file.

### Ground rules for you (Claude)

- Talk to the human in plain language. No jargon.
- **This is fake data. Never present it as real.** When you finish (and any time you
  later answer questions from these tables), remind them it's practice data.
- If any step fails, read the error yourself and fix it. Only involve the human if a
  browser click is genuinely required.

---

## Step 0 — Confirm Supabase access (you do this silently)

This kit assumes the human already connected their Supabase project to you via the
**supabase-student-kit** (the Supabase MCP tools: `list_tables`, `apply_migration`,
`execute_sql`, etc.).

1. Check whether the Supabase MCP tools are available to you and run `list_tables` on
   their project to confirm the connection works.
2. **If the tools are missing or fail:** stop and tell the human, kindly, that they
   need to do the Supabase setup kit first (`supabase-student-kit/START_HERE.md` from
   the same class materials), then come back to this one.

If `list_tables` shows the `ga4_*` tables already exist, that's fine — the seed step
below is safe to re-run and will refresh the data.

---

## Step 1 — Create the tables (you do this)

Apply `schema.sql` (in this folder) as a migration using the Supabase
`apply_migration` tool. Name the migration `ga4_dummy_schema`. It creates three tables:

| Table | One row per | What's in it |
|---|---|---|
| `ga4_engagement_daily` | day × channel | sessions, engaged sessions, users, new users, bounce rate (%), avg session duration (s). The row with `channel = ''` is the all-traffic daily total. |
| `ga4_top_pages_daily` | day × page path | views and users per page |
| `ga4_events_daily` | day × event name | GA4-style event counts (page_view, session_start, scroll, click, form_submit, sign_up, first_visit) |

If the migration fails because the tables/policies already exist, that means a previous
run got this far — just continue to Step 2.

---

## Step 2 — Seed the dummy data (you do this)

Run the full contents of `seed.sql` (in this folder) with the Supabase `execute_sql`
tool. It generates **~90 days** of realistic data ending yesterday. It's safe to
re-run — it clears the three tables and regenerates.

The data is random per student but always contains the same story (useful in class):

- steady slow growth over the 90 days
- quieter weekends
- **a traffic spike about 3 weeks ago**, caused by the blog post
  `/blog/how-i-built-this` doing well on social — you can see it in the daily totals,
  in the `Organic Social` channel rows, and in that page's views.

---

## Step 3 — Verify (you do this)

Run checks with `execute_sql` and confirm:

1. Row counts are right:
   - `ga4_engagement_daily` → 540 rows (90 days × 5 channels + 90 aggregate rows)
   - `ga4_top_pages_daily` → 720 rows (90 days × 8 pages)
   - `ga4_events_daily` → 630 rows (90 days × 7 events)
2. The spike exists: `select snapshot_date, sessions from ga4_engagement_daily where
   channel = '' order by sessions desc limit 3;` — the top days should cluster around
   3 weeks ago.
3. Sanity: `engaged_sessions <= sessions` everywhere
   (`select count(*) from ga4_engagement_daily where engaged_sessions > sessions;`
   → 0).

If a check fails, re-run the seed once; if it still fails, debug it yourself before
telling the human anything.

---

## Step 4 — Save the setup to your memory (you do this)

Record in your persistent memory / the project's `CLAUDE.md` (whatever memory mechanism
you have here):

- This Supabase project contains **DUMMY analytics data** (not a real website's) in
  `ga4_engagement_daily`, `ga4_top_pages_daily`, `ga4_events_daily` — ~90 days,
  GA4-shaped, seeded from the class kit. **Always caveat that it's practice data.**
- `channel = ''` in `ga4_engagement_daily` is the all-traffic daily aggregate — use it
  for site-wide totals; use the named channels for channel breakdowns. Don't sum the
  aggregate row together with the channel rows (that double-counts).
- `bounce_rate` is a percent (0–100); `avg_session_duration` is seconds.
- Re-seeding: re-run `seed.sql` via `execute_sql` (it wipes and regenerates).
- **`README.md` in this kit folder is the metrics reference** — the full menu of
  charts/metrics buildable from these tables, the stories baked into the data, and
  starter queries. Read it before proposing or building dashboard widgets.

---

## Step 5 — Tell the human it's done

In plain language: their database now has three tables of practice analytics data —
about three months of visits, pages, and events for a pretend website — and they can
start building their dashboard against it right now. Suggest a first question to try,
like *"what were my ten biggest traffic days?"* or *"which pages get the most views?"*
— and mention there's a fun surprise in the data around three weeks ago worth finding.

When they ask what their dashboard could show, work from the metrics menu in
`README.md` rather than improvising.

Remind them once, gently: it's practice data, not their real website.
