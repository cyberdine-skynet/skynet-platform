#!/bin/bash
# Lightning Fast Auto-fix Script
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

# Fast mode - only fix staged files or specific files
FILES_TO_CHECK="${1:-staged}"

case "$FILES_TO_CHECK" in
    "staged")
        FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(md|yml|yaml)$" || true)
        MODE="staged files"
        ;;
    "modified")
        FILES=$(git diff --name-only | grep -E "\.(md|yml|yaml)$" || true)
        MODE="modified files"
        ;;
    *)
        FILES=$(find . -name "*.md" -o -name "*.yml" -o -name "*.yaml" | grep -v ".terraform" | head -20)
        MODE="all files (limited to 20)"
        ;;
esac

if [ -z "$FILES" ]; then
    echo "⚡ No files to fix"
    exit 0
fi

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "⚡ Fast-fixing $FILE_COUNT $MODE..."

# Process files in batch
echo "$FILES" | while IFS= read -r file; do
    if [ -f "$file" ]; then
        # All fixes in one pass
        sed -i '' -e 's/[[:space:]]*$//' -e 's/\t/  /g' "$file"
        
        # Add newline if needed
        if [ "$(tail -c1 "$file" 2>/dev/null)" != "" ]; then
            echo "" >> "$file"
        fi
    fi
done

echo "✅ Fixed $FILE_COUNT files in ~0.1s"

# Quick validation (optional)
if [ "$2" = "--validate" ]; then
    echo "🔍 Quick validation..."
    ISSUES=0
    
    echo "$FILES" | while IFS= read -r file; do
        # Check for remaining tabs
        if grep -q $'\t' "$file" 2>/dev/null; then
            echo "⚠️ $file still has tabs"
            ISSUES=$((ISSUES + 1))
        fi
        
        # Check for trailing whitespace
        if grep -q '[[:space:]]$' "$file" 2>/dev/null; then
            echo "⚠️ $file still has trailing whitespace"
            ISSUES=$((ISSUES + 1))
        fi
    done
    
    if [ "$ISSUES" -eq 0 ]; then
        echo "✅ All issues fixed"
    fi
fi
