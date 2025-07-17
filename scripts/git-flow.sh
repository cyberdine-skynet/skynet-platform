#!/bin/bash
# Git Workflow Helper - Status, Add, Commit, Push
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

COMMIT_MSG="$1"

show_help() {
    echo "🚀 Git Workflow Helper"
    echo ""
    echo "Usage:"
    echo "  $0 'commit message'           # Full workflow: status → add → commit → push"
    echo "  $0 status                     # Just show status"
    echo "  $0 add                        # Just add all files"
    echo "  $0 commit 'message'           # Just commit with message"
    echo "  $0 push                       # Just push"
    echo ""
    echo "Examples:"
    echo "  $0 'feat: add new feature'    # Complete workflow"
    echo "  $0 status                     # Check current status"
}

run_status() {
    echo "📊 Git Status:"
    git status
}

run_add() {
    echo "📁 Adding all changes..."
    git add .
    echo "✅ Files staged"
}

run_commit() {
    local msg="$1"
    if [ -z "$msg" ]; then
        echo "❌ Commit message required"
        echo "Usage: $0 commit 'your message'"
        exit 1
    fi

    echo "💾 Committing with fast auto-fix..."
    time ./scripts/fast-commit.sh "$msg"
}

run_push() {
    echo "🚀 Pushing to remote..."
    git push
    echo "✅ Push complete"
}

run_full_workflow() {
    local msg="$1"
    if [ -z "$msg" ]; then
        show_help
        exit 1
    fi

    echo "🔄 Running full git workflow..."
    echo ""

    # Step 1: Status
    run_status
    echo ""

    # Step 2: Add
    run_add
    echo ""

    # Step 3: Commit (with fast auto-fix)
    run_commit "$msg"
    echo ""

    # Step 4: Push
    run_push
    echo ""

    echo "🎉 Complete workflow finished!"
}

# Main command handling
case "${1:-help}" in
    "status")
        run_status
        ;;
    "add")
        run_add
        ;;
    "commit")
        run_commit "$2"
        ;;
    "push")
        run_push
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        # If first argument looks like a commit message, run full workflow
        if [ -n "$1" ] && [[ ! "$1" =~ ^(status|add|commit|push|help|-h|--help)$ ]]; then
            run_full_workflow "$1"
        else
            show_help
        fi
        ;;
esac
