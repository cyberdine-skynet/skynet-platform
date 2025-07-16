#!/bin/bash

# Skynet Platform Deployment Script for Talos Cluster
# Cluster: skynetcluster (talos-5kn-42d)
# Node IP: 192.168.1.175
# Talos v1.9.5, Kubernetes v1.32.3

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Cluster-specific configuration
CLUSTER_NAME="skynetcluster"
NODE_IP="192.168.1.175"
NODE_NAME="talos-5kn-42d"
KUBECONFIG_PATH="/Users/f.emanuele/kubeconfig"

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

print_talos() {
    echo -e "${PURPLE}[TALOS]${NC} $1"
}

# Set kubeconfig
export KUBECONFIG="$KUBECONFIG_PATH"

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites for Talos cluster deployment..."
    
    # Check if kubeconfig exists
    if [ ! -f "$KUBECONFIG_PATH" ]; then
        print_error "Kubeconfig not found at $KUBECONFIG_PATH"
        exit 1
    fi
    
    # Check for kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        print_error "Make sure your Talos cluster is running and kubeconfig is correct"
        exit 1
    fi
    
    print_success "Prerequisites check completed"
}

# Verify Talos cluster
verify_talos_cluster() {
    print_talos "Verifying Talos cluster configuration..."
    
    # Check if we're connected to the right cluster
    local current_context=$(kubectl config current-context)
    if [[ "$current_context" != *"$CLUSTER_NAME"* ]]; then
        print_warning "Current context ($current_context) doesn't match expected cluster ($CLUSTER_NAME)"
    fi
    
    # Get node information
    local node_info=$(kubectl get nodes -o wide --no-headers)
    print_talos "Cluster information:"
    echo "  - Node: $node_info"
    
    # Check if it's actually a Talos node
    if kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}' | grep -q "Talos"; then
        local talos_version=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}')
        local k8s_version=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')
        print_talos "Talos OS: $talos_version"
        print_talos "Kubernetes: $k8s_version"
    else
        print_warning "Node doesn't appear to be running Talos OS"
    fi
    
    print_success "Talos cluster verified"
}

# Install local-path provisioner if needed
install_storage_provisioner() {
    print_status "Checking storage provisioner..."
    
    # Check if any storage class exists
    if kubectl get storageclass &> /dev/null && [ $(kubectl get storageclass --no-headers | wc -l) -gt 0 ]; then
        print_success "Storage classes already available"
        kubectl get storageclass
        return 0
    fi
    
    print_warning "No storage classes found. Installing local-path provisioner..."
    
    # Apply local-path provisioner from our manifests
    if [ -f "apps/local-path-provisioner/manifests/local-path-provisioner.yaml" ]; then
        kubectl apply -f apps/local-path-provisioner/manifests/local-path-provisioner.yaml
        
        # Wait for deployment to be ready
        print_status "Waiting for local-path provisioner to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/local-path-provisioner -n local-path-storage
        
        print_success "Local-path provisioner installed"
        kubectl get storageclass
    else
        print_error "Local-path provisioner manifest not found"
        print_error "Please ensure apps/local-path-provisioner/manifests/local-path-provisioner.yaml exists"
        exit 1
    fi
}

# Install Argo CD
install_argocd() {
    print_status "Installing Argo CD..."
    
    # Create namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Argo CD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    print_status "Waiting for Argo CD to be ready..."
    kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
    
    print_success "Argo CD installed successfully"
}

# Apply secrets and configuration
apply_secrets() {
    print_status "Applying secrets and configuration..."
    
    if [ -d "secrets" ]; then
        kubectl apply -f secrets/
        print_success "Secrets applied"
    else
        print_warning "No secrets directory found - GitHub integration may not work"
    fi
}

# Deploy root application
deploy_root_app() {
    print_status "Deploying root App-of-Apps..."
    
    if [ ! -f "apps/root-app.yaml" ]; then
        print_error "root-app.yaml not found. Make sure you're in the correct directory."
        exit 1
    fi
    
    kubectl apply -f apps/root-app.yaml
    print_success "Root App-of-Apps deployed"
}

