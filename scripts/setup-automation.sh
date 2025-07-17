#!/bin/bash
# Setup automated code quality system
# Run this once to set up all automation

echo "🚀 Setting up automated code quality system..."

# Enable the auto-fix pre-commit hook
echo "🔧 Setting up auto-fix git hook..."
if [ -f ".git/hooks/pre-commit-auto" ]; then
    # Backup existing pre-commit hook if it exists
    if [ -f ".git/hooks/pre-commit" ]; then
        echo "   Backing up existing pre-commit hook..."
        mv .git/hooks/pre-commit .git/hooks/pre-commit.backup
    fi

    # Link the auto-fix hook
    ln -sf "$(pwd)/.git/hooks/pre-commit-auto" .git/hooks/pre-commit
    echo "   ✅ Auto-fix pre-commit hook enabled"
else
    echo "   ❌ Auto-fix hook not found"
fi

# Install VS Code extensions if VS Code is available
if command -v code >/dev/null 2>&1; then
    echo "📦 Installing recommended VS Code extensions..."

    # Read extensions from .vscode/extensions.json
    if [ -f ".vscode/extensions.json" ]; then
        # Extract extension IDs and install them
        grep '"' .vscode/extensions.json | grep -E '^\s*"[^"]+/[^"]+",?\s*$' | sed 's/.*"\([^"]*\)".*/\1/' | while read -r ext; do
            if [ -n "$ext" ]; then
                echo "   Installing: $ext"
                code --install-extension "$ext" --force 2>/dev/null || echo "     ⚠️ Failed to install $ext"
            fi
        done
        echo "   ✅ VS Code extensions installation attempted"
    fi
else
    echo "   ℹ️ VS Code not found, skipping extension installation"
fi

# Set up fast pre-commit for development
echo "⚡ Setting up fast pre-commit for development..."
if [ -f ".pre-commit-config-fast.yaml" ]; then
    # Install fast config as alternative
    pre-commit install --config .pre-commit-config-fast.yaml --hook-type pre-commit --install-hooks 2>/dev/null || true
    echo "   ✅ Fast pre-commit config available"
    echo "   💡 Use: pre-commit install --config .pre-commit-config-fast.yaml"
fi

# Make all scripts executable
echo "🔑 Making scripts executable..."
chmod +x scripts/*.sh 2>/dev/null || true
echo "   ✅ Scripts are now executable"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Available automation:"
echo ""
echo "   🔧 Auto-fix issues:"
echo "      ./scripts/auto-fix.sh"
echo ""
echo "   ⚡ Quick validation:"
echo "      ./scripts/quick-check.sh"
echo ""
echo "   🚀 Smart commit (auto-fixes on errors):"
echo "      ./scripts/smart-commit.sh 'commit message'"
echo ""
echo "   🎯 VS Code tasks (Ctrl+Shift+P → Tasks):"
echo "      - Auto-fix Code Quality"
echo "      - Quick Quality Check"
echo "      - Smart Commit"
echo ""
echo "💡 The system will now automatically:"
echo "   ✅ Fix common issues during git commit"
echo "   ✅ Show real-time validation in VS Code"
echo "   ✅ Provide quick manual fix commands"
echo ""
echo "🚀 Try it: ./scripts/smart-commit.sh 'test: automated quality system'"
