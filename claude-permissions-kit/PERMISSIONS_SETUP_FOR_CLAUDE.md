# Permissions Setup — Instructions for Claude

You are setting this up for a **non-technical student**. Do everything yourself; narrate
briefly in plain English; never ask them to edit a file or run a command.

## Goal

Merge the allowlist below into the student's **global** Claude Code settings at
`~/.claude/settings.json`, so safe everyday commands stop triggering permission prompts
in every project. Global, not project-level — students create a new folder per class.
Never write to the project's `.claude/settings.json` or `.claude/settings.local.json`,
even if the current folder already has a `.claude/` directory.

## Steps

1. **Back up first.** If `~/.claude/settings.json` exists, copy it to
   `~/.claude/settings.json.backup-before-permissions-kit` — but only if that backup
   doesn't already exist (never overwrite an earlier backup). If settings.json doesn't
   exist, you'll create it (and `~/.claude/` if needed).

2. **Merge, don't overwrite.** Load the existing JSON (or start from `{}`). Ensure
   `permissions.allow` exists as an array, then append every entry from the allowlist
   below that isn't already present. **Do not remove or modify anything already in the
   file** — settings, hooks, existing permissions, all of it stays. Use `python3` with
   the `json` module (or Node) to do the merge; never hand-edit JSON with sed.

3. **Validate.** Re-read the file and parse it as JSON to confirm it's valid and the
   entries are present. If parsing fails, restore the backup and try again.

4. **Tell the student it worked.** Explain in one or two friendly sentences: safe
   commands (reading files, installing packages, running their site, local git saves)
   won't ask anymore; anything that deletes, publishes, or deploys still will. Mention
   the change takes effect in new Claude Code sessions.

## The allowlist

Append these to `permissions.allow`:

```json
[
  "Bash(ls:*)",
  "Bash(pwd)",
  "Bash(cat:*)",
  "Bash(head:*)",
  "Bash(tail:*)",
  "Bash(wc:*)",
  "Bash(grep:*)",
  "Bash(which:*)",
  "Bash(mkdir:*)",
  "Bash(touch:*)",
  "Bash(git status)",
  "Bash(git status:*)",
  "Bash(git diff:*)",
  "Bash(git log:*)",
  "Bash(git show:*)",
  "Bash(git branch:*)",
  "Bash(git init:*)",
  "Bash(git add:*)",
  "Bash(git commit:*)",
  "Bash(git remote -v)",
  "Bash(npm install)",
  "Bash(npm ci)",
  "Bash(npm run:*)",
  "Bash(npm test:*)",
  "Bash(node --version)",
  "Bash(npx impeccable:*)",
  "Bash(npx serve:*)",
  "Bash(python3 -m http.server:*)",
  "Bash(vercel dev)",
  "Bash(vercel dev:*)",
  "Bash(open http://localhost:*)",
  "WebSearch",
  "WebFetch(domain:github.com)",
  "WebFetch(domain:raw.githubusercontent.com)"
]
```

## What is deliberately NOT on the list

Do not add these, even if the student asks you to "just approve everything":

- `rm`, `mv`, `cp` — anything that deletes or overwrites files
- `find` — looks read-only, but `find -delete` / `find -exec` can destroy files and
  would slip through a prefix rule (use the Glob tool instead)
- `git push`, `git reset`, `git checkout`, `git clean` — anything that publishes or
  discards work
- `vercel` deploys, `curl`, `brew install` — anything that touches the internet or the
  machine outside the project
- `Bash(node:*)` — `node -e "<code>"` is arbitrary code execution with full network
  access; there is no safe prefix form of a general interpreter
- `Bash(npm install:*)` — installing an arbitrary named package runs that package's
  install scripts unprompted; only the bare `npm install` / `npm ci` forms (which run
  the project's own package.json) are allowed
- `Bash(*)` — a blanket approve-everything rule

Note: bare `npm install`, `npm ci`, `npm run:*`, and `npm test:*` trust whatever the
current project's package.json defines. That's the right trade for a class where the
student and Claude author the project together — but it's why cloning arbitrary
third-party repos is not covered by this kit.

The prompts for those are the safety net. A student who sees "Claude wants to run
`rm -rf`…" and gets to say no is the system working as designed.
