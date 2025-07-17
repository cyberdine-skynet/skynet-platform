#!/bin/bash
# Interactive Git Workflow Script
# Status → Add → Commit → Push with user confirmation
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

set -e

echo "📋 Interactive Git Workflow"
echo "=========================="

# Function to ask yes/no
ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes (y) or no (n)." ;;
        esac
    done
}

# Function to get commit message
get_commit_message() {
    local message
    echo ""
    echo "📝 Enter commit message:"
    read -p "> " message

    if [ -z "$message" ]; then
        echo "❌ Commit message cannot be empty"
        return 1
    fi

    echo "$message"
    return 0
}

# Step 1: Git Status
echo ""
echo "🔍 Step 1: Checking git status..."
git status

if ask_yes_no "📁 Do you want to add files"; then
    echo ""
    echo "➕ Step 2: Adding files..."
    git add .
    echo "✅ Files added"

    # Show what was staged
    echo ""
    echo "📋 Staged files:"
    git diff --cached --name-only
else
    echo "⏭️  Skipping add step"
fi

if ask_yes_no "💾 Do you want to commit"; then
    echo ""

    # Get commit message
    COMMIT_MSG=""
    while [ -z "$COMMIT_MSG" ]; do
        COMMIT_MSG=$(get_commit_message)
    done

    echo ""
    echo "🚀 Step 3: Committing with message: '$COMMIT_MSG'"

    # Use fast commit if available, otherwise regular commit
    if [ -f "./scripts/fast-commit.sh" ]; then
        echo "⚡ Using fast commit with auto-fix..."
        ./scripts/fast-commit.sh "$COMMIT_MSG

Co-authored-by: francesco2323 <f.emanuele@outlook.com>"
    else
        echo "📝 Using regular git commit..."
        git commit -m "$COMMIT_MSG

Co-authored-by: francesco2323 <f.emanuele@outlook.com>"
    fi

    echo "✅ Commit completed"
else
    echo "⏭️  Skipping commit step"
    exit 0
fi

if ask_yes_no "🚀 Do you want to push to remote"; then
    echo ""
    echo "📤 Step 4: Pushing to remote..."
    git push
    echo "✅ Push completed"
else
    echo "⏭️  Skipping push step"
fi

echo ""
echo "🎉 Git workflow complete!"
echo ""
echo "📊 Final status:"
git status --short
