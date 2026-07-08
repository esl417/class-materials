# Fewer "Approve?" Clicks 👋

When Claude Code works, it asks your permission before running commands. That's a good
safety feature — but it asks about a lot of totally harmless stuff (listing files,
installing packages, saving a git checkpoint), and all that clicking slows you down.

This kit gives Claude a pre-approved list of the **safe, everyday commands** we use in
class, so it stops asking about those. Anything risky — deleting files, pushing to the
internet, deploying — will **still ask you first**. That's on purpose.

## What to do

1. Open **Claude Code** in any project folder (your class folder is fine).
2. Copy/paste this one message to Claude:

   > **"Grab the permissions kit from https://github.com/esl417/class-materials (the files
   > in `claude-permissions-kit`), then read PERMISSIONS_SETUP_FOR_CLAUDE.md and do what
   > it says for me. I'm not technical — handle it yourself and tell me when it's done."**

3. That's it. Takes under a minute. It works in **every** project from now on, not just
   this folder.

## What this does / doesn't do

- ✅ Auto-approves boring, safe commands: looking at files, creating folders, installing
  packages, running your site locally, saving git checkpoints on your own computer.
- ✅ Keeps a backup of your old settings, in case you ever want to undo it.
- ❌ Does **not** auto-approve anything that deletes files, changes things outside your
  project, or publishes anything to the internet. Claude still asks you for those.

---

*(PERMISSIONS_SETUP_FOR_CLAUDE.md is for Claude to read. You don't need to open it.)*
