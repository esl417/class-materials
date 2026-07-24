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
| `../content-guide/AEO_CONTENT_GUIDE.md` | project **root** | The writing standard for every bot page. **Copy it into the project** — the student keeps writing bot pages long after class, and this is what tells Claude how. |

## The platform split (the mental model these files enforce)

Two platforms, two jobs — and the config files are what keep them from stepping
on each other:

- **Vercel** serves the **human site** (your Next.js / static site). `.vercelignore`
  tells it to ignore `/llm/` and `/infra/` so it never tries to bundle or serve
  the bot surface or the Worker source.
- **Cloudflare Pages** serves the **bot surface** (`llm/`). It's connected to the
  project's **GitHub repo** (dashboard Git integration) with its build-output
  directory set to `llm/`, so it only ever sees those files (`_headers`,
  `robots.txt`, the generated pages). Because it auto-pulls from GitHub, **every
  `git push` rebuilds and redeploys the bot surface automatically** — there is no
  separate upload step for the student to remember.
- **The Cloudflare Worker** (`infra/worker.js`) sits in **front** of both via a
  route, and decides who gets which.

### Two deploy models — this trips people up, so be clear about it

The two Cloudflare pieces deploy in **different** ways, on purpose:

| Piece | How it deploys | Who triggers it |
|---|---|---|
| **Pages** (bot surface, `llm/`) | **auto-pulls from GitHub** — connected once in the dashboard | every `git push` |
| **Worker** (`infra/worker.js`) | **CLI** — `wrangler deploy` | you (Claude), run it |

This is the architecture the class ships from the start: **the student never runs
a separate command to publish bot-surface content.** They (or you) edit a page in
`llm/`, `git push`, and Cloudflare Pages rebuilds it automatically — the same
push that updates their human site's repo. The only thing that deploys by command
is the Worker, and the Worker changes rarely (basically only when the bot list
does). Do **not** teach `wrangler pages deploy` as the normal path — that's the
manual-upload model this architecture deliberately replaces, and it leaves the
student tracking a deploy step by hand forever.

## Pages auto-deploy from GitHub (set this up once — it's dashboard state, not a repo file)

Cloudflare Pages' Git integration is configured in the **dashboard**, not in any
file in the repo — that's why there's no config for it in `wrangler.toml` or
anywhere else. It lives in Cloudflare's dashboard state. Set it up once:

**Claude: walk the student through this in the dashboard, one click at a time
(it's a 🙋 human-in-the-browser step — you can't click for them).**

1. dash.cloudflare.com → **Workers & Pages** → **Create** → **Pages** →
   **Connect to Git**.
2. Authorize Cloudflare's GitHub app if prompted, then **pick the student's
   website repo** (the same repo their site is in).
3. **Production branch:** `main`.
4. **Build command:** leave **empty** — the `llm/` files are static HTML committed
   to the repo, so there's nothing to build.
5. **Build output directory:** set to `llm/` — this is the load-bearing setting.
   It makes Pages publish only the bot surface and ignore the Next.js app,
   `infra/`, scripts, etc.
6. **Save and Deploy.** Cloudflare builds and gives you the project's
   **`*.pages.dev` URL** (e.g. `their-project.pages.dev`). **That URL is what you
   put in `worker.js`'s `PAGES_URL`.**

From now on, every push to `main` auto-deploys the bot surface. Confirm it works:
make a trivial edit in `llm/`, push, and watch the deploy appear in the Pages
project's **Deployments** tab.

> `llm/_headers` is a Pages convention — Pages reads it automatically from the
> output directory and applies those security headers to the served pages. It
> only works because the output directory is `llm/`, so keep `_headers` inside
> `llm/`, not at the repo root.

## Claude: how to use these

1. `wrangler.toml` → `infra/`. Replace `yourdomain.com` (both places) with the
   real domain. **Keep the `routes = [...]` form.**
2. `.vercelignore` → project **root**. Keep the `/llm/` and `/infra/` lines.
3. `bot-surface/_headers` → `llm/_headers` (as-is). `bot-surface/robots.txt` →
   `llm/robots.txt` (change the Sitemap domain to the human apex URL).
4. **`AEO_CONTENT_GUIDE.md` → project root, and wire it in (see below).** This is
   not a one-time read — the student writes bot pages for as long as they own the
   site, so the standard has to live *in the project*, not in this repo.
5. **Commit and push** everything above (`llm/`, `infra/`) to the student's
   GitHub repo. It all has to be on GitHub before the next step — Pages deploys
   from the repo, not from the local folder.
6. **Set up Cloudflare Pages to auto-pull from GitHub** — this is the deploy
   model for the bot surface. See "Pages auto-deploy from GitHub" below. This
   gives you the `*.pages.dev` URL.
7. `worker.js` → `infra/`. Set the one `PAGES_URL` constant to the `*.pages.dev`
   URL from the Pages project you just connected. Change nothing else in the
   routing logic. Commit + push (Pages redeploys the bot surface automatically;
   `infra/` is ignored by Pages via the `llm/` output dir).
8. Deploy the **Worker** via CLI: `cd infra && npx wrangler@latest deploy`. The
   Worker is the only piece that deploys by command — Pages auto-pulls, the
   Worker does not.
9. Verify with the three-request routing test (GPTBot / normal browser /
   Googlebot). Googlebot MUST match the human result — that's the cloaking check.

## Make the AEO standard permanent (don't skip this)

Copying the guide isn't enough — a future Claude session won't know to open it.
**Add a rule to the project's `CLAUDE.md`** (create it if there isn't one) so the
standard fires automatically on every future session, with no prompt from the
student:

```markdown
## Bot surface (llm/)

- Anything in `llm/` is the AI/bot version of the site. When writing or updating
  ANY file in `llm/`, follow `AEO_CONTENT_GUIDE.md` in the project root — it is
  the writing standard for those pages. Read it first; don't write from memory.
- Never apply the AEO guide to the human site. It governs `llm/` only.
- When a page on the human site is added or changed, update its matching page in
  `llm/` to match, then redeploy the bot surface.
```

Why this matters: the class ships a *loop* (get a brief → write the pages →
grade with `/seo geo` → repeat, a few pages a week), not a one-off build. Without
the `CLAUDE.md` rule, every one of those future sessions starts from zero and
Claude writes marketing copy into `llm/` instead of answer-first AEO content.

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
