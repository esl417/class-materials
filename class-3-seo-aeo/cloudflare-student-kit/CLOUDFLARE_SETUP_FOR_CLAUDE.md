# Cloudflare Setup — Instructions for Claude Code

> **Human: you don't need to understand any of this.** Open Claude Code in your website
> project, give it this file, and say: **"Read this and do everything in it for me. Stop
> and tell me whenever you need me to click something in my browser."** Claude does the rest.

---

## Claude: read this whole file before doing anything. This is your runbook.

You are preparing a **completely non-technical person's** machine for a class where they
build a dual-surface website on Cloudflare (a normal site for humans, a separate set of
pages for AI crawlers, and a Worker that routes between them). **This kit is setup only —
you do NOT deploy anything, create any Workers or Pages projects, or change any DNS
records today.** The build happens in class.

Your three jobs today, in order:

1. Install **Cloudflare's official skills + plugin** so you (Claude) work from Cloudflare's
   current instructions instead of stale memory.
2. Log the terminal in to **their** Cloudflare account (`wrangler login` via browser OAuth).
3. **Verify** everything: login works, their domain is active on Cloudflare, and their live
   site still loads correctly.

**Do everything yourself.** The human cannot use a terminal or read code. **Never ask them
to run a command or edit a file.** The only things they do are marked **🙋 HUMAN STEP**:
restarting Claude Code once, and clicking **Allow** in their browser once. When you reach
one, STOP, give one plain instruction, and wait.

### Ground rules for you (Claude)

- Plain language. Never show the human raw error text — read it yourself, say one friendly
  sentence about what's happening.
- One instruction at a time. Reassure them — this is intimidating for them, routine for you.
- Nothing you do today touches their live website. Say so if they seem nervous.

---

## Step 0 — Preflight (you do this)

1. Confirm Node.js works: `node --version` (want v18+). If it's missing, the human needs to
   install it from https://nodejs.org (LTS) and restart their terminal — that's a
   🙋 HUMAN STEP; walk them through it plainly, then re-check.
2. Confirm you're in their **website project** (their site's code should be here — look for
   the pages/site files and a git repo). If this folder looks empty or wrong, ask them to
   open the folder their website lives in (the Class 1 project) and start again there.
3. Check for stale Cloudflare credentials that would conflict with a fresh login:
   - `env | grep -i cloudflare` — if `CLOUDFLARE_API_TOKEN` (or similar) is set, it will
     override the browser login and cause confusing auth errors. Note where it comes from
     (shell profile, `.env` files in this project) and neutralize it for this setup —
     unset it for your commands, and tell the human plainly if a file needs their OK to edit.

---

## Step 1 — Install Cloudflare's official skills + plugin (you do this)

Run these two commands:

```bash
claude plugin marketplace add cloudflare/skills
claude plugin install cloudflare@cloudflare
```

The first registers Cloudflare's official skills marketplace (the knowledge — how to use
Wrangler, Pages, Workers correctly, current as of today). The second installs the
Cloudflare plugin (skills + MCP server for live docs and deploy status). If either reports
it's already installed, that's fine — continue.

After install, the plugin is registered but its tools are **not loaded into this session
yet** — they only load when Claude Code starts up. That's Step 2.

---

## Step 2 — 🙋 HUMAN STEP: RESTART Claude Code (required — don't skip)

Tell the human, plainly:

> "I just installed the Cloudflare tools, but they only switch on when Claude Code
> restarts. Please **fully quit Claude Code and open it again in this same folder.** When
> it reopens, click the **🕐 clock icon at the top-right of the Claude box** to open your
> conversation history, and pick *this* chat so I remember where we were — then say
> *continue the Cloudflare setup.*"

Wait for them to restart and return. **You cannot do this step for them.** (If they start a
brand-new chat instead, have them reopen the prior chat from the 🕐 history — or just
re-read this file and continue from Step 3.)

> If they say the Claude box / Anthropic logo vanished after reopening the app, tell them:
> *"Just click any file in your project on the left — the Claude panel comes right back."*

> Claude, after the restart: re-read this file, confirm the plugin is enabled
> (`claude plugin list` shows the cloudflare plugin ✔ enabled), then continue to Step 3.

---

## Step 3 — 🙋 HUMAN STEP: log in to Cloudflare in the browser

Run:

```bash
npx wrangler@latest login
```

(First run downloads Wrangler automatically — a few seconds of nothing happening is
normal.) A Cloudflare page opens in their browser. Tell the human:

