#!/bin/bash
# Development Auto-fix Helper
# Provides various automation modes for development
# Co-authored-by: francesco2323 <f.emanuele@outlook.com>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo "🔧 Development Auto-fix Helper"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  fix           - Run auto-fix once"
    echo "  check         - Run quick validation check"
    echo "  watch         - Watch files and auto-fix on changes"
    echo "  commit MSG    - Smart commit with auto-fix"
    echo "  validate      - Run validation then auto-fix if needed"
    echo "  continuous    - Continuous validation and fixing loop"
    echo "  help          - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 fix                           # Fix issues now"
    echo "  $0 check                         # Check for issues"
    echo "  $0 watch                         # Watch and auto-fix"
    echo "  $0 commit 'feat: new feature'    # Smart commit"
    echo "  $0 validate                      # Validate then fix"
    echo ""
}

run_fix() {
    echo "🔧 Running auto-fix..."
    "$SCRIPT_DIR/auto-fix.sh"
}

run_check() {
    echo "🔍 Running validation check..."
    "$SCRIPT_DIR/quick-check.sh"
}

run_watch() {
    echo "👁️  Starting file watcher..."
    "$SCRIPT_DIR/watch-and-fix.sh"
}

run_commit() {
    local msg="$1"
    if [ -z "$msg" ]; then
        echo "❌ Please provide a commit message"
        echo "   Usage: $0 commit 'your message'"
        exit 1
    fi
    echo "🚀 Running smart commit..."
    "$SCRIPT_DIR/smart-commit.sh" "$msg"
}

run_validate() {
    echo "🔍 Running validation with auto-fix fallback..."

    if "$SCRIPT_DIR/quick-check.sh"; then
        echo "✅ Validation passed - no fixes needed"
    else
        echo "⚠️  Validation failed - running auto-fix..."
        "$SCRIPT_DIR/auto-fix.sh"

        echo "🔄 Re-running validation..."
        if "$SCRIPT_DIR/quick-check.sh"; then
            echo "✅ Validation now passes after auto-fix"
        else
            echo "⚠️  Some issues may require manual attention"
            echo "💡 Check the output above for details"
        fi
    fi
}

run_continuous() {
    echo "🔄 Starting continuous validation and fixing..."
    echo "   Press Ctrl+C to stop"
    echo ""

    while true; do
        echo "🔍 $(date '+%H:%M:%S') - Running validation..."

        if ! "$SCRIPT_DIR/quick-check.sh" >/dev/null 2>&1; then
            echo "🔧 $(date '+%H:%M:%S') - Issues found, running auto-fix..."
            "$SCRIPT_DIR/auto-fix.sh"
        else
            echo "✅ $(date '+%H:%M:%S') - All checks passed"
        fi

        echo "💤 Waiting 30 seconds..."
        sleep 30
    done
}

# Main command handling
case "${1:-help}" in
    "fix")
        run_fix
        ;;
    "check")
        run_check
        ;;
    "watch")
        run_watch
        ;;
    "commit")
        run_commit "$2"
        ;;
    "validate")
        run_validate
        ;;
    "continuous")
        run_continuous
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