# Wait for applications to sync
wait_for_sync() {
    print_status "Waiting for applications to sync..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local healthy_apps=$(kubectl get applications -n argocd -o jsonpath='{.items[?(@.status.health.status=="Healthy")].metadata.name}' 2>/dev/null | wc -w)
        local total_apps=$(kubectl get applications -n argocd --no-headers 2>/dev/null | wc -l)
        
        if [ "$total_apps" -gt 0 ]; then
            print_status "Applications status: $healthy_apps/$total_apps healthy"
            
            if [ "$healthy_apps" -eq "$total_apps" ]; then
                print_success "All applications are healthy"
                break
            fi
        fi
        
        sleep 30
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -eq $max_attempts ]; then
        print_warning "Some applications may still be syncing. Check Argo CD UI for details."
    fi
}

# Get deployment information
get_deployment_info() {
    print_status "Retrieving deployment information..."
    
    # Get Argo CD admin password
    local admin_password=""
    local retries=0
    while [ $retries -lt 30 ]; do
        if kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
            admin_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
            break
        fi
        print_status "Waiting for Argo CD admin secret... (attempt $((retries+1))/30)"
        sleep 10
        retries=$((retries+1))
    done
    
    echo ""
    print_success "🎉 Skynet Platform Deployed Successfully!"
    echo "=========================================="
    echo ""
    echo "🏗️ Cluster Information:"
    echo "  - Cluster: $CLUSTER_NAME"
    echo "  - Node: $NODE_NAME ($NODE_IP)"
    echo "  - Talos OS: $(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}')"
    echo "  - Kubernetes: $(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')"
    echo ""
    echo "🔐 Argo CD Access:"
    echo "  - Domain:        https://argocd.fle.api64.de (requires DNS setup)"
    echo "  - NodePort:      https://$NODE_IP:30443"
    echo "  - Port Forward:  kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo ""
    echo "🔑 Credentials:"
    echo "  - Username: admin"
    if [ -n "$admin_password" ]; then
        echo "  - Password: $admin_password"
    else
        echo "  - Password: Run 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d'"
    fi
    echo ""
    echo "🌐 Traefik Dashboard:"
    echo "  - Domain:    https://traefik.fle.api64.de (requires DNS setup)"
    echo "  - NodePort:  http://$NODE_IP:30900"
    echo ""
    echo "📊 Storage:"
    echo "  - Storage Class: $(kubectl get storageclass --no-headers | head -1 | awk '{print $1}')"
    echo "  - Default: $(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')"
    echo ""
    print_warning "Next Steps:"
    echo "1. Configure DNS to point *.fle.api64.de to $NODE_IP"
    echo "2. Access Argo CD UI and verify all applications are synced"
    echo "3. Login with GitHub SSO (cyberdine-skynet organization)"
    echo "4. Check application status: kubectl get applications -n argocd"
    echo ""
    echo "📚 Documentation: See TALOS.md for Talos-specific information"
}

# Main deployment function
main() {
    echo "=================================================="
    echo "  Skynet Platform Deployment for Talos Cluster  "
    echo "  Cluster: $CLUSTER_NAME ($NODE_IP)             "
    echo "=================================================="
    echo ""
    
    check_prerequisites
    verify_talos_cluster
    install_storage_provisioner
    
    # Check if Argo CD is already installed
    if kubectl get deployment argocd-server -n argocd &> /dev/null; then
        print_warning "Argo CD is already installed"
    else
        install_argocd
    fi
    
    apply_secrets
    deploy_root_app
    wait_for_sync
    get_deployment_info
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Deployment script for Skynet Platform on Talos cluster: $CLUSTER_NAME"
        echo ""
        echo "Options:"
        echo "  --help, -h         Show this help message"
        echo "  --skip-argocd      Skip Argo CD installation"
        echo "  --storage-only     Only install storage provisioner"
        echo "  --verify-only      Only verify cluster connectivity"
        echo ""
        echo "Cluster Information:"
        echo "  - Name: $CLUSTER_NAME"
        echo "  - Node: $NODE_NAME"
        echo "  - IP: $NODE_IP"
        echo "  - Kubeconfig: $KUBECONFIG_PATH"
        exit 0
        ;;
    --skip-argocd)
        print_warning "Skipping Argo CD installation"
        check_prerequisites
        verify_talos_cluster
        install_storage_provisioner
        apply_secrets
        deploy_root_app
        get_deployment_info
        ;;
    --storage-only)
        check_prerequisites
        verify_talos_cluster
        install_storage_provisioner
        ;;
    --verify-only)
        check_prerequisites
        verify_talos_cluster
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