> "A Cloudflare page just opened in your browser. Sign in to your Cloudflare account and
> click **Allow** — that's you giving me permission to work on your account. Tell me when
> it says you can close the tab."

Approve **all** requested permissions on the consent screen (they're needed for the class
build). Wait for them to confirm.

If the login errors with an authentication problem (e.g. "Authentication error
[code: 10000]" or "Unable to get membership roles"), a stale API token is conflicting
(see Step 0.3): run `npx wrangler@latest logout`, clear the token from the environment,
then `npx wrangler@latest login` again fresh.

---

## Step 4 — Verify the login (you do this)

```bash
npx wrangler@latest whoami
```

This should print their account name and ID. Tell the human the friendly version:

> "You're logged in — I can see your Cloudflare account ([account name])."

---

## Step 5 — Verify their domain is live on Cloudflare (you do this)

Ask the human what their domain is (e.g. `yourbusiness.com`) if you can't infer it from
the project. Then check:

1. **Nameservers point at Cloudflare:** `dig NS theirdomain.com +short` (macOS/Linux) or
   `nslookup -type=NS theirdomain.com` (Windows). You should see two hosts ending in
   `.ns.cloudflare.com`.
   - If you don't: the domain hasn't been added to Cloudflare, the nameserver switch
     hasn't been made at their registrar, or it's still propagating (it can take up to a
     day). Point them back to the prerequisite slides for Step 1 and offer to walk them
     through it. Don't continue to "done" until this passes — it's the class's one hard
     prerequisite.
2. **Their live site still works:** `curl -sSIL https://theirdomain.com` — you want a
   final `200` (a couple of redirects on the way, e.g. to `www`, is fine).
   - **Redirect loop or SSL error?** This is the known post-move gotcha: the zone's
     SSL/TLS mode needs to be **Full (strict)** (the "Flexible" mode loops with hosts like
     Vercel). Wrangler can't change zone SSL settings — walk the human through it in the
     dashboard, one click at a time: dash.cloudflare.com → their domain → **SSL/TLS** →
     set mode to **Full (strict)**. Then re-check with curl.

---

## Step 6 — Report done (you do this)

Tell the human, plainly, confirming each item:

> "All set for class. ✅ Your domain is live on Cloudflare. ✅ Your site works exactly like
> before — I just checked it. ✅ I have Cloudflare's official, current instructions
> installed. ✅ Your terminal is logged in to your account. On class day we build the
> AI-bot version of your site right here in this project. Nothing on your live site has
> changed today."

**Do not** create Workers, Pages projects, `wrangler.toml`, or an `llm/` folder now —
class does that together.

---

## Troubleshooting (read the matching case, then act)

| What you see | What it means | What you do |
|---|---|---|
| Cloudflare tools/skills missing after install | **Session wasn't restarted** (most common) | This is Step 2 — the human must fully quit and reopen Claude Code in this folder. Plugins load only at startup. |
| "In a non-interactive environment… set CLOUDFLARE_API_TOKEN" | Not logged in | Run `npx wrangler@latest login` (Step 3) and have them authorize in the browser. |
| "Authentication error [code: 10000]" / "Unable to get membership roles" | Stale API token conflicting with browser login | `npx wrangler@latest logout`, clear `CLOUDFLARE_API_TOKEN` from env/`.env` files, `npx wrangler@latest login` fresh, approve **all** permissions. |
| `npx wrangler` hangs or errors on first run | Downloading Wrangler on first use | Give it a few seconds + working internet. If it fails, `npm cache clean --force` and retry. |
| `dig` shows non-Cloudflare nameservers | Nameserver switch not made or still propagating | Check the registrar setting was actually saved; propagation can take up to ~24h. Re-check later. |
| Cloudflare dashboard shows domain "Pending" | Same as above — not settled yet | Wait; Cloudflare emails when Active. |
| Site loops / SSL error after the move | Zone SSL/TLS mode is wrong for their host | Walk them through setting SSL/TLS mode to **Full (strict)** in the dashboard (Step 5.2). |
| `node: command not found` | Node.js missing or terminal not restarted after install | Install LTS from https://nodejs.org, close and reopen the terminal, re-check. |

---

## What "done" looks like

- The Cloudflare official skills marketplace + plugin are installed and enabled.
- `npx wrangler@latest whoami` prints **their** account.
- Their domain's nameservers end in `.ns.cloudflare.com` and the zone is **Active**.
- `https://theirdomain.com` loads with a final `200` — the site is unchanged.
- You deployed **nothing** and changed **no DNS records**; you paused only at the 🙋 steps.
