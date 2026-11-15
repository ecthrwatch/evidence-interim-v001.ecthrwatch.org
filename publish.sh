#!/bin/bash
set -euo pipefail

# Work from the folder containing this script.
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ "$(git rev-parse --show-toplevel)" != "$PWD" ]]; then
    echo "Error: publish.sh must be in the repository root." >&2
    exit 1
fi

if [[ "$(git symbolic-ref --quiet --short HEAD)" != "main" ]]; then
    echo "Error: switch to main before publishing." >&2
    exit 1
fi

remote_url=$(git remote get-url --push origin)
message="${1:-Update evidence website $(date -u '+%Y-%m-%d %H:%M:%S UTC')}"

# Remove macOS metadata, leaving Git's internal folder alone.
find . -type d -name .git -prune -o \
    -type f \( -iname '.DS_Store' -o -name '._*' \) \
    -print -exec rm -f -- {} +

# Stage new files, changes, and deletions.
git add -A

if git diff --cached --quiet; then
    echo "No new changes to commit."
else
    git --no-pager diff --cached --stat
    git commit -m "$message"
fi

# Includes existing unpushed commits. Never force-push.
printf 'Pushing main to %s\n' "$remote_url"
git push origin main
