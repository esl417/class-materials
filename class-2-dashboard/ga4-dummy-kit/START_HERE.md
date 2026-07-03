# Start Here 👋 (No Google Analytics? No problem.)

This kit is for you if you **don't have a Google tag installed on a website** (or your
analytics is still empty). Claude will fill your Supabase database with **realistic
practice data** — about 3 months of visits, pages, and events for a pretend website —
so you can build your dashboard today just like everyone else.

## Before you start

You need the **Supabase setup kit done first** (that's the one where you clicked
"Authorize" and Claude connected to your Supabase project). If you haven't done that,
do `supabase-student-kit/START_HERE.md` first, then come back here.

## What to do

1. Open your **dashboard project** in VS Code and open **Claude Code** in it.
2. Copy/paste this message to Claude:

   > **"Grab the GA4 dummy-data kit from https://github.com/esl417/class-materials (the
   > files in `class-2-dashboard/ga4-dummy-kit`) into this project, then read
   > DUMMY_DATA_FOR_CLAUDE.md and do everything in it for me. I'm not technical —
   > handle it all yourself."**

3. That's it. There are **no clicks for you** in this one — Claude builds the tables
   and fills them with data on its own, then tells you when it's done.

## What this does

- ✅ Creates three analytics tables in **your own** Supabase project.
- ✅ Fills them with ~90 days of realistic practice data (it even has a hidden
  traffic-spike story in it — ask Claude to find it).
- ✅ Your data is randomly generated, so yours won't look exactly like your neighbor's.

## Good to know

- **It's practice data**, not a real website's. Claude will always remind you of that.
- If you ever install a real Google tag later, these tables are shaped exactly like
  real Google Analytics data — your dashboard won't need to change.
- Messed something up? Just tell Claude *"re-run the analytics seed"* — it wipes and
  regenerates fresh data safely.

---

*(The other files — DUMMY_DATA_FOR_CLAUDE.md, README.md, schema.sql, seed.sql — are
for Claude to read. You don't need to open them. Once setup is done, try asking Claude:
**"what could my dashboard show?"** — it has a whole menu ready.)*
