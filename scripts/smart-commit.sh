#!/bin/bash
# Smart commit script with automatic error fixing
# Usage: ./scripts/smart-commit.sh "your commit message"

set -e

COMMIT_MSG="$1"

if [ -z "$COMMIT_MSG" ]; then
    echo "❌ Usage: $0 'commit message'"
    echo "   Example: $0 'fix: update documentation'"
    exit 1
fi

echo "🚀 Smart commit starting..."
echo "📝 Commit message: $COMMIT_MSG"
echo ""

# Stage all changes
echo "📁 Staging changes..."
git add .

# Check if there are staged changes
if ! git diff --cached --quiet; then
    echo "✅ Found changes to commit"
else
    echo "ℹ️  No changes to commit"
    exit 0
fi

echo ""
echo "🔍 Running validation checks..."

# Run quick validation first
if ./scripts/quick-check.sh; then
    echo ""
    echo "✅ Quick validation passed"
else
    echo ""
    echo "⚠️  Quick validation found issues. Running auto-fix..."

    # Run auto-fix
    ./scripts/auto-fix.sh

    # Re-stage after auto-fix
    git add .

    echo ""
    echo "🔄 Re-running quick validation..."
    if ./scripts/quick-check.sh; then
        echo "✅ Auto-fix successful!"
    else
        echo "⚠️  Some issues require manual attention"
    fi
fi

echo ""
echo "🔍 Running pre-commit hooks..."

# Try pre-commit
if pre-commit run; then
    echo ""
    echo "✅ All pre-commit checks passed"

    # Commit the changes
    git commit -m "$COMMIT_MSG"

    echo ""
    echo "🎉 Commit successful!"
    echo "💡 Next: git push origin $(git branch --show-current)"

else
    echo ""
    echo "❌ Pre-commit failed. Running comprehensive auto-fix..."

    # Run auto-fix again (more comprehensive)
    ./scripts/auto-fix.sh

    # Re-stage
    git add .

    echo ""
    echo "🔄 Retrying pre-commit..."

    if pre-commit run; then
        echo ""
        echo "✅ Auto-fix resolved the issues!"

        # Commit the changes
        git commit -m "$COMMIT_MSG"

        echo ""
        echo "🎉 Commit successful after auto-fix!"
        echo "💡 Next: git push origin $(git branch --show-current)"

    else
        echo ""
        echo "⚠️  Manual intervention required:"
        echo ""
        echo "🔧 Remaining issues to fix manually:"
        echo "   1. Check the errors above"
        echo "   2. Fix long lines (>120 chars) by splitting them"
        echo "   3. Fix any YAML syntax errors"
        echo "   4. Add 'pragma: allowlist secret' for false positives"
        echo ""
        echo "📋 Then run:"
        echo "   git add ."
        echo "   git commit -m \"$COMMIT_MSG\""
        echo ""
        exit 1
    fi
fi
