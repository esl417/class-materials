/**
 * Dual-web routing Worker — CLASS 3 REFERENCE TEMPLATE
 *
 * This is a known-good starting point for the front door you build in class.
 * It routes AI crawlers to your bot-optimized Pages site, and sends humans +
 * traditional search engines (Google, Bing) straight through to your real site.
 *
 * Claude: use this as the template. The ONLY thing you must change is the one
 * marked PAGES_URL below — set it to the *.pages.dev URL from the Pages deploy.
 * Everything else works as-is. Keep the three bot lists as they are unless you
 * have a specific reason to add a crawler (Cloudflare's AI Crawl Control
 * dashboard is the reference for new AI bot user-agents).
 *
 * Why this exists: writing the router from scratch invites two classic bugs —
 * (1) putting Google in the AI-bot list (that's cloaking; Google penalizes it),
 * and (2) using a redirect instead of a pass-through fetch (leaks the bot origin
 * and changes the visitor's URL). This template gets both right. Don't "improve"
 * those two things.
 */

// 🔧 THE ONE THING TO SET: your Cloudflare Pages URL (from `wrangler pages deploy`).
// It looks like https://your-project-name.pages.dev — no trailing slash.
const PAGES_URL = 'https://YOUR-PAGES-PROJECT.pages.dev';

export default {
  async fetch(request, env, ctx) {
    const userAgent = (request.headers.get('user-agent') || '').toLowerCase();
    const url = new URL(request.url);

    // ── Traditional search engines ──────────────────────────────────────────
    // CRITICAL: these MUST get the same pages as humans. Serving them the bot
    // surface is cloaking, and Google will penalize the site. Do NOT move any
    // of these into the AI list below.
    const traditionalSearchBots = [
      'googlebot',
      'google-cloudvertexbot',
      'bingbot',
      'slurp',            // Yahoo
      'baiduspider',
      'yandexbot',
      'applebot',
      'duckduckbot',
    ];

    // ── AI crawlers ─────────────────────────────────────────────────────────
    // These CAN receive the bot-optimized surface. Keep this list current from
    // Cloudflare's AI Crawl Control dashboard as new crawlers appear.
    const aiSearchBots = [
      // AI assistants & answer engines
      'gptbot',            // OpenAI GPT
      'oai-searchbot',     // OpenAI Search
      'chatgpt-user',      // ChatGPT live fetch
      'claudebot',         // Anthropic Claude
      'claude-searchbot',  // Anthropic Search
      'claude-user',       // Claude live fetch
      'perplexitybot',     // Perplexity
      'perplexity-user',   // Perplexity live fetch
      'mistralai-user',    // Mistral
      'duckassistbot',     // DuckDuckGo Assist (AI)
      'you-com-bot',       // You.com AI
      'anthropic-ai',      // Anthropic generic
      // Social preview crawlers (fine to serve the clean version to)
      'facebookbot',
      'meta-externalagent',
      'meta-externalfetcher',
      'twitterbot',
      'linkedinbot',
      // Other AI / data crawlers
      'ccbot',             // Common Crawl (AI training)
      'bytespider',        // ByteDance
      'petalbot',          // Huawei AI
      'amazonbot',         // Amazon (AI training)
      'archive.org_bot',   // Internet Archive
    ];

    // ── SEO tools ───────────────────────────────────────────────────────────
    // Not cloaking-sensitive; fine to give them the optimized surface too.
    const seoToolBots = [
      'semrushbot',
      'ahrefsbot',
      'mj12bot',           // Majestic
      'screaming frog',
    ];

    const isTraditionalSearchBot = traditionalSearchBots.some(b => userAgent.includes(b));
    const isAISearchBot = aiSearchBots.some(b => userAgent.includes(b));
    const isSEOToolBot = seoToolBots.some(b => userAgent.includes(b));

    // ── Route AI crawlers + SEO tools → the bot-optimized Pages surface ───────
    // This is a pass-through fetch (a proxy), NOT a redirect: the visitor's URL
    // stays on your apex domain, and the .pages.dev origin never shows.
    if (isAISearchBot || isSEOToolBot) {
      return fetch(PAGES_URL + url.pathname, {
        method: request.method,
        headers: request.headers,
        body: request.body,
      });
    }

    // ── Everyone else (humans + Google/Bing) → your real site, untouched ──────
    // `fetch(request)` passes through to your apex origin (your human site,
    // e.g. Vercel, reached via the Cloudflare-proxied DNS record). Because this
    // Worker is bound with a ROUTE (not a Custom Domain), that origin record is
    // still in place for this pass-through to reach.
    return fetch(request);
  },
};
