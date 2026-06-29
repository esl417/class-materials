#!/usr/bin/env bash
# setup.sh — one-command GA4 read access for a student.
#
# Creates (on the student's OWN Google account): a Cloud project, enables the GA4
# Data API, makes a service account, downloads its key to ./ga4-credentials.json,
# and prints the email + the exact GA4 grant instruction.
#
# It does NOT silently fail. Every step that an org policy can block is checked, and
# on failure you get a plain-English reason + what to do instead (almost always:
# "this account is locked down, use a personal Gmail").
#
# Prereqs: gcloud CLI installed (https://cloud.google.com/sdk/docs/install).
# Run:  bash setup.sh

set -uo pipefail

say()  { printf "\n\033[1m%s\033[0m\n" "$*"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$*"; }
warn() { printf "  \033[33m!\033[0m %s\n" "$*"; }
die()  { printf "\n  \033[31m✗ %s\033[0m\n" "$*" >&2; [ -n "${1:-}" ] && shift; for l in "$@"; do printf "    %s\n" "$l" >&2; done; exit 1; }

# A short, unique-ish project id derived from the current epoch (last 6 digits).
EPOCH=$(date +%s)
SUFFIX=$(printf '%s' "$EPOCH" | tail -c 6)
PROJECT_ID="ga4-class-${SUFFIX}"
SA_NAME="ga4-reader"
KEY_FILE="./ga4-credentials.json"

# -- 0. gcloud present (auto-install on macOS) & logged in ------------
if ! command -v gcloud >/dev/null; then
  say "Google Cloud CLI not found - installing it for you..."
  if command -v brew >/dev/null; then
    brew install --cask google-cloud-sdk 2>/tmp/ga4err || die "" \
      "Homebrew couldn't install the Google Cloud CLI:" "$(cat /tmp/ga4err)" \
      "Install it manually once: https://cloud.google.com/sdk/docs/install"
    # Make gcloud visible in this shell after a cask install.
    for p in "/opt/homebrew/share/google-cloud-sdk/path.bash.inc" \
             "/usr/local/share/google-cloud-sdk/path.bash.inc"; do
      [ -f "$p" ] && . "$p"
    done
  else
    die "" "The Google Cloud CLI isn't installed and Homebrew isn't available to install it." \
      "Easiest fix: install Homebrew (https://brew.sh), then re-run this." \
      "Or install the CLI directly: https://cloud.google.com/sdk/docs/install"
  fi
  command -v gcloud >/dev/null || die "" \
    "Installed the SDK but 'gcloud' still isn't on PATH in this shell." \
    "Close and reopen the terminal, then re-run this script."
  ok "Google Cloud CLI installed"
fi

ACCOUNT=$(gcloud config get-value account 2>/dev/null)
if [ -z "$ACCOUNT" ] || [ "$ACCOUNT" = "(unset)" ]; then
  say "Logging you into Google (a browser will open)..."
  gcloud auth login || die "" "Login failed. Re-run and complete the browser step."
  ACCOUNT=$(gcloud config get-value account 2>/dev/null)
fi
ok "Signed in as $ACCOUNT"

# Flag the Workspace risk early so the student isn't surprised later.
case "$ACCOUNT" in
  *@gmail.com) ok "Personal Gmail — service-account keys are normally allowed." ;;
  *) warn "This looks like a Workspace/org account ($ACCOUNT)."
     warn "Many orgs BLOCK project or key creation. If a step below fails with a"
     warn "policy error, switch to a personal @gmail.com account and re-run." ;;
esac

# -- 1. Create the project --------------------------------------------
say "1/5  Creating project $PROJECT_ID..."
if ! gcloud projects create "$PROJECT_ID" --name="GA4 Class" 2>/tmp/ga4err; then
  ERR=$(cat /tmp/ga4err)
  case "$ERR" in
    *PERMISSION_DENIED*|*violates*|*constraint*|*policy*)
      die "" "Your account is not allowed to create Cloud projects." \
        "This is an org policy on a Workspace/school account." \
        "Fix: run this with a personal @gmail.com account instead." ;;
    *already*exists*|*ALREADY_EXISTS*) warn "Project name taken — retrying with a new id..."
      PROJECT_ID="ga4-class-$(($EPOCH % 1000000 + 1))"
      gcloud projects create "$PROJECT_ID" --name="GA4 Class" 2>/tmp/ga4err \
        || die "" "Could not create a project. See: $(cat /tmp/ga4err)" ;;
    *) die "" "Project creation failed:" "$ERR" ;;
  esac
fi
gcloud config set project "$PROJECT_ID" >/dev/null 2>&1
ok "Project $PROJECT_ID created and selected"

# -- 2. Enable the GA4 Data API ---------------------------------------
# Note: enabling an API can require billing on SOME orgs, but the Analytics Data
# API itself has a free quota and normally enables without a card.
say "2/5  Enabling the Google Analytics Data API..."
if ! gcloud services enable analyticsdata.googleapis.com 2>/tmp/ga4err; then
  ERR=$(cat /tmp/ga4err)
  case "$ERR" in
    *billing*) die "" "Enabling the API wants a billing account on this org." \
      "On a personal Gmail this usually isn't required — try a personal account." \
      "Otherwise link a billing account (free tier) in the Cloud Console." ;;
    *) die "" "Could not enable the API:" "$ERR" ;;
  esac
fi
ok "analyticsdata.googleapis.com enabled"

# -- 3. Create the service account ------------------------------------
say "3/5  Creating the service account..."
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud iam service-accounts create "$SA_NAME" \
  --display-name="GA4 read-only reader" 2>/tmp/ga4err \
  || die "" "Service-account creation failed:" "$(cat /tmp/ga4err)"
ok "Service account: $SA_EMAIL"

# -- 4. Download a key (THE step orgs most often block) ---------------
say "4/5  Downloading the key to $KEY_FILE..."
if ! gcloud iam service-accounts keys create "$KEY_FILE" \
      --iam-account="$SA_EMAIL" 2>/tmp/ga4err; then
  ERR=$(cat /tmp/ga4err)
  case "$ERR" in
    *disableServiceAccountKeyCreation*|*constraints/iam*|*FAILED_PRECONDITION*|*violates*)
      die "" "Your org BLOCKS downloading service-account keys." \
        "(policy: iam.disableServiceAccountKeyCreation — common on schools/Workspace)" \
        "There is no way around this on this account." \
        "Fix: re-run with a personal @gmail.com account." ;;
    *) die "" "Key creation failed:" "$ERR" ;;
  esac
fi
chmod 600 "$KEY_FILE"
ok "Key saved to $KEY_FILE (gitignored — never commit it)"

# -- 5. Tell the student the ONE manual step left ---------------------
say "5/5  Done with automation. One manual step left — grant this email in GA4:"
cat <<EOF

  Copy this service-account email:

      $SA_EMAIL

  Then in Google Analytics:
    Admin → Property Access Management → '+' → Add users
    → paste the email → role 'Viewer' → uncheck 'Notify by email' → Add

  Finally set your property id and run discovery:

      export GA4_PROPERTY_ID=<your numeric property id>   # Admin → Property Settings
      node discover.mjs

EOF
ok "Setup complete for $ACCOUNT"
