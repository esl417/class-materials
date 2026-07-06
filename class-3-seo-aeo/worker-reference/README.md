# Routing Worker — reference files for the dual-web build

> **Human: you don't open these.** They're a known-good template for Claude to
> copy from, so the front door you build in class works on the first try instead
> of needing debugging. Claude reads them; you just approve deploys.

These are the **canonical, tested** versions of the two files that make the
dual-surface site route correctly:

- **`worker.js`** — the router (the "front door"). Sends AI crawlers to your
  bot-optimized Pages surface; sends humans + Google/Bing straight to your real
  site. Includes a current, well-maintained list of AI crawler user-agents so
  Claude doesn't have to invent one.
- **`wrangler.toml`** — binds the Worker to the domain **with a route** (not a
  Custom Domain — see the note in the file; this is the single most common way
  the build breaks).

---

## Claude: how to use these

1. Copy `worker.js` into the project's `infra/` (or wherever the Worker lives).
   Set the one `PAGES_URL` constant to the `*.pages.dev` URL from
   `wrangler pages deploy`. Change nothing else in the routing logic.
2. Copy `wrangler.toml` next to it. Replace `yourdomain.com` (both places) with
   the student's real domain. **Keep the `routes = [...]` form** — do not switch
   it to `custom_domain = true`.
3. Deploy: `npx wrangler@latest deploy`.
4. Verify with the three-request routing test (GPTBot / normal browser /
   Googlebot). Googlebot MUST match the human result — that's the cloaking check.

The reference `worker.js` here is deliberately **stripped of any analytics/beacon
wiring** — it's pure routing so it's easy to read and can't leak anything. If the
student later wants bot-hit analytics, that's an additive step, not part of this
template.

---

## ⚠️ Bot-traffic control — the Cloudflare setting that silently blocks crawlers

Cloudflare has features (in **AI Crawl Control** / bot settings) that can **block
AI crawlers by default**. If those are on, your router works perfectly but the AI
bots never even reach it — so nothing gets served the optimized pages, and it
looks broken for no visible reason.

**Claude: after deploying, verify the student's zone is not blocking the AI bots
they want to reach them.** In the Cloudflare dashboard: the zone → **AI Crawl
Control** (and Security → Bots). The crawlers listed in `worker.js` (`aiSearchBots`)
should be **allowed**, not blocked. If any are blocked, walk the student through
allowing them, one click at a time. This is a "it deployed fine but no AI traffic
shows up" gotcha — check it before concluding anything is wrong with the routing.

> AI Crawl Control is also the reference for keeping the bot list current — new
> AI crawlers show up there first; add their user-agent token to `aiSearchBots`
> in `worker.js` and redeploy.
