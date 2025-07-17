#!/bin/bash
# Auto-fix Common Issues Script
# Automatically fix common formatting issues

set -e

echo "🔧 Auto-fixing common code quality issues..."

# Count initial issues
INITIAL_ISSUES=0

# Fix trailing whitespace
echo "✂️  Removing trailing whitespace..."
WHITESPACE_FILES=$(find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" -exec grep -l '[[:space:]]$' {} \; 2>/dev/null | wc -l)
if [ "$WHITESPACE_FILES" -gt 0 ]; then
    echo "   Found $WHITESPACE_FILES files with trailing whitespace"
    INITIAL_ISSUES=$((INITIAL_ISSUES + WHITESPACE_FILES))
fi
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" -exec sed -i '' 's/[[:space:]]*$//' {} \;

# Fix missing final newlines
echo "📝 Adding final newlines..."
NEWLINE_COUNT=0
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" -exec sh -c '
    if [ "$(tail -c1 "$1" 2>/dev/null)" != "" ]; then
        echo "" >> "$1"
        echo "   Fixed: $1"
    fi
' _ {} \;

# Fix YAML indentation (basic)
echo "📐 Fixing YAML indentation..."
YAML_FIXED=0
find . \( -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" | while read -r file; do
    # Convert tabs to spaces
    if grep -q $'\t' "$file" 2>/dev/null; then
        sed -i '' 's/\t/  /g' "$file"
        echo "   Fixed tabs in: $file"
        YAML_FIXED=$((YAML_FIXED + 1))
    fi
done

# Fix common YAML patterns
echo "🔧 Fixing common YAML issues..."
find . \( -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" | while read -r file; do
    # Fix common indentation issues in lists
    if grep -q '^  - ' "$file" 2>/dev/null; then
        # Check if this is under a key that should be 4-space indented
        sed -i '' 's/^  - /    - /g' "$file" 2>/dev/null || true
    fi
done

# Smart markdown line splitting (for very long lines)
echo "📏 Checking for very long lines (>150 chars)..."
VERY_LONG_FILES=$(find . -name "*.md" -not -path "./terraform/.terraform/*" -exec awk 'length($0) > 150 {print FILENAME; exit}' {} \; 2>/dev/null)

if [ -n "$VERY_LONG_FILES" ]; then
    echo "🔧 Attempting to split very long lines..."
    echo "$VERY_LONG_FILES" | while read -r file; do
        # Basic line splitting for common patterns
        sed -i '' 's/\. /.\n/g; s/, and /, and\n/g' "$file" 2>/dev/null || true
        echo "   Processed: $file"
    done
fi

# Split long lines in markdown (interactive)
echo "📏 Checking for long lines..."
LONG_FILES=$(find . -name "*.md" -not -path "./terraform/.terraform/*" -exec awk 'length($0) > 120 {print FILENAME; exit}' {} \;)

if [ -n "$LONG_FILES" ]; then
    echo "❌ Files with long lines found:"
    echo "$LONG_FILES"
    echo ""
    echo "💡 Consider manually splitting these lines or using your editor's word wrap"
    echo "   VS Code: Alt+Z toggles word wrap"
    echo "   Rule: Aim for 120 characters per line"
fi

echo "✨ Auto-fix complete!"

# Show summary
echo ""
echo "📊 Summary:"
if [ "$INITIAL_ISSUES" -gt 0 ]; then
    echo "   ✅ Fixed $INITIAL_ISSUES+ issues automatically"
else
    echo "   ✅ No issues found to fix"
fi

# Check remaining issues
REMAINING_LONG_LINES=$(find . -name "*.md" -not -path "./terraform/.terraform/*" -exec awk 'length($0) > 120 {print FILENAME; exit}' {} \; 2>/dev/null | wc -l)
if [ "$REMAINING_LONG_LINES" -gt 0 ]; then
    echo "   ⚠️  $REMAINING_LONG_LINES files still have long lines (>120 chars)"
    echo "      These may need manual splitting"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run validation: ./scripts/quick-check.sh"
echo "   3. Commit: ./scripts/smart-commit.sh 'your message'"
echo ""
echo "💡 VS Code shortcuts:"
echo "   - Ctrl+Shift+P → 'Tasks: Run Task' → 'Auto-fix Code Quality'"
echo "   - Ctrl+Shift+P → 'Tasks: Run Task' → 'Smart Commit'"
