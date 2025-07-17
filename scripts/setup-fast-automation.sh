#!/bin/bash
# Setup Lightning Fast Development Automation
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

echo "⚡ Setting up lightning-fast development automation..."

# Make scripts executable
chmod +x scripts/fast-fix.sh scripts/fast-commit.sh

# Install the fast pre-commit hook
cp .git/hooks/pre-commit-fast .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Fast automation setup complete!"
echo ""
echo "🚀 Usage (all operations < 1 second):"
echo ""
echo "   # Fix issues in staged files"
echo "   ./scripts/fast-fix.sh staged"
echo ""
echo "   # Fix issues in modified files"  
echo "   ./scripts/fast-fix.sh modified"
echo ""
echo "   # Smart commit with auto-fix"
echo "   ./scripts/fast-commit.sh 'your commit message'"
echo ""
echo "   # Normal git commit (auto-fix runs in hook)"
echo "   git commit -m 'your message'"
echo ""
echo "⚡ All operations optimized for speed:"
echo "   - Only processes relevant files"
echo "   - Fixes common issues automatically"
echo "   - Pre-commit hook runs in <0.5s"
echo "   - Total commit time < 1s"
