# GA4 Setup — Instructions for Claude Code

> **Human: you don't need to understand any of this.** Open Claude Code in an empty
> folder, give it this file, and say: **"Read this and do everything in it for me. Stop
> and tell me whenever you need me to click something."** That's all you have to do.
> Claude will handle the rest and pause for you at the two moments a human is required.

---

## Claude: read this whole file before doing anything. This is your runbook.

You are setting up **live, read-only access to a Google Analytics 4 (GA4) property** for
a **completely non-technical person**. By the end, you will be able to query their GA4
data and tell them what's in it.

**Your job is to do everything yourself** via the terminal (the Bash tool) and by
*creating the helper files described below*. The human cannot read code, cannot use a
terminal, and finds this intimidating. **Never ask them to run a command or edit a
file.** You run the commands. You write the files.

There are **exactly two things only the human can do** (Google will not let any tool do
them). When you reach each one, STOP, give the human a short, plain-English instruction,
and wait. They are clearly marked **🙋 HUMAN STEP** below.

Work through the steps in order. After each command, check the result before moving on.

---

### Ground rules for you (Claude)

- Talk to the human in plain language. No jargon. Never show them raw error text — read
  it yourself, then tell them in one friendly sentence what's happening.
- One question at a time. They are nervous; reassure them.
- The credential file you'll create (`ga4-credentials.json`) is a **live secret**. Never
  print its contents, never commit it, never paste it into chat.
- Everything you set up is **read-only** (a "Viewer"). Reassure the human they cannot
  break or change their analytics with this.
- If a step fails because of a school/work-account policy, see **Step 6 (Troubleshooting)**
  — the fix is almost always "use a personal @gmail.com account."

---

## Step 0 — Confirm prerequisites (you do this silently)

Run these and handle problems yourself:

1. **Node.js** — check with `node --version`. If missing, install it:
   - macOS with Homebrew: `brew install node`
   - macOS without Homebrew: install Homebrew first from https://brew.sh, then the above.
   - Tell the human only: *"Installing a small tool I need — one minute."*

2. **Google Cloud CLI (`gcloud`)** — check with `gcloud --version`. If missing, install:
   - macOS with Homebrew: `brew install --cask google-cloud-sdk`
   - Then load it into the current shell if needed:
     `. "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"` (ignore if not found).
   - If `gcloud` still isn't found, ask the human to fully close and reopen their terminal
     app, then continue.

Don't narrate the technical details. Just get these working.

---

## Step 1 — 🙋 HUMAN STEP: sign in to Google

Run: `gcloud auth login`

This opens the human's web browser. Tell them, in your own words:

> "A Google sign-in page just opened in your browser. Please pick the Google account you
> want to use for your analytics, and click **Allow**. Tell me when you've done it."

Wait for them. After they confirm, run `gcloud config get-value account` to confirm
who's signed in, and tell them which account it is.

**If their email is NOT `@gmail.com`** (looks like a school or company account), warn them
gently now:

> "Heads up — that's a work/school account. Sometimes those are locked down by an admin
> and won't let me finish. If we hit that wall, the easy fix is to redo this with a
> personal @gmail.com account. We'll only worry about it if it happens."

---

## Step 2 — Create their Google Cloud project + service account (you do all of this)

A "service account" is just a robot login that can read their analytics. You'll create
it. Pick a unique project id like `ga4-class-<6 digits>` (e.g. derived from the current
time). Run these in order, and **if any fails, jump to Step 6 and read the matching
case** before telling the human anything:

```bash
# 2a. Create the project (a container for the robot account)
gcloud projects create ga4-class-XXXXXX --name="GA4 Class"
gcloud config set project ga4-class-XXXXXX

# 2b. Turn on the Analytics Data API for this project
gcloud services enable analyticsdata.googleapis.com

# 2c. Create the read-only robot account
gcloud iam service-accounts create ga4-reader --display-name="GA4 read-only reader"

# 2d. Download the robot's key into THIS folder
gcloud iam service-accounts keys create ./ga4-credentials.json \
  --iam-account="ga4-reader@ga4-class-XXXXXX.iam.gserviceaccount.com"
```

Replace `ga4-class-XXXXXX` with the real id you chose, consistently, in all four commands.

After 2d succeeds, run `chmod 600 ./ga4-credentials.json` and tell the human:

> "Done with the technical part — I've created a read-only key that can see your
> analytics. One quick thing I need you to click next."

Keep the robot's email handy (it's `ga4-reader@<your-project-id>.iam.gserviceaccount.com`)
— the human needs to paste it in the next step.

> 💡 You can do Step 2 by hand as above, OR you may use the helper script `setup.sh`
> (in this folder) which runs 2a–2d with friendly error handling. Either is fine. If you
> use it: `bash setup.sh`. Prefer it if present, since its error messages map to Step 6.

---

## Step 3 — 🙋 HUMAN STEP: let the robot read their analytics

Google Analytics has its **own** permission list, separate from everything above. The
robot account must be added to it by hand — no tool can do this. Give the human this,
filling in the real robot email:

