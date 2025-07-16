#!/bin/bash

# Skynet Platform Terraform Deployment Script
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Default environment
ENVIRONMENT=${1:-dev}
TF_DIR="terraform"
TF_VAR_FILE="environments/${ENVIRONMENT}.tfvars"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_status "Deploying Skynet Platform with Terraform (Environment: ${ENVIRONMENT})"

cd "${TF_DIR}"

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Set sensitive variables via environment
export TF_VAR_github_pat="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"
export TF_VAR_github_oauth_client_id="Ov23liD7vhKxvYHgF1WE"
export TF_VAR_github_oauth_client_secret="11630d854dd2d4bf9a46572e8e81575ba8a0d6c5"

# Plan the deployment
print_status "Planning Terraform deployment..."
terraform plan -var-file="../${TF_VAR_FILE}" -out=tfplan

# Ask for confirmation
echo ""
print_warning "This will deploy the Skynet Platform infrastructure to your Kubernetes cluster."
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled."
    exit 0
fi

# Apply the deployment
print_status "Applying Terraform configuration..."
terraform apply tfplan

print_success "Terraform deployment completed!"

# Wait for Argo CD to be ready
print_status "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get access information
print_success "Deployment completed!"
echo ""
echo "Access Information:"
echo "==================="
echo "1. Argo CD UI: https://argocd.fle.api64.de"
echo "2. NodePort: https://NODE_IP:30443"
echo "3. Port Forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""

# Get admin password
print_status "Retrieving Argo CD admin password..."
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "Secret not found")

if [ "$ADMIN_PASSWORD" != "Secret not found" ]; then
    echo "Admin Credentials:"
    echo "Username: admin"
    echo "Password: $ADMIN_PASSWORD"
else
    print_warning "Admin password secret not found. Use GitHub SSO to login."
fi

echo ""
print_success "Platform deployment completed! 🚀"
