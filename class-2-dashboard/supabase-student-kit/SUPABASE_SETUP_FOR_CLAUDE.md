# Supabase Setup — Instructions for Claude Code

> **Human: you don't need to understand any of this.** Open this folder in the Claude app's Code tab,
> give it this file, and say: **"Read this and do everything in it for me. Stop and tell
> me whenever you need me to click something in my browser."** Claude does the rest.

---

## Claude: read this whole file before doing anything. This is your runbook.

You are connecting a **completely non-technical person's** own Supabase project to
yourself (Claude Code) so that **you** can build their database — create tables, run
migrations, deploy edge functions — directly. Two pieces make that work:

1. **The Supabase connector** — the live connection (Supabase's MCP server). The human
   adds it in the Claude app with a few clicks and approves access in their browser.
2. **Supabase's agent skills** — Supabase's own best-practice instructions for working in
   a Supabase project. You install these yourself.

**Your job is to do everything you can yourself.** The human cannot use a terminal or read
code. **Never ask them to run a command or edit a file.** The only things they do are
marked **🙋 HUMAN STEP**. When you reach one, STOP, give one plain instruction, and wait.

### Ground rules for you (Claude)

- Plain language. Never show the human raw error text — read it yourself, say one friendly
  sentence about what's happening.
- One instruction at a time. Reassure them — this is intimidating for them, routine for
  you.
- During the browser sign-in, the human chooses **which Supabase organization /
  project** to grant. Make sure they pick the project for this class.

---

## Step 1 — 🙋 HUMAN STEP: make sure they have a project

Ask:

> "Do you already have a Supabase project? An empty one is fine. If not, go to
> **supabase.com** → sign in → **New project**, give it a name and a database password
> (save that password somewhere safe), and create it. Tell me once you have a project."

Wait until they confirm a project exists.

---

## Step 2 — Install Supabase's agent skills (you do this)

Run:

```bash
npx skills add supabase/agent-skills
```

Install them **globally, for Claude Code** — if the installer asks which agent, choose
Claude Code; if it asks project or global, choose global. Node and npx are already on
their computer from the Class 1 setup.

If the install fails, don't stop: say one friendly sentence, carry on with Step 3, and
mention at the end that the skills can be added later. The connector is what the class
depends on; the skills make your work better.

---

## Step 3 — 🙋 HUMAN STEP: add the Supabase connector

Tell the human, plainly:

> "Now let's connect your Supabase. Click **+** next to the message box, choose
> **Connectors → Manage connectors**, click the **Discover** tab at the top, and search
> **Supabase**. Add it and sign in. A Supabase page opens in your browser — sign in if
> asked, **choose the project for this class**, and click **Authorize**. Tell me when it
> says connected."

Wait for them. The connector itself shows them anything else it needs.

---

## Step 4 — Confirm you can see it (you do this)

Check that the Supabase tools are now available to you (for example `list_tables`,
`execute_sql`, `apply_migration`, `deploy_edge_function`).

**If you can't see them yet**, the connector was added after this session started. Tell
the human:

> "One more click: start a fresh session so I can see the new connection. Click
> **+ New session** (⌘N on a Mac, Ctrl+N on Windows), choose **Local → Select folder**,
> pick your **dashboard** folder again, and type **'continue the Supabase setup.'**"

In the new session, this file is still in the project folder: re-read it and continue
from Step 5.

---

## Step 5 — Verify it works (you do this)

Prove the capabilities you'll need in class:

1. **Read** → call `list_tables` (or `execute_sql` with `select 1`). An empty project
   returns no user tables — that's success, not an error.
2. **Write is available** → confirm `apply_migration` and `deploy_edge_function` are in
   your tool list. (You don't have to apply anything yet — their presence confirms write
   access.)

Then tell the human, plainly:

> "All connected. I can now build database tables, run migrations, and deploy backend
> functions straight into your Supabase project. Want to start building?"

---

## Step 6 — How you'll build things in class (reference for you)

Once connected, prefer the connector's tools over the terminal. If Supabase's agent skills
are installed, follow them for Supabase work — they have the current best practices.

- **Schema change / new table** → write SQL and call `apply_migration` (records a proper
  timestamped migration). Use `execute_sql` for quick iteration, then capture a clean
  migration when ready.
- **Inspect data** → `execute_sql` with a `select`.
- **Edge function** → `deploy_edge_function` with the name + code.
- **Extensions / pg_cron / scheduled jobs** → `apply_migration` with the
  `create extension ...` / `cron.schedule(...)` SQL (pg_cron is available on Supabase).
- For auth/RLS/storage specifics, lean on the Supabase skills.

Keep migrations as the source of truth so the student's project stays reproducible.

---

## Step 7 — Troubleshooting (read the matching case, then act)

| What you see | What it means | What you do |
|---|---|---|
| Supabase tools missing after they added the connector | Connector was added mid-session | Step 4 — have them start a **+ New session** on the dashboard folder and say "continue the Supabase setup." |
| They can't find Supabase in Connectors | Looking in the wrong list | Walk them to **+ → Connectors → Manage connectors → Discover** and search Supabase. |
| Connector says it needs sign-in | Browser approval not finished | Have them open the connector again, sign in, pick the class project, and click **Authorize**. |
| Authorized the wrong project/org | Picked wrong one in the browser | Have them sign in to the connector again and choose the correct organization/project. |
| Writes rejected / only reads work | Connected in read-only mode | Have them reconnect and allow write access. |
| `npx skills add` fails | Network or Node issue | Not a blocker — finish the connection, then retry the skills install at the end. |
| `apply_migration` fails on schema SQL | SQL error, not access | Read the DB error, fix the SQL, retry. |

---

## What "done" looks like

- The **Supabase connector** is added and signed in, scoped to **their** project.
- Supabase's agent skills are installed globally (or you've told them they can be added later).
- `list_tables` works, and `apply_migration` / `deploy_edge_function` are available.
- You never asked them to type a command or read code; you paused only at the 🙋 steps.
