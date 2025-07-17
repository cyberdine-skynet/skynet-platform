#!/bin/bash
# Quick development quality checks
# Run this before committing to catch issues early

set -e

echo "🔍 Running quick development checks..."

# Check only staged files for speed
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    echo "ℹ️  No staged files to check"
    exit 0
fi

echo "📁 Checking staged files:"
echo "${STAGED_FILES//\n/\n  - }"

# Quick YAML check on staged files
echo ""
echo "🔧 YAML validation..."
for file in $STAGED_FILES; do
    if [[ $file == *.yml || $file == *.yaml ]]; then
        if command -v yamllint >/dev/null 2>&1; then
            yamllint "$file" || echo "❌ YAML issues in $file"
        else
            echo "⚠️  yamllint not installed, skipping YAML check"
            break
        fi
    fi
done

# Quick markdown check on staged files
echo ""
echo "📝 Markdown validation..."
for file in $STAGED_FILES; do
    if [[ $file == *.md ]]; then
        # Check line length manually (faster than markdownlint)
        long_lines=$(awk 'length($0) > 120 {print NR ": " substr($0, 1, 140)}' "$file")
        if [ -n "$long_lines" ]; then
            echo "❌ Long lines in $file:"
            echo "$long_lines"
        fi
    fi
done

# Check for secrets in staged files
echo ""
echo "🔐 Secret detection..."
for file in $STAGED_FILES; do
    # Simple secret detection
    if grep -i "password\|secret\|key\|token" "$file" | grep -v "pragma: allowlist secret" >/dev/null 2>&1; then
        echo "⚠️  Potential secrets in $file (add '# pragma: allowlist secret' if false positive)"
    fi
done

echo ""
echo "✅ Quick checks complete! Run 'pre-commit run --files $STAGED_FILES' for full validation."
