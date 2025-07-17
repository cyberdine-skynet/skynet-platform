#!/bin/bash

# 🔧 Proactive YAML Auto-Fixer
# Automatically fixes common YAML issues before they become problems

set -e

echo "🔧 Running proactive YAML fixes..."

# Find all YAML files
YAML_FILES=$(find . -name "*.yml" -o -name "*.yaml" | grep -v node_modules | grep -v .git | grep -v venv)

if [ -z "$YAML_FILES" ]; then
    echo "ℹ️ No YAML files found to fix"
    exit 0
fi

echo "📁 Found YAML files to process:"
echo "$YAML_FILES" | sed 's/^/  - /'

# Process each YAML file
for file in $YAML_FILES; do
    echo "🔧 Processing: $file"
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Fix common indentation issues
    if command -v yq &> /dev/null; then
        # Use yq to reformat (this ensures proper YAML structure)
        yq eval '.' "$file" > "$file.tmp" 2>/dev/null && mv "$file.tmp" "$file" || {
            echo "⚠️ yq failed for $file, trying manual fixes..."
            mv "$file.backup" "$file"
        }
    fi
    
    # Manual fixes for common issues
    python3 -c "
import sys
import re

with open('$file', 'r') as f:
    content = f.read()

# Fix common indentation issues
lines = content.split('\n')
fixed_lines = []

for line in lines:
    # Fix repos: section indentation
    if line.strip().startswith('- repo:') and not line.startswith('  '):
        line = '  ' + line.strip()
    elif line.strip().startswith('rev:') and not line.startswith('    '):
        line = '    ' + line.strip()
    elif line.strip().startswith('hooks:') and not line.startswith('    '):
        line = '    ' + line.strip()
    elif line.strip().startswith('- id:') and not line.startswith('      '):
        line = '      ' + line.strip()
    elif line.strip().startswith('args:') and not line.startswith('        '):
        line = '        ' + line.strip()
    
    fixed_lines.append(line)

# Write back
with open('$file', 'w') as f:
    f.write('\n'.join(fixed_lines))
" 2>/dev/null || echo "⚠️ Python fix failed for $file"
    
    # Validate the fix
    if command -v yamllint &> /dev/null; then
        if yamllint "$file" 2>/dev/null; then
            echo "✅ $file is now valid"
            rm "$file.backup"
        else
            echo "❌ $file still has issues, reverting..."
            mv "$file.backup" "$file"
        fi
    else
        # Try python yaml validation
        python3 -c "
import yaml
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✅ $file is valid YAML')
except Exception as e:
    print(f'❌ $file has YAML errors: {e}')
    exit(1)
" && rm "$file.backup" || mv "$file.backup" "$file"
    fi
done

echo "✅ YAML auto-fix complete!"