> "Last click, I promise. Please:
> 1. Go to **https://analytics.google.com**
> 2. Click **Admin** (the gear icon, bottom-left).
> 3. Under the **Property** column, click **Property Access Management**.
> 4. Click the **+** (top right) → **Add users**.
> 5. Paste in this exact email: **`ga4-reader@<your-project-id>.iam.gserviceaccount.com`**
> 6. Set the role to **Viewer**.
> 7. Uncheck **Notify new users by email** (it's a robot, not a person).
> 8. Click **Add**.
>
> Tell me when that's done."

Wait for confirmation.

---

## Step 4 — 🙋 HUMAN STEP (tiny): get their Property ID

You need the property's numeric ID. Ask:

> "One number I need: in that same **Admin** area, click **Property Settings** (under the
> Property column). Near the top you'll see a **Property ID** — a number like
> `123456789`. Paste that number here for me."

> ⚠️ Make sure it's the **Property ID** (a number), NOT the "Measurement ID" that looks
> like `G-XXXXXXX`. If they paste a `G-...` value, ask again for the numeric one.

Save it. From here on, set it as an environment variable when you run the scripts:
`GA4_PROPERTY_ID=<that number>`.

---

## Step 5 — Create the helper scripts and run discovery (you do this)

If `discover.mjs` and `query.mjs` aren't already in this folder, **create them now** using
the exact code in **SCRIPTS.md** (in this folder). Then run:

```bash
GA4_PROPERTY_ID=<their number> node discover.mjs
```

This prints every **dimension**, **metric**, and recent **event** their property exposes.
Read that output yourself — it's the menu of what you can query. Then summarize it for the
human in plain language: how many things are trackable, and a few interesting examples.

Pull a first real result so they see it working, e.g.:

```bash
GA4_PROPERTY_ID=<their number> node query.mjs '{"dateRanges":[{"startDate":"7daysAgo","endDate":"yesterday"}],"dimensions":[{"name":"eventName"}],"metrics":[{"name":"eventCount"}]}'
```

Then tell them they're done, and that they can now just ask you questions like *"how many
people visited last week?"* and you'll pull the answer.

> If the events list is empty: their property is brand new or has no traffic yet. That's
> normal — reassure them; the schema is still correct and data will appear within ~24h of
> their site getting visitors.

---

## Step 5.5 — Save the setup to your memory (you do this)

So that future sessions can answer the human's data questions without redoing any of
this, **record how to query this property in your persistent memory** (e.g. a project
memory / `CLAUDE.md` entry — whatever memory mechanism you have in this environment).
Save these facts:

- This project has **read-only GA4 access** set up. Credentials are in
  `./ga4-credentials.json` (a live secret — never print, commit, or paste it).
- The **numeric GA4 Property ID** is `<their number>` (from Step 4).
- To query their analytics: run `GA4_PROPERTY_ID=<number> node query.mjs '<runReport JSON>'`
  from this folder. Run `discover.mjs` first to get exact dimension/metric names — don't
  guess them. See `SCRIPTS.md` for the report shape.
- The access is **read-only / Viewer** — you can read their data, never modify it.

Then tell the human, in plain language, that you've remembered their setup so next time
they can just ask a question and you'll pull the answer straight away.

---

## Step 6 — Troubleshooting (read the matching case, then act)

Read the actual error yourself; match it here; tell the human only the friendly version.

| What the error says | What it means | What you do |
|---|---|---|
| `PERMISSION_DENIED` / `violates` / `constraint` on **project create** | Their account (usually work/school) isn't allowed to make projects | Tell them: *"Your account is locked down by its admin. The quick fix is to do this with a personal @gmail.com account — want to switch?"* Then redo from Step 1 signed into Gmail. |
| `disableServiceAccountKeyCreation` / `FAILED_PRECONDITION` on **key download** | Their org blocks downloading robot keys. **Unfixable on that account.** | Same as above — switch to a personal @gmail.com and redo from Step 1. Be kind; it's not their fault. |
| Something about **billing** on **enable API** | Org wants a credit card linked | On a personal Gmail this normally isn't needed — suggest switching accounts. |
| `403` when running `discover.mjs`/`query.mjs` | The GA4 grant (Step 3) didn't take | Recheck Step 3: right property, role = Viewer, exact robot email. It can take a minute to apply — wait and retry once. |
| `Analytics Data API has not been used` | Step 2b didn't run | Run `gcloud services enable analyticsdata.googleapis.com` and retry. |
| `Set GA4_PROPERTY_ID` | You forgot to pass the property id | Re-run the command with `GA4_PROPERTY_ID=<number>` in front. |

---

## What "done" looks like

- `ga4-credentials.json` exists in this folder (a working read-only key).
- `node discover.mjs` prints the property's dimensions/metrics/events.
- You can answer the human's plain-English questions by translating them into
  `query.mjs` reports.
- You saved the setup (property id, credential path, how to query) to your memory
  (Step 5.5), so a future session can answer data questions immediately.

You never asked them to type a command or read code. You paused only at the 🙋 steps.
