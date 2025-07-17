#!/bin/bash

# Smart YAML Pre-commit Hook
# Auto-fixes YAML issues before commit

set -e

echo "🔧 Smart YAML validation and auto-fix..."

# Run YAML fixer first
./scripts/yaml-fix.sh

# Run yamllint with auto-fix if available
if command -v yamllint &> /dev/null; then
    echo "🔍 Running yamllint validation..."
    
    # Find changed YAML files
    CHANGED_YAML=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(yaml|yml)$' || true)
    
    if [ -n "$CHANGED_YAML" ]; then
        echo "📁 Validating changed YAML files:"
        echo "$CHANGED_YAML" | sed 's/^/  - /'
        
        for file in $CHANGED_YAML; do
            if [ -f "$file" ]; then
                yamllint "$file" || {
                    echo "⚠️ YAML issues found in $file, attempting auto-fix..."
                    # Try prettier if available
                    if command -v prettier &> /dev/null; then
                        prettier --write "$file" 2>/dev/null || echo "⚠️ Prettier failed"
                    fi
                    # Re-run our fixer
                    ./scripts/yaml-fix.sh
                }
            fi
        done
    else
        echo "ℹ️ No YAML files changed"
    fi
else
    echo "⚠️ yamllint not available, skipping validation"
fi

echo "✅ Smart YAML hook complete!"
