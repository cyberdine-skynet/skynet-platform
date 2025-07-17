#!/usr/bin/env bash

# 📚 MkDocs Management Script for Skynet Platform
# Provides easy commands for building, serving, and managing documentation

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly DOCS_DIR="${PROJECT_ROOT}/manifests/mkdocs-docs"
readonly DOCKER_IMAGE="skynet-docs"
readonly CONTAINER_NAME="skynet-docs-dev"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "${PURPLE}${1}${NC}"
}

# Check if MkDocs is installed locally
check_mkdocs() {
    if command -v mkdocs >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Check if Docker is available
check_docker() {
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Install MkDocs and dependencies
install_mkdocs() {
    log_header "📦 Installing MkDocs and dependencies..."

    if command -v pip3 >/dev/null 2>&1; then
        pip3 install mkdocs-material mkdocs-git-revision-date-localized-plugin
        log_success "MkDocs installed successfully!"
    elif command -v pip >/dev/null 2>&1; then
        pip install mkdocs-material mkdocs-git-revision-date-localized-plugin
        log_success "MkDocs installed successfully!"
    else
        log_error "Python pip not found. Please install Python and pip first."
        exit 1
    fi
}

# Serve documentation locally
serve_local() {
    log_header "🌐 Starting local MkDocs server..."

    if ! check_mkdocs; then
        log_warning "MkDocs not found. Installing..."
        install_mkdocs
    fi

    cd "${DOCS_DIR}"
    log_info "Serving docs from: ${DOCS_DIR}"
    log_info "Access at: http://localhost:8000"

    mkdocs serve --dev-addr=0.0.0.0:8000
}

# Build documentation
build_docs() {
    log_header "🏗️  Building documentation..."

    if ! check_mkdocs; then
        log_warning "MkDocs not found. Installing..."
        install_mkdocs
    fi

    cd "${DOCS_DIR}"
    mkdocs build --clean
    log_success "Documentation built successfully in ${DOCS_DIR}/site"
}

# Build Docker image
build_docker() {
    log_header "🐳 Building Docker image..."

    if ! check_docker; then
        log_error "Docker not available. Please install Docker first."
        exit 1
    fi

    cd "${DOCS_DIR}"
    docker build -t "${DOCKER_IMAGE}" .
    log_success "Docker image '${DOCKER_IMAGE}' built successfully!"
}

# Run documentation in Docker container
serve_docker() {
    log_header "🐳 Running documentation in Docker..."

    if ! check_docker; then
        log_error "Docker not available. Please install Docker first."
        exit 1
    fi

    # Stop existing container if running
    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Stopping existing container..."
        docker stop "${CONTAINER_NAME}" >/dev/null
    fi

    # Remove existing container if exists
    if docker ps -aq -f name="${CONTAINER_NAME}" | grep -q .; then
        log_info "Removing existing container..."
        docker rm "${CONTAINER_NAME}" >/dev/null
    fi

    # Build image if it doesn't exist
    if ! docker images -q "${DOCKER_IMAGE}" | grep -q .; then
        log_info "Docker image not found. Building..."
        build_docker
    fi

    # Run container
    log_info "Starting container '${CONTAINER_NAME}'..."
    log_info "Access at: http://localhost:8080"

    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p 8080:8080 \
        "${DOCKER_IMAGE}"

    log_success "Container started successfully!"
    log_info "View logs: docker logs -f ${CONTAINER_NAME}"
    log_info "Stop container: docker stop ${CONTAINER_NAME}"
}

# Stop Docker container
stop_docker() {
    log_header "🛑 Stopping Docker container..."

    if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
        docker stop "${CONTAINER_NAME}"
        docker rm "${CONTAINER_NAME}"
        log_success "Container stopped and removed!"
    else
        log_warning "Container '${CONTAINER_NAME}' not running."
    fi
}

# Check documentation for issues
validate_docs() {
    log_header "🔍 Validating documentation..."

    cd "${PROJECT_ROOT}"

    # Run quick check
    if [[ -f "./scripts/quick-check.sh" ]]; then
        ./scripts/quick-check.sh
    else
        log_warning "Quick check script not found. Running manual validation..."

        # Check for broken internal links (basic check)
        if check_mkdocs; then
            cd "${DOCS_DIR}"
            mkdocs build --strict 2>/dev/null || {
                log_error "MkDocs build failed. Check for configuration issues."
                return 1
            }
            log_success "MkDocs configuration is valid!"
        fi
    fi
}

# Open documentation in browser
open_docs() {
    local url="${1:-http://localhost:8000}"

    log_info "Opening documentation at: ${url}"

    if command -v open >/dev/null 2>&1; then
        # macOS
        open "${url}"
    elif command -v xdg-open >/dev/null 2>&1; then
        # Linux
        xdg-open "${url}"
    elif command -v start >/dev/null 2>&1; then
        # Windows
        start "${url}"
    else
        log_warning "Could not auto-open browser. Please visit: ${url}"
    fi
}

# Show status of documentation services
status() {
    log_header "📊 Documentation Status"

    echo ""
    echo "📍 Project Structure:"
    echo "   Docs Directory: ${DOCS_DIR}"
    echo "   Config File: $(realpath "${DOCS_DIR}/mkdocs.yml")"
    echo ""

    echo "🔧 Dependencies:"
    if check_mkdocs; then
        echo "   ✅ MkDocs: $(mkdocs --version 2>/dev/null || echo "installed")"
    else
        echo "   ❌ MkDocs: not installed"
    fi

    if check_docker; then
        echo "   ✅ Docker: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')"
    else
        echo "   ❌ Docker: not available"
    fi

    echo ""
    echo "🐳 Docker Status:"
    if check_docker; then
        if docker images -q "${DOCKER_IMAGE}" | grep -q .; then
            echo "   ✅ Image '${DOCKER_IMAGE}': built"
        else
            echo "   ❌ Image '${DOCKER_IMAGE}': not built"
        fi

        if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
            echo "   🟢 Container '${CONTAINER_NAME}': running"
            echo "      Access at: http://localhost:8080"
        else
            echo "   ⚪ Container '${CONTAINER_NAME}': not running"
        fi
    else
        echo "   ❌ Docker not available"
    fi

    echo ""
    echo "📄 Documentation Files:"
    if [[ -d "${DOCS_DIR}/docs" ]]; then
        local file_count=$(find "${DOCS_DIR}/docs" -name "*.md" | wc -l)
        echo "   📝 Markdown files: ${file_count}"
        echo "   📂 Directories: $(find "${DOCS_DIR}/docs" -type d | wc -l)"
    else
        echo "   ❌ Docs directory not found"
    fi
}

# Development workflow
dev() {
    log_header "🚀 Starting development workflow..."

    # Validate first
    if ! validate_docs; then
        log_error "Documentation validation failed. Please fix issues first."
        exit 1
    fi

    # Start local server
    log_info "Starting local development server..."
    open_docs "http://localhost:8000" &
    serve_local
}

# Production preview
preview() {
    log_header "🎭 Starting production preview..."

    # Build and run in Docker
    build_docker
    serve_docker

    # Wait a moment for container to start
    sleep 2
    open_docs "http://localhost:8080"

    log_success "Production preview running!"
    log_info "Press Ctrl+C to view container logs, or run 'stop' to stop"

    # Follow logs
    docker logs -f "${CONTAINER_NAME}"
}

# Quick help
show_help() {
    cat << EOF
📚 MkDocs Management Script for Skynet Platform

Usage: $0 <command>

Commands:
  dev                   Start development server with auto-reload
  serve                 Serve documentation locally (localhost:8000)
  build                 Build static documentation
  docker-build          Build Docker image
  docker-serve          Serve documentation in Docker (localhost:8080)
  docker-stop           Stop Docker container
  preview               Build and preview production version
  validate              Check documentation for issues
  status                Show status of documentation services
  install               Install MkDocs and dependencies
  open [url]            Open documentation in browser
  help                  Show this help message

Examples:
  $0 dev                # Start development with auto-reload
  $0 preview            # Test production build in Docker
  $0 status             # Check service status
  $0 validate           # Check for documentation issues

Development Workflow:
  1. $0 dev             # Start local development
  2. Edit docs in: ${DOCS_DIR}/docs/
  3. $0 validate        # Check for issues
  4. $0 preview         # Test production build

🔗 URLs:
  Development:  http://localhost:8000
  Docker:       http://localhost:8080

📁 Docs Location: ${DOCS_DIR}

EOF
}

# Main script logic
main() {
    case "${1:-help}" in
        "serve"|"s")
            serve_local
            ;;
        "build"|"b")
            build_docs
            ;;
        "docker-build"|"db")
            build_docker
            ;;
        "docker-serve"|"ds")
            serve_docker
            ;;
        "docker-stop"|"stop")
            stop_docker
            ;;
        "dev"|"d")
            dev
            ;;
        "preview"|"p")
            preview
            ;;
        "validate"|"v")
            validate_docs
            ;;
        "status"|"st")
            status
            ;;
        "install"|"i")
            install_mkdocs
            ;;
        "open"|"o")
            open_docs "${2:-http://localhost:8000}"
            ;;
        "help"|"h"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
