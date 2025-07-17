#!/bin/bash
# File Watcher with Auto-fix
# Automatically runs auto-fix when relevant files are modified
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

set -e

echo "👁️  Starting file watcher with auto-fix..."
echo "📁 Watching: *.md, *.yml, *.yaml files"
echo "🔧 Will auto-fix on changes"
echo "   Press Ctrl+C to stop"
echo ""

# Check if fswatch is available
if ! command -v fswatch >/dev/null 2>&1; then
    echo "⚠️  fswatch not found. Installing via brew..."
    if command -v brew >/dev/null 2>&1; then
        brew install fswatch
    else
        echo "❌ Please install fswatch manually:"
        echo "   brew install fswatch"
        echo "   or"
        echo "   https://github.com/emcrisostomo/fswatch"
        exit 1
    fi
fi

# Track last run to avoid rapid successive runs
LAST_RUN=0
COOLDOWN=2  # seconds

run_autofix() {
    local current_time=$(date +%s)
    local time_diff=$((current_time - LAST_RUN))

    if [ $time_diff -ge $COOLDOWN ]; then
        echo "🔧 $(date '+%H:%M:%S') - Files changed, running auto-fix..."
        ./scripts/auto-fix.sh
        LAST_RUN=$current_time
        echo "✨ Auto-fix complete"
        echo ""
    fi
}

# Watch for changes in markdown and YAML files
fswatch \
    --recursive \
    --one-per-batch \
    --event=Updated \
    --exclude='\.git/' \
    --exclude='node_modules/' \
    --exclude='\.terraform/' \
    --exclude='\.vscode/' \
    --include='.*\.(md|yml|yaml)$' \
    . | while read -r changed_file; do
    run_autofix
done
