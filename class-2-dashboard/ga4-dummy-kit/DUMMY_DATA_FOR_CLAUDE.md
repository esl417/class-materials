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

## Step 0 — Confirm Supabase access — and if it's missing, set it up yourself

This kit needs a live connection to the human's Supabase project (the Supabase MCP
tools: `list_tables`, `apply_migration`, `execute_sql`, etc.), normally established by
the **supabase-student-kit**. **Many students skip that prereq and come straight here.
That is fine and expected — when it happens, you do the connection setup for them
automatically. Do not send them away to "go do the other kit first"; go get it and run
it yourself.**

1. Look at your available tools for the Supabase MCP tools (`list_tables`,
   `apply_migration`, `execute_sql`). If they're present, run `list_tables` once to
   confirm the connection actually works. If it works → skip to Step 1.

2. **If those tools are NOT in your toolset, or `list_tables` errors with an
   auth/connection problem — the prereq wasn't done. Handle it yourself, inline, now:**

   a. Tell the human, warmly and briefly, what's happening — no jargon, no blame:
      > "Quick heads-up: before I can build your practice data, I need to connect to
      > your Supabase account. That's a one-time setup and I'll walk us through it right
      > now — you'll just click a couple of things when I ask."

   b. **Fetch the connection kit yourself** from the class materials repo and follow it
      as your runbook — do NOT ask the human to paste anything to get it. Read:
      `https://github.com/esl417/class-materials` →
      `class-2-dashboard/supabase-student-kit/SUPABASE_SETUP_FOR_CLAUDE.md`
      (raw:
      `https://raw.githubusercontent.com/esl417/class-materials/main/class-2-dashboard/supabase-student-kit/SUPABASE_SETUP_FOR_CLAUDE.md`).
      Use your web-fetch / file tools to pull it in. If you truly cannot fetch it, then
      and only then fall back to asking the human to paste the setup-kit prompt.

   c. **Run that setup runbook end to end**, doing every step you can do yourself
      (installing the `supabase` plugin, wiring the MCP server). Pause ONLY at the
      genuine human moments, one at a time, and wait each time:
      - **Making a Supabase account / empty project** — they may already have one; ask
        first. If not, walk them through supabase.com → sign in → New project (save the
        DB password). This is theirs to do in the browser.
      - **Restarting Claude Code** (the plugin's tools only load on restart) — see the
        restart handling just below; this is the step people get stuck on.
      - **Clicking "Authorize"** in the Supabase browser page (OAuth — no token to
        paste), choosing the project for this class.

   d. **The restart hand-off (do this carefully — it's where students get lost).** When
      the setup kit tells you to have them restart, say something like:
      > "Now I need you to fully **quit Claude Code and open it again** in this same
      > folder — the Supabase tools only switch on after a restart. The one tricky part
      > is getting back into *this* conversation so I remember where we are. Here's a
      > short visual walkthrough of exactly how — follow the slide on screen:
      > **https://class-1-deck.vercel.app/class-2-dashboard-build/prereqs.html#restart**
      >
      > In short: after it reopens, click the **🕐 clock icon at the top-right** of the
      > Claude box to open your conversation history, pick **this** chat, and type
      > **'continue the dummy-data setup.'** (If the Claude panel vanishes, click any
      > file on the left and it comes back.)"

   e. **After they restart and return**, re-check the MCP tools (they should now be
      present and authorized), finish any remaining setup-kit steps, then **continue
      straight into Step 1 of THIS kit** — build the tables and seed the data. Don't make
      them re-paste the dummy-data prompt; you're already on it.

   Throughout: never show raw errors, never ask them to run terminal commands or edit
   files, and don't spin — if a step needs a human click, ask for that one click and
   wait.

If `list_tables` succeeds but the project is empty (no user tables), that's perfect —
you're connected, just continue to Step 1. If it shows the `ga4_*` tables already exist,
that's also fine — the seed step below is safe to re-run and will refresh the data.

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
