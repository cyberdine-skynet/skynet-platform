#!/bin/bash
# Lightning Fast Smart Commit
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

COMMIT_MSG="$1"

if [ -z "$COMMIT_MSG" ]; then
    echo "❌ Usage: $0 'commit message'"
    exit 1
fi

echo "⚡ Lightning smart commit..."

# 1. Fast fix staged files only (0.1s)
./scripts/fast-fix.sh staged

# 2. Add any newly fixed files
git add -u

# 3. Commit (fast hook will run)
git commit -m "$COMMIT_MSG

Co-authored-by: francesco2323 <f.emanuele@outlook.com>"

echo "✅ Commit complete!"
