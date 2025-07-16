#!/bin/bash

# Skynet Platform Deployment Script
# This script automates the deployment of the Helm-based GitOps platform

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    print_success "kubectl is available"
}

# Check if cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    print_success "Kubernetes cluster is accessible"
}

# Create namespace if it doesn't exist
create_namespace() {
    local namespace=$1
    if ! kubectl get namespace "$namespace" &> /dev/null; then
        print_status "Creating namespace: $namespace"
        kubectl create namespace "$namespace"
        print_success "Namespace $namespace created"
    else
        print_warning "Namespace $namespace already exists"
    fi
}

# Install Argo CD
install_argocd() {
    print_status "Installing Argo CD..."
    
    create_namespace "argocd"
    
    # Install Argo CD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    print_status "Waiting for Argo CD to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
    
    print_success "Argo CD installed successfully"
}

# Deploy the root application
deploy_root_app() {
    print_status "Deploying secrets and configuration..."
    
    # Apply secrets first
    if [ -d "secrets" ]; then
        kubectl apply -f secrets/
        print_success "Secrets applied"
    fi
    
    print_status "Deploying root App-of-Apps..."
    
    if [ ! -f "apps/root-app.yaml" ]; then
        print_error "root-app.yaml not found. Make sure you're in the correct directory."
        exit 1
    fi
    
    kubectl apply -f apps/root-app.yaml
    print_success "Root App-of-Apps deployed"
}

# Get Argo CD admin password
get_admin_password() {
    print_status "Retrieving Argo CD admin password..."
    
    # Wait for the secret to be created
    local retries=0
    while [ $retries -lt 30 ]; do
        if kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
            break
        fi
        print_status "Waiting for admin secret to be created... (attempt $((retries+1))/30)"
        sleep 10
        retries=$((retries+1))
    done
    
    if [ $retries -eq 30 ]; then
        print_error "Admin secret not found after 5 minutes"
        return 1
    fi
    
    local password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    echo ""
    print_success "Argo CD Admin Credentials:"
    echo "Username: admin"
    echo "Password: $password"
    echo ""
}

# Show access information
show_access_info() {
    print_success "Deployment completed!"
    echo ""
    echo "Access Methods:"
    echo "1. NodePort (if configured):"
    echo "   - HTTP:  http://NODE_IP:30080"
    echo "   - HTTPS: https://NODE_IP:30443"
    echo ""
    echo "2. Port Forward:"
    echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "   Then access: https://localhost:8080"
    echo ""
    echo "3. Get node IP:"
    echo "   kubectl get nodes -o wide"
    echo ""
    
    get_admin_password
    
    print_warning "Next steps:"
    echo "1. Configure GitHub SSO (see GITHUB_SSO.md)"
    echo "2. Add private repository credentials if needed"
    echo "3. Review and customize application values.yaml files"
    echo "4. Configure DNS to point argocd.fle.api64.de and traefik.fle.api64.de to your cluster"
}

# Main deployment function
main() {
    echo "======================================"
    echo "  Skynet Platform Deployment Script  "
    echo "======================================"
    echo ""
    
    check_kubectl
    check_cluster
    
    print_status "Starting deployment..."
    
    # Check if Argo CD is already installed
    if kubectl get deployment argocd-server -n argocd &> /dev/null; then
        print_warning "Argo CD is already installed"
    else
        install_argocd
    fi
    
    deploy_root_app
    
    print_status "Waiting for applications to sync..."
    sleep 30
    
    show_access_info
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --skip-argocd  Skip Argo CD installation"
        echo ""
        echo "This script deploys the Skynet Platform GitOps setup."
        exit 0
        ;;
    --skip-argocd)
        print_warning "Skipping Argo CD installation"
        check_kubectl
        check_cluster
        deploy_root_app
        show_access_info
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
