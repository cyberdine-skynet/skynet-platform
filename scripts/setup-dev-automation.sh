#!/bin/bash
# Setup Development Automation Workflow
# Sets up automatic error detection and fixing for development
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

set -e

echo "🚀 Setting up development automation workflow..."
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Make all scripts executable
echo "🔑 Making scripts executable..."
find scripts/ -name "*.sh" -exec chmod +x {} \;
echo "   ✅ All scripts are now executable"

# Set up enhanced git hook
echo "🪝 Setting up enhanced git hook..."
if [ -f ".git/hooks/pre-commit" ]; then
    echo "   📦 Backing up existing pre-commit hook..."
    mv .git/hooks/pre-commit .git/hooks/pre-commit.backup.$(date +%s)
fi

cp .git/hooks/pre-commit-enhanced .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "   ✅ Enhanced pre-commit hook installed"

# Test if fswatch is available for file watching
echo "👁️  Checking file watcher dependencies..."
if command -v fswatch >/dev/null 2>&1; then
    echo "   ✅ fswatch is available"
    WATCH_AVAILABLE=true
else
    echo "   ⚠️ fswatch not found"
    if command -v brew >/dev/null 2>&1; then
        echo "   📦 Installing fswatch via brew..."
        brew install fswatch
        WATCH_AVAILABLE=true
        echo "   ✅ fswatch installed"
    else
        echo "   💡 Install fswatch for file watching: brew install fswatch"
        WATCH_AVAILABLE=false
    fi
fi

# Install VS Code extensions if VS Code is available
if command -v code >/dev/null 2>&1; then
    echo "📦 Installing VS Code extensions..."

    # Essential extensions for automation
    EXTENSIONS=(
        "emeraldwalk.runonsave"           # Run commands on file save
        "davidanson.vscode-markdownlint"  # Markdown linting
        "redhat.vscode-yaml"              # YAML support
        "streetsidesoftware.code-spell-checker"  # Spell checking
        "eamodio.gitlens"                 # Git integration
    )

    for ext in "${EXTENSIONS[@]}"; do
        echo "   Installing: $ext"
        code --install-extension "$ext" --force >/dev/null 2>&1 || echo "     ⚠️ Failed to install $ext"
    done
    echo "   ✅ VS Code extensions installation complete"
else
    echo "   ℹ️ VS Code not found, skipping extension installation"
fi

# Test the automation
echo "🧪 Testing automation setup..."
echo "   Running quick validation test..."
if ./scripts/quick-check.sh >/dev/null 2>&1; then
    echo "   ✅ Validation script works"
else
    echo "   ⚠️ Validation found issues (this is normal)"
fi

echo "   Testing auto-fix script..."
# Run auto-fix in test mode
if ./scripts/auto-fix.sh >/dev/null 2>&1; then
    echo "   ✅ Auto-fix script works"
else
    echo "   ❌ Auto-fix script failed"
fi

echo ""
echo "🎉 Development automation setup complete!"
echo ""
echo "📋 Available automation modes:"
echo ""
echo "   🔧 Manual Commands:"
echo "      ./scripts/dev-auto.sh fix         # Fix issues now"
echo "      ./scripts/dev-auto.sh check       # Check for issues"
echo "      ./scripts/dev-auto.sh validate    # Check then fix if needed"
echo ""
echo "   🚀 Development Modes:"
if [ "$WATCH_AVAILABLE" = true ]; then
echo "      ./scripts/dev-auto.sh watch       # Watch files and auto-fix"
echo "      ./scripts/dev-auto.sh continuous  # Continuous validation loop"
fi
echo "      ./scripts/dev-auto.sh commit 'msg' # Smart commit with auto-fix"
echo ""
echo "   🎯 VS Code Integration:"
echo "      - Files auto-fix on save (if Run On Save extension installed)"
echo "      - Tasks available: Ctrl+Shift+P → 'Tasks: Run Task'"
echo "      - Real-time linting and validation"
echo ""
echo "   🪝 Git Integration:"
echo "      - Pre-commit hook runs auto-fix automatically"
echo "      - Smart commit script handles validation + fixing"
echo ""
echo "💡 Quick Start:"
echo "   1. Open project in VS Code"
echo "   2. Make changes to .md/.yml/.yaml files"
echo "   3. Files will auto-fix on save"
echo "   4. Use git commit normally (auto-fix runs automatically)"
echo ""
echo "🔄 For continuous development:"
if [ "$WATCH_AVAILABLE" = true ]; then
echo "   ./scripts/dev-auto.sh watch"
echo "   (Runs in background, auto-fixes when files change)"
else
echo "   Install fswatch first: brew install fswatch"
echo "   Then run: ./scripts/dev-auto.sh watch"
fi
