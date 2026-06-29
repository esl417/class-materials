# Start Here 👋

You're going to connect your Google Analytics to Claude so it can read your website's
data for you. **You don't need to know anything technical.** Claude does all of it.

## What to do

1. Make a new empty folder for your dashboard project (e.g. `my-dashboard`) and open it
   in **VS Code**.
2. Open **Claude Code** in that folder.
3. Copy/paste this one message to Claude:

   > **"Grab the GA4 setup kit from https://github.com/esl417/class-materials (the files in
   > `class-2-dashboard/ga4-student-kit`) into this project, then read
   > GA4_SETUP_FOR_CLAUDE.md and do everything in it for me. I'm not technical — handle all
   > the setup yourself, and stop to tell me whenever you need me to click something in my
   > web browser."**

4. That's it. Claude will work through the setup and **pause twice** to ask you to click
   something in your browser (signing into Google, and giving permission in Google
   Analytics). Just follow what it tells you in those moments.

## What you'll need

- A **Google account** (the one your Google Analytics is under).
- A **Google Analytics property that already has some data** — i.e. analytics is already
  running on a website. If you don't have that yet, tell Claude and it will guide you.
- 💡 If your Google account is a **work or school account** and something gets blocked,
  Claude will tell you — the easy fix is to use a personal `@gmail.com` account instead.

## What this does / doesn't do

- ✅ Gives Claude **read-only** access — it can *look at* your analytics, nothing else.
- ✅ You cannot break or change your analytics with this.
- ❌ It does **not** post, edit, or delete anything.

When it's done, you can just ask Claude things like *"how many people visited my site last
week?"* and it will pull the real answer.

---

*(The other files — GA4_SETUP_FOR_CLAUDE.md, SCRIPTS.md, setup.sh — are for Claude to
read and use. You don't need to open them.)*
