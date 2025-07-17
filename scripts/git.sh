#!/bin/bash
# Quick Git Commands Script
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

show_help() {
    echo "🚀 Quick Git Commands"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status    - Show git status"
    echo "  add       - Add all files (git add .)"
    echo "  commit    - Interactive commit with message prompt"
    echo "  push      - Push to remote"
    echo "  all       - Interactive workflow: status → add → commit → push"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 commit"
    echo "  $0 all"
}

do_status() {
    echo "🔍 Git Status:"
    git status
}

do_add() {
    echo "➕ Adding all files..."
    git add .
    echo "✅ Files added"
    echo ""
    echo "📋 Staged files:"
    git diff --cached --name-only
}

do_commit() {
    echo "💾 Commit"
    echo ""

    # Check if there are staged changes
    if ! git diff --cached --quiet; then
        echo "📝 Enter commit message:"
        read -p "> " COMMIT_MSG

        if [ -z "$COMMIT_MSG" ]; then
            echo "❌ Commit message cannot be empty"
            return 1
        fi

        echo ""
        echo "🚀 Committing: '$COMMIT_MSG'"

        # Use fast commit if available
        if [ -f "./scripts/fast-commit.sh" ]; then
            ./scripts/fast-commit.sh "$COMMIT_MSG

Co-authored-by: francesco2323 <f.emanuele@outlook.com>"
        else
            git commit -m "$COMMIT_MSG

Co-authored-by: francesco2323 <f.emanuele@outlook.com>"
        fi

        echo "✅ Commit completed"
    else
        echo "ℹ️  No staged changes to commit"
        echo "💡 Run '$0 add' first to stage files"
    fi
}

do_push() {
    echo "📤 Pushing to remote..."
    git push
    echo "✅ Push completed"
}

# Main command handling
case "${1:-help}" in
    "status"|"s")
        do_status
        ;;
    "add"|"a")
        do_add
        ;;
    "commit"|"c")
        do_commit
        ;;
    "push"|"p")
        do_push
        ;;
    "all"|"workflow")
        ./scripts/git-workflow.sh
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
