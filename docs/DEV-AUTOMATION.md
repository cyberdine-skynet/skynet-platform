# Development Automation System

> Proactive, automated code quality system that prevents slow, reactive pre-commit cycles

## Overview

This automation system automatically detects and fixes common code quality issues during
development, eliminating the need for slow, manual pre-commit cycles. The system integrates
with VS Code, git hooks, and file watchers to provide seamless error detection and fixing.

## Quick Start

1. **Setup automation (one-time)**:

   ```bash
   ./scripts/setup-dev-automation.sh
   ```

2. **Start development with auto-fix**:

   ```bash
   # Option 1: File watcher (auto-fixes on file changes)
   ./scripts/dev-auto.sh watch

   # Option 2: VS Code (auto-fixes on save)
   # Just open the project in VS Code and edit files

   # Option 3: Manual validation and fixing
   ./scripts/dev-auto.sh validate
   ```

3. **Commit with auto-fix**:

   ```bash
   ./scripts/dev-auto.sh commit "feat: new feature"
   # OR use regular git commit (auto-fix runs via pre-commit hook)
   git commit -m "feat: new feature"
   ```

## Automation Modes

### 1. Real-time Auto-fix (VS Code)

**When**: Files are saved in VS Code
**What**: Automatically runs auto-fix on `.md`, `.yml`, `.yaml` files
**Setup**: Install recommended extensions via `setup-dev-automation.sh`

```bash
# Files auto-fix when you save them in VS Code
# No manual intervention needed
```

### 2. File Watcher Auto-fix

**When**: Files change on disk
**What**: Watches for changes and auto-fixes within 2 seconds
**Best for**: Continuous development, bulk edits

```bash
# Start file watcher
./scripts/dev-auto.sh watch

# Files will auto-fix automatically when changed
# Press Ctrl+C to stop
```

### 3. Git Commit Auto-fix

**When**: Running `git commit`
**What**: Pre-commit hook validates, auto-fixes if needed, then commits
**Best for**: Ensuring clean commits

```bash
# Regular git commit - auto-fix runs automatically
git add .
git commit -m "your message"

# OR use smart commit (includes validation)
./scripts/dev-auto.sh commit "your message"
```

### 4. Manual Validation and Fixing

**When**: On-demand
**What**: Check for issues, auto-fix if found
**Best for**: Before important commits, bulk validation

```bash
# Check for issues only
./scripts/dev-auto.sh check

# Fix issues only
./scripts/dev-auto.sh fix

# Check, then fix if needed
./scripts/dev-auto.sh validate
```

### 5. Continuous Background Validation

**When**: Continuously every 30 seconds
**What**: Runs validation checks and auto-fixes issues
**Best for**: Long development sessions

```bash
# Start continuous validation
./scripts/dev-auto.sh continuous

# Checks every 30 seconds, fixes if needed
# Press Ctrl+C to stop
```

## What Gets Auto-fixed

The automation system automatically fixes:

- ✅ **Trailing whitespace** - Removed from all lines
- ✅ **Missing final newlines** - Added to end of files
- ✅ **YAML indentation** - Tabs converted to spaces
- ✅ **Basic line length** - Reports files with long lines (manual split needed)
- ✅ **File encoding** - Ensures proper UTF-8 encoding

## VS Code Integration

### Tasks Available

Access via `Ctrl+Shift+P` → "Tasks: Run Task":

- **Auto-fix: Fix Code Quality Issues** - Run auto-fix manually
- **Quick Check: Validate Code Quality** - Check for issues
- **Smart Commit: Auto-fix and Commit** - Commit with auto-fix
- **Validate and Auto-fix Pipeline** - Full validation + fix + re-validate

### Settings

The workspace includes settings for:

- Real-time linting and validation
- Auto-format on save
- 120-character rulers and word wrap
- Trailing whitespace removal
- Final newline insertion

### Extensions

Recommended extensions (auto-installed):

- `emeraldwalk.runonsave` - Auto-fix on file save
- `davidanson.vscode-markdownlint` - Markdown linting
- `redhat.vscode-yaml` - YAML validation
- `streetsidesoftware.code-spell-checker` - Spell checking

## Command Reference

### Development Helper (`./scripts/dev-auto.sh`)

```bash
./scripts/dev-auto.sh fix                    # Run auto-fix once
./scripts/dev-auto.sh check                  # Run validation check
./scripts/dev-auto.sh validate               # Check then fix if needed
./scripts/dev-auto.sh watch                  # Watch files and auto-fix
./scripts/dev-auto.sh continuous             # Continuous validation loop
./scripts/dev-auto.sh commit "message"       # Smart commit with auto-fix
```

### Individual Scripts

```bash
./scripts/auto-fix.sh                        # Fix common issues
./scripts/quick-check.sh                     # Fast validation
./scripts/smart-commit.sh "message"          # Intelligent commit
./scripts/watch-and-fix.sh                   # File watcher
./scripts/setup-dev-automation.sh            # Setup automation
```

## Git Hook Behavior

The enhanced pre-commit hook:

1. **Validates** staged files first
2. **Auto-fixes** if validation fails
3. **Re-stages** the fixed files
4. **Re-validates** to ensure success
5. **Commits** with fixed code

This ensures all commits have clean, validated code without manual intervention.

## Troubleshooting

### File Watcher Not Working

```bash
# Install fswatch
brew install fswatch

# Test file watcher
./scripts/watch-and-fix.sh
```

### VS Code Auto-fix Not Working

1. Check if "Run On Save" extension is installed
2. Reload VS Code window
3. Check output panel for errors

### Pre-commit Hook Not Running

```bash
# Re-run setup
./scripts/setup-dev-automation.sh

# Check hook permissions
ls -la .git/hooks/pre-commit
```

### Manual Override

If automation needs to be bypassed:

```bash
# Skip pre-commit hook
git commit --no-verify -m "message"

# Disable file watcher
# Press Ctrl+C in the watcher terminal
```

## Workflow Examples

### Daily Development

```bash
# Morning setup
./scripts/dev-auto.sh watch        # Start file watcher

# Develop normally - files auto-fix as you work
# ... edit files in VS Code ...

# Commit when ready (auto-fix runs via git hook)
git add .
git commit -m "feat: implement new feature"
```

### Bulk File Updates

```bash
# Update many files at once
./scripts/dev-auto.sh validate     # Check and fix all issues

# Review changes
git diff

# Commit
git add .
git commit -m "style: fix formatting across files"
```

### Pre-delivery Quality Check

```bash
# Comprehensive validation
./scripts/dev-auto.sh continuous   # Let it run for a few minutes

# Final check
./scripts/dev-auto.sh check

# Smart commit with final validation
./scripts/dev-auto.sh commit "release: prepare v1.0.0"
```

## Benefits

- 🚀 **Faster Development** - No waiting for slow pre-commit checks
- 🔧 **Automatic Fixing** - Common issues fixed without manual intervention
- 💡 **Proactive** - Catches issues during development, not at commit time
- 🎯 **Seamless** - Integrates with existing VS Code + git workflow
- ⚡ **Fast** - Lightweight validation and fixing
- 🛡️ **Reliable** - Ensures consistent code quality across all commits

The system transforms reactive, slow pre-commit validation into proactive, fast development-time fixing.
