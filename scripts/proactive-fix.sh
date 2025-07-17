#!/bin/bash

# 🚀 Proactive Code Quality Fixer
# Prevents issues before they happen

set -e

echo "🚀 Running proactive fixes..."

# 1. Fix YAML issues
echo "🔧 Fixing YAML syntax..."
./scripts/yaml-fix.sh

# 2. Fix common file issues
echo "🔧 Fixing common file issues..."
./scripts/auto-fix.sh

# 3. Format with prettier if available
if command -v prettier &> /dev/null; then
    echo "💅 Running Prettier formatting..."
    prettier --write "**/*.{yml,yaml,json,md}" --ignore-path .gitignore 2>/dev/null || echo "⚠️ Some files couldn't be formatted"
fi

# 4. Run quick validation
echo "🔍 Running quick validation..."
./scripts/quick-check.sh || echo "⚠️ Some issues remain - check output above"

echo "✅ Proactive fixes complete!"
echo "💡 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Test: git add . && git commit --dry-run"
echo "   3. Commit: ./scripts/smart-commit.sh 'your message'"
