# Supabase Setup — Instructions for Claude Code

> **Human: you don't need to understand any of this.** Open Claude Code in this folder,
> give it this file, and say: **"Read this and do everything in it for me. Stop and tell
> me whenever you need me to click something in my browser."** Claude does the rest.

---

## Claude: read this whole file before doing anything. This is your runbook.

You are connecting a **completely non-technical person's** own Supabase project to
yourself (Claude Code) so that **you** can build their database — create tables, run
migrations, deploy edge functions — directly. You do this by installing the **official
Supabase plugin**, which gives you both the Supabase MCP server (the live connection) and
Supabase skills (best-practice knowledge), then having the human approve access with a
single browser click.

**Your job is to do everything yourself.** The human cannot use a terminal or read code.
**Never ask them to run a command or edit a file.** The ONLY thing they do is **click
"Authorize" in their browser once**. That moment is marked **🙋 HUMAN STEP**. When you
reach it, STOP, give one plain instruction, and wait.

### What you'll end up with (verified flow)

1. The `supabase` plugin installed → bundles the MCP server + skills.
2. The Supabase MCP server **authenticated** via the human's browser (OAuth — no token to
   copy or paste).
3. Write-capable MCP tools available: `list_tables`, `execute_sql`, `apply_migration`,
   `deploy_edge_function`, and more — you call these directly, no terminal.

### Ground rules for you (Claude)

- Plain language. Never show the human raw error text — read it yourself, say one friendly
  sentence about what's happening.
- One instruction at a time. Reassure them — this is intimidating for them, routine for
  you.
- During the browser authorization, the human chooses **which Supabase organization /
  project** to grant. Make sure they pick the project for this class.

---

## Step 1 — 🙋 HUMAN STEP: make sure they have a project

Ask:

> "Do you already have a Supabase project? An empty one is fine. If not, go to
> **supabase.com** → sign in → **New project**, give it a name and a database password
> (save that password somewhere safe), and create it. Tell me once you have a project."

Wait until they confirm a project exists.

---

## Step 2 — Install the Supabase plugin (you do this)

Run:

```bash
claude plugin install supabase@claude-plugins-official
```

This installs the official Supabase plugin (skills + MCP server) from the pre-configured
official marketplace — no marketplace setup needed. If it reports it's already installed,
that's fine.

> If for any reason that marketplace isn't available, add it first:
> `claude plugin marketplace add anthropics/claude-plugins-official` then re-run the
> install. As a last resort you can register the MCP server directly without the plugin:
> `claude mcp add --transport http supabase "https://mcp.supabase.com/mcp"` — but prefer
> the plugin, since it also gives you the Supabase skills.

After install, the plugin is registered but its tools are **not loaded into this session
yet** — and that's the #1 thing that trips people up. Read Step 3 carefully.

---

## Step 3 — 🙋 HUMAN STEP: RESTART Claude Code (required — don't skip)

**A plugin's tools only load when Claude Code starts up.** Because you just installed the
plugin mid-session, its Supabase tools and the `/mcp` connection will NOT appear until the
session is restarted. This is expected, not a bug.

Tell the human, plainly (and point them at the visual walkthrough — this is the step
people get stuck on):

> "I just installed the Supabase tools, but they only switch on when Claude Code restarts.
> Please **fully quit Claude Code and open it again in this same folder.** When it reopens,
> click the **🕐 clock icon at the top-right of the Claude box** to open your conversation
> history, and pick *this* chat so I remember where we were — then say *continue the
> Supabase setup.* Here's a short visual of exactly how to get back into this chat:
> **https://class-1-deck.vercel.app/class-2-dashboard-build/prereqs.html#restart**"

Wait for them to restart and return. **You cannot do this step for them** — they must
restart the app and reopen this conversation themselves. (If they start a brand-new chat
instead, you'll have lost this context; in that case have them reopen the prior chat from
the 🕐 history, or just re-read this file and continue from Step 4.)

> If they say the Claude box / Anthropic logo vanished after reopening the app, tell them:
> *"Just click any file in your project on the left — the Claude panel comes right back."*

> Claude, after the restart: re-read this file, confirm the plugin is enabled
> (`claude plugin list` shows `supabase ... ✔ enabled`), and confirm the MCP server now
> appears (`claude mcp list` shows `plugin:supabase:supabase`). Then continue to Step 4.

---

## Step 4 — 🙋 HUMAN STEP: authorize Supabase in the browser

The Supabase MCP server uses a secure browser sign-in (OAuth) — there is **no token to
copy or paste** (this is by design; the sign-in must be started by the app, not a link).

Tell the human to open the connection menu and authenticate:

> "Now let's connect to your Supabase. Please type **`/mcp`** and press enter, pick
> **`supabase`** from the list, and choose **Authenticate** (or Login). A Supabase page
> will open in your browser — sign in if asked, **choose the project for this class**, and
> click **Authorize**. Tell me when it says connected."

Wait for them. Then confirm the connection is live: `claude mcp list` should show the
Supabase server **without** "Needs authentication", and the Supabase MCP tools should be
available to you.

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

Once connected, prefer the MCP tools over the terminal. The bundled **`supabase` skill**
fires automatically for Supabase work — follow it; it has the current best practices.

- **Schema change / new table** → write SQL and call `apply_migration` (records a proper
  timestamped migration). Use `execute_sql` for quick iteration, then capture a clean
  migration when ready.
- **Inspect data** → `execute_sql` with a `select`.
- **Edge function** → `deploy_edge_function` with the name + code.
- **Extensions / pg_cron / scheduled jobs** → `apply_migration` with the
  `create extension ...` / `cron.schedule(...)` SQL (pg_cron is available on Supabase).
- For auth/RLS/storage specifics, lean on the `supabase` and
  `supabase-postgres-best-practices` skills the plugin installed.

Keep migrations as the source of truth so the student's project stays reproducible.

---

## Step 7 — Troubleshooting (read the matching case, then act)

| What you see | What it means | What you do |
|---|---|---|
| `/mcp` doesn't list supabase, or tools missing after install | **Session wasn't restarted** (most common) | This is Step 3 — the human must fully quit and reopen Claude Code in this folder. Plugins load only at startup. |
| `claude plugin list` shows supabase but no `✔ enabled` | Plugin installed but disabled | Run `claude plugin enable supabase@claude-plugins-official`, then restart the session. |
| Server says "Needs authentication" | OAuth (Step 3) not completed | Trigger the auth flow again; make sure they clicked **Authorize** and picked the right project. |
| Authorized the wrong project/org | Picked wrong one in the browser | Re-run the auth flow and choose the correct organization/project. |
| Writes rejected / only reads work | Connected in read-only mode | Re-authorize; ensure the project URL has no `read_only=true`. The plugin's default is write-capable. |
| `plugin install` can't find it | Official marketplace not registered | `claude plugin marketplace add anthropics/claude-plugins-official`, then re-run install. |
| `apply_migration` fails on schema SQL | SQL error, not access | Read the DB error, fix the SQL, retry. The bundled skill has Postgres guidance. |

---

## What "done" looks like

- The `supabase` plugin is installed (skills + MCP).
- The Supabase MCP server is **authenticated** and scoped to **their** project.
- `list_tables` works, and `apply_migration` / `deploy_edge_function` are available.
- You never asked them to type a command or read code; you paused only at the 🙋 steps.
