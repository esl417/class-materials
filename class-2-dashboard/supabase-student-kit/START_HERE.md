# Start Here 👋

You're going to connect your Supabase project to Claude so it can build your database
and backend for you. **You don't need to know anything technical.** Claude does all of
it.

## Before you start

You need a **Supabase account and an empty project already created.** (Your class slides
cover signing up and making the project — do that first.) Have the project open in your
browser when you start.

## What to do

1. Open your **dashboard project** in VS Code (the same folder you used for the analytics
   setup) and open **Claude Code** in it.
2. Copy/paste this message to Claude:

   > **"Grab the Supabase setup kit from https://github.com/esl417/class-materials (the
   > files in `class-2-dashboard/supabase-student-kit`) into this project, then read
   > SUPABASE_SETUP_FOR_CLAUDE.md and do everything in it for me. I'm not technical —
   > handle all the setup yourself, and stop to tell me whenever you need me to click
   > something in my web browser."**

3. Partway through, Claude will ask you to **fully quit and reopen Claude Code once** (the
   Supabase tools only switch on after a restart). **This is the important part:** when you
   reopen it, click the **🕐 clock icon at the top-right** of the Claude box to open your
   **conversation history**, and pick the chat you were just in — that's how Claude
   remembers where it was. Then say: **"continue the Supabase setup."**

4. Near the end, you'll **click "Authorize" on a Supabase page in your browser once** and
   pick your project. Claude handles everything else.

> Three things you do by hand: **restart the app once**, **reopen the same chat from the
> 🕐 history**, and **click Authorize once.** That's all.
>
> 💡 If the Claude box disappears after you reopen the app, just **click any file** in your
> project on the left and it'll come right back.

## What this does

- ✅ Lets Claude **build and update your database** (create tables, run "migrations").
- ✅ Lets Claude **deploy backend functions** to your project.
- ✅ Everything stays in **your own** Supabase project — nobody else's.

When it's done, you can ask Claude to build database tables and backend logic, and it
will set them up in your real project.

---

*(The other files — SUPABASE_SETUP_FOR_CLAUDE.md, etc. — are for Claude to read. You
don't need to open them.)*
