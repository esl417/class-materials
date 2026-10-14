# Start Here 👋

You're going to connect your Supabase project to Claude so it can build your database
and backend for you. **You don't need to know anything technical.** Claude does all of
it.

## Before you start

You need a **Supabase account and an empty project already created.** (Your class slides
cover signing up and making the project — do that first.) Have the project open in your
browser when you start.

## What to do

1. Open your **dashboard project** in the Claude app's **Code** tab (the same folder you
   used for the analytics setup).
2. Copy/paste this message to Claude:

   > **"Grab the Supabase setup kit from https://github.com/esl417/class-materials (the
   > files in `class-2-dashboard/supabase-student-kit`) into this project, then read
   > SUPABASE_SETUP_FOR_CLAUDE.md and do everything in it for me. I'm not technical —
   > handle all the setup yourself, and stop to tell me whenever you need me to click
   > something in my web browser."**

3. Partway through, Claude will ask you to **add the Supabase connector**: click **+**
   next to the message box, choose **Connectors → Manage connectors**, click the
   **Discover** tab at the top, search **Supabase**, add it, and sign in.

4. A Supabase page opens in your browser. Sign in if asked, **pick your class project**,
   and click **Authorize**. Then tell Claude you're done.

> If Claude can't see Supabase yet, it will ask you to start a fresh session: click
> **+ New session**, choose **Local → Select folder**, pick your dashboard folder, and
> type **"continue the Supabase setup."**

## What this does

- ✅ Lets Claude **build and update your database** (create tables, run "migrations").
- ✅ Lets Claude **deploy backend functions** to your project.
- ✅ Everything stays in **your own** Supabase project — nobody else's.

When it's done, you can ask Claude to build database tables and backend logic, and it
will set them up in your real project.

---

*(The other files — SUPABASE_SETUP_FOR_CLAUDE.md, etc. — are for Claude to read. You
don't need to open them.)*
