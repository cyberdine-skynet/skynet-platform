#!/bin/bash
# Auto-fix Common Issues Script
# Automatically fix common formatting issues

set -e

echo "🔧 Auto-fixing common code quality issues..."

# Fix trailing whitespace
echo "✂️  Removing trailing whitespace..."
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" -exec sed -i '' 's/[[:space:]]*$//' {} \;

# Fix missing final newlines
echo "📝 Adding final newlines..."
find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -not -path "./terraform/.terraform/*" -exec sh -c 'if [ "$(tail -c1 "$1")" != "" ]; then echo "" >> "$1"; fi' _ {} \;

# Fix YAML indentation (basic)
echo "📐 Checking YAML indentation..."
find . -name "*.yml" -o -name "*.yaml" | grep -v ".terraform" | while read -r file; do
    # Convert tabs to spaces
    sed -i '' 's/\t/  /g' "$file"
done

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
echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run quick check: ./scripts/quick-check.sh"
echo "   3. Commit changes: git add . && git commit"
