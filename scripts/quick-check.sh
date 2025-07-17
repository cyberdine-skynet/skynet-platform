#!/bin/bash
# Quick Code Quality Check Script
# Run this before committing to catch issues early

set -e

echo "🚀 Running quick code quality checks..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Basic file checks (fast)
echo "📁 Checking for basic file issues..."
find . \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -print0 | xargs -0 grep -l $'\t' && echo "❌ Found tabs, please use spaces" || echo "✅ No tabs found"

# Line length check (fast)
echo "📏 Checking line lengths..."
LONG_LINES=$(find . -name "*.md" -not -path "./terraform/.terraform/*" -exec awk 'length($0) > 120 {print FILENAME ":" NR ": (length " length($0) ")"}' {} \; | head -5)
if [ -n "$LONG_LINES" ]; then
    echo "❌ Found lines longer than 120 characters:"
    echo "$LONG_LINES"
    echo "   (showing first 5, fix these and run again)"
else
    echo "✅ All lines under 120 characters"
fi

# YAML syntax check (fast)
if command_exists yamllint; then
    echo "📄 Checking YAML syntax..."
    if yamllint --config-file .yamllint.yml -f parsable . 2>/dev/null | head -5; then
        echo "❌ YAML issues found (showing first 5)"
    else
        echo "✅ YAML syntax clean"
    fi
else
    echo "⚠️  yamllint not installed, skipping YAML checks"
fi

# Secrets check (critical)
if command_exists detect-secrets; then
    echo "🔐 Checking for secrets..."
    if detect-secrets scan --baseline .secrets.baseline --quiet; then
        echo "✅ No new secrets detected"
    else
        echo "❌ Potential secrets found! Review carefully."
    fi
else
    echo "⚠️  detect-secrets not installed, skipping secrets check"
fi

echo "✨ Quick check complete!"
echo ""
echo "💡 Tips:"
echo "   - Install extensions: code --install-extension davidanson.vscode-markdownlint"
echo "   - Use fast pre-commit: pre-commit install --config .pre-commit-config-fast.yaml"
echo "   - Run full check: ./scripts/full-quality-check.sh"
