# Dual-web build — reference files

> **Human: you don't open these.** They're known-good templates for Claude to
> copy from, so the site you build in class works on the first try instead of
> needing debugging. Claude reads them; you just approve deploys.

These are the **canonical, tested** files for the dual-surface build — the router,
the two platform configs, and the bot-surface essentials. Copying from these cuts
out the classic first-time-build bugs.

## What's here

| File | Goes where | What it does |
|---|---|---|
| `worker.js` | project `infra/` | The router ("front door"): AI crawlers → bot surface; humans + Google/Bing → your real site. Includes a current AI-crawler user-agent list. |
| `wrangler.toml` | next to `worker.js` | Binds the Worker to your domain **with a route** (not a Custom Domain — the #1 way the build breaks). |
| `.vercelignore` | project **root** | Keeps `/llm/` and `/infra/` **out** of the Vercel human-site deploy, so the two surfaces stay cleanly separated. |
| `bot-surface/_headers` | your `llm/` folder | Security headers Cloudflare Pages applies to the bot surface. Copy as-is. |
| `bot-surface/robots.txt` | your `llm/` folder | Opens the bot surface to all crawlers + points to the sitemap. Change the domain. |

## The platform split (the mental model these files enforce)

Two platforms, two jobs — and the config files are what keep them from stepping
on each other:

- **Vercel** serves the **human site** (your Next.js / static site). `.vercelignore`
  tells it to ignore `/llm/` and `/infra/` so it never tries to bundle or serve
  the bot surface or the Worker source.
- **Cloudflare Pages** serves the **bot surface** (`llm/`). Its build-output
  directory is set to `llm/`, so it only ever sees those files (`_headers`,
  `robots.txt`, the generated pages).
- **The Cloudflare Worker** (`infra/worker.js`) sits in **front** of both via a
  route, and decides who gets which.

## Claude: how to use these

1. `worker.js` → `infra/`. Set the one `PAGES_URL` constant to the `*.pages.dev`
   URL from `wrangler pages deploy`. Change nothing else in the routing logic.
2. `wrangler.toml` → next to it. Replace `yourdomain.com` (both places) with the
   real domain. **Keep the `routes = [...]` form.**
3. `.vercelignore` → project **root**. Keep the `/llm/` and `/infra/` lines.
4. `bot-surface/_headers` → `llm/_headers` (as-is). `bot-surface/robots.txt` →
   `llm/robots.txt` (change the Sitemap domain to the human apex URL).
5. Deploy: `wrangler pages deploy ./llm` for the bot surface, `wrangler deploy`
   for the Worker.
6. Verify with the three-request routing test (GPTBot / normal browser /
   Googlebot). Googlebot MUST match the human result — that's the cloaking check.

The reference `worker.js` is deliberately **stripped of analytics/beacon wiring**
— pure routing, easy to read, can't leak anything. Bot-hit analytics is an
additive step later, not part of this template.

---

## ⚠️ Bot-traffic control — the Cloudflare setting that silently blocks crawlers

Cloudflare can **block AI crawlers by default** (in **AI Crawl Control** / bot
settings). If that's on, your router works perfectly but the AI bots never reach
it — so nothing gets served the optimized pages, and it looks broken for no
visible reason.

**Claude: after deploying, verify the zone isn't blocking the AI bots you want.**
Dashboard → the zone → **AI Crawl Control** (and Security → Bots). The crawlers in
`worker.js` (`aiSearchBots`) should be **allowed**. If any are blocked, walk the
student through allowing them, one click at a time. Check this before concluding
anything is wrong with the routing.

> AI Crawl Control is also the reference for keeping the bot list current — new
> AI crawlers show up there first; add their user-agent token to `aiSearchBots`
> in `worker.js` and redeploy.
