# Helper scripts — for Claude to create

These are the two files Claude writes into the working folder during **Step 5** of
GA4_SETUP_FOR_CLAUDE.md. They use only Node's built-ins (`fetch` + `crypto`) — no `npm
install` needed. Claude: create each file verbatim, then run it.

Both read `./ga4-credentials.json` (the key you downloaded) and the `GA4_PROPERTY_ID`
environment variable.

---

## `discover.mjs`

Prints everything the property exposes — dimensions, metrics (custom flagged), and the
events seen in the last 30 days. Run with:
`GA4_PROPERTY_ID=<number> node discover.mjs`

```javascript
// discover.mjs — list every dimension/metric/event a GA4 property exposes.
import { readFileSync } from "node:fs";
import { createSign } from "node:crypto";

const PROPERTY_ID = process.env.GA4_PROPERTY_ID;
if (!PROPERTY_ID) {
  console.error("Set GA4_PROPERTY_ID (the numeric property id, e.g. 123456789).");
  process.exit(1);
}
const creds = JSON.parse(readFileSync(new URL("./ga4-credentials.json", import.meta.url)));

async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const b64url = (obj) => Buffer.from(JSON.stringify(obj)).toString("base64url");
  const header = b64url({ alg: "RS256", typ: "JWT" });
  const payload = b64url({
    iss: creds.client_email,
    scope: "https://www.googleapis.com/auth/analytics.readonly",
    aud: "https://oauth2.googleapis.com/token",
    iat: now, exp: now + 3600,
  });
  const signature = createSign("RSA-SHA256").update(`${header}.${payload}`).sign(creds.private_key, "base64url");
  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${header}.${payload}.${signature}`,
  });
  if (!resp.ok) throw new Error(`Google auth failed (${resp.status}): ${await resp.text()}`);
  return (await resp.json()).access_token;
}

async function getMetadata(token) {
  const resp = await fetch(
    `https://analyticsdata.googleapis.com/v1beta/properties/${PROPERTY_ID}/metadata`,
    { headers: { Authorization: `Bearer ${token}` } });
  if (!resp.ok) throw new Error(`metadata failed (${resp.status}): ${await resp.text()}`);
  return resp.json();
}

async function getEvents(token) {
  const resp = await fetch(
    `https://analyticsdata.googleapis.com/v1beta/properties/${PROPERTY_ID}:runReport`,
    {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        dateRanges: [{ startDate: "30daysAgo", endDate: "yesterday" }],
        dimensions: [{ name: "eventName" }],
        metrics: [{ name: "eventCount" }],
        orderBys: [{ metric: { metricName: "eventCount" }, desc: true }],
        limit: 100,
      }),
    });
  if (!resp.ok) throw new Error(`events report failed (${resp.status}): ${await resp.text()}`);
  return resp.json();
}

const token = await getAccessToken();
console.log(`authed as ${creds.client_email}`);
console.log(`property ${PROPERTY_ID}\n`);

const meta = await getMetadata(token);
console.log(`DIMENSIONS (${meta.dimensions?.length || 0})`);
console.log("-".repeat(60));
for (const d of meta.dimensions || []) {
  console.log(`  ${d.apiName.padEnd(34)} ${d.uiName}${d.customDefinition ? "  [custom]" : ""}`);
}
console.log(`\nMETRICS (${meta.metrics?.length || 0})`);
console.log("-".repeat(60));
for (const m of meta.metrics || []) {
  console.log(`  ${m.apiName.padEnd(34)} ${m.uiName} (${m.type})${m.customDefinition ? "  [custom]" : ""}`);
}

const events = await getEvents(token);
console.log(`\nEVENTS seen last 30 days (${events.rows?.length || 0})`);
console.log("-".repeat(60));
for (const row of events.rows || []) {
  console.log(`  ${row.dimensionValues[0].value.padEnd(34)} ${row.metricValues[0].value}`);
}
if (!events.rows?.length) console.log("  (no events yet — property is new or has no traffic)");
```

---

## `query.mjs`

Runs any GA4 `runReport` and prints the rows. Pass a JSON report body as the first
argument:
`GA4_PROPERTY_ID=<number> node query.mjs '{"dateRanges":[...],"dimensions":[...],"metrics":[...]}'`

```javascript
// query.mjs — run any GA4 runReport and print the rows.
import { readFileSync } from "node:fs";
import { createSign } from "node:crypto";

const PROPERTY_ID = process.env.GA4_PROPERTY_ID;
if (!PROPERTY_ID) { console.error("Set GA4_PROPERTY_ID first."); process.exit(1); }
const creds = JSON.parse(readFileSync(new URL("./ga4-credentials.json", import.meta.url)));

// Default report if none is passed: sessions by channel, last 7 days.
const DEFAULT_REPORT = {
  dateRanges: [{ startDate: "7daysAgo", endDate: "yesterday" }],
  dimensions: [{ name: "sessionDefaultChannelGroup" }],
  metrics: [{ name: "sessions" }, { name: "engagedSessions" }],
  orderBys: [{ metric: { metricName: "sessions" }, desc: true }],
};
const REPORT = process.argv[2] ? JSON.parse(process.argv[2]) : DEFAULT_REPORT;

async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const b64url = (obj) => Buffer.from(JSON.stringify(obj)).toString("base64url");
  const header = b64url({ alg: "RS256", typ: "JWT" });
  const payload = b64url({
    iss: creds.client_email,
    scope: "https://www.googleapis.com/auth/analytics.readonly",
    aud: "https://oauth2.googleapis.com/token",
    iat: now, exp: now + 3600,
  });
  const signature = createSign("RSA-SHA256").update(`${header}.${payload}`).sign(creds.private_key, "base64url");
  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${header}.${payload}.${signature}`,
  });
  if (!resp.ok) throw new Error(`auth failed (${resp.status}): ${await resp.text()}`);
  return (await resp.json()).access_token;
}

const token = await getAccessToken();
const resp = await fetch(
  `https://analyticsdata.googleapis.com/v1beta/properties/${PROPERTY_ID}:runReport`,
  {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
    body: JSON.stringify(REPORT),
  });
if (!resp.ok) { console.error(`report failed (${resp.status}): ${await resp.text()}`); process.exit(1); }

const data = await resp.json();
const headers = [
  ...(data.dimensionHeaders || []).map((h) => h.name),
  ...(data.metricHeaders || []).map((h) => h.name),
];
console.log(headers.join(" | "));
console.log("-".repeat(60));
for (const row of data.rows || []) {
  const vals = [
    ...(row.dimensionValues || []).map((v) => v.value),
    ...(row.metricValues || []).map((v) => v.value),
  ];
  console.log(vals.join(" | "));
}
if (!data.rows?.length) console.log("(no rows)");
```

---

## Reference: GA4 report shape

The argument to `query.mjs` is a GA4 Data API `runReport` body. Key fields:

- `dateRanges`: `[{ startDate, endDate }]` — dates can be `YYYY-MM-DD`, `NdaysAgo`,
  `yesterday`, `today`.
- `dimensions`: `[{ name: "..." }]` — the "by what" (e.g. `country`, `eventName`).
- `metrics`: `[{ name: "..." }]` — the "how many" (e.g. `sessions`, `purchaseRevenue`).
- `dimensionFilter`, `orderBys`, `limit` — optional.

Always run `discover.mjs` first to get the exact field names for that property; don't
guess them.
