# Skynet Platform

A modern, production-ready GitOps infrastructure platform built on Talos OS Kubernetes with
comprehensive tooling, security, and automation.

## 🎯 Platform Overview

The Skynet Platform is a complete Kubernetes infrastructure stack featuring:

- **GitOps Continuous Deployment** via Argo CD
- **Ingress & Load Balancing** via Traefik + MetalLB
- **Automatic TLS Certificates** via cert-manager
- **Encrypted Secrets Management** via SOPS + Age
- **Infrastructure as Code** via Terraform + Helm
- **CI/CD Security Scanning** via GitHub Actions

## 📊 Current Infrastructure Status

| Component | Status | Version | Access | Purpose |
|-----------|--------|---------|---------|---------|
| **Talos OS Kubernetes** | ✅ Running | v1.32.3 | Node: 192.168.1.175 | Container Platform |
| **Argo CD** | ✅ Healthy | v2.13.2 | http://192.168.1.175:30180 | GitOps Controller |
| **Traefik** | ✅ Healthy | v3.1.5 | http://192.168.1.201:9000/dashboard/ | Ingress Controller |
| **MetalLB** | ✅ Healthy | Latest | IP Pool: 192.168.1.200-220 | LoadBalancer Provider |
| **cert-manager** | ✅ Healthy | Latest | ClusterIssuers: staging/prod | TLS Certificate Manager |
| **Demo App** | ✅ Running | nginx:alpine | Internal ClusterIP | Test Workload |

## 🏗️ Architecture

```
External Access (192.168.1.201)
    ↓
Traefik Ingress Controller (LoadBalancer)
    ↓
Kubernetes Services
    ↓
Application Pods
    ↓
Talos OS Node (192.168.1.175)
```

### Repository Structure

```
skynet-platform/
├── 📖 README.md                           # This overview
├── 📖 INFRASTRUCTURE.md                   # Complete architecture documentation
├── 📖 COMMANDS.md                         # Command reference guide
├── 📖 SETUP.md                           # Setup instructions
├── 🔧 terraform/                         # Infrastructure as Code
│   ├── main.tf                          # Argo CD deployment
│   └── provider.tf                      # Terraform providers
├── 🚀 apps/                              # Argo CD Applications
│   ├── root-app-simple.yaml             # Root app-of-apps
│   ├── 📖 README.md                      # Argo CD documentation
│   └── workloads/                       # Application definitions
│       ├── demo-app/                    # Demo application
│       ├── metallb/                     # MetalLB Helm app
│       ├── metallb-config/              # MetalLB configuration
│       ├── cert-manager/                # cert-manager Helm app
│       ├── cert-manager-issuers/        # TLS certificate issuers
│       └── traefik/                     # Traefik Helm app
├── 📦 manifests/                         # Kubernetes manifests
│   ├── demo-app/                        # Demo app deployment
│   ├── metallb-config/                  # MetalLB IP pools
│   ├── cert-manager-issuers/            # ClusterIssuers
│   ├── 📖 README-traefik.md             # Traefik documentation
│   ├── 📖 README-metallb.md             # MetalLB documentation
│   └── 📖 README-cert-manager.md        # cert-manager documentation
├── 🔐 secrets/                          # Encrypted secrets (SOPS)
│   ├── .sops.yaml                      # SOPS configuration
│   └── age-key.txt                     # Age encryption key
├── 🛠️ scripts/                          # Utility scripts
│   └── traefik-dashboard.sh            # Dashboard access script
└── 🔄 .github/workflows/                # CI/CD workflows
    ├── tfsec.yml                       # Terraform security scanning
    └── dependency-review.yml           # Dependency security review
```

## 📚 Documentation

### Complete Guides

- **[📖 INFRASTRUCTURE.md](INFRASTRUCTURE.md)** - Complete architecture and component overview
- **[📖 COMMANDS.md](COMMANDS.md)** - Comprehensive command reference for daily operations
- **[📖 SETUP.md](SETUP.md)** - Step-by-step setup instructions

### Component-Specific Documentation

- **[📖 Argo CD Guide](apps/README.md)** - GitOps controller operations and troubleshooting
- **[📖 Traefik Guide](manifests/README-traefik.md)** - Ingress controller configuration and usage
- **[📖 MetalLB Guide](manifests/README-metallb.md)** - LoadBalancer setup and management
- **[📖 cert-manager Guide](manifests/README-cert-manager.md)** - TLS certificate automation

## 🚀 Quick Start

### Prerequisites

- Talos OS Kubernetes cluster (bare metal)
- Terraform installed
- kubectl configured for your cluster
- Git repository access

### 1. Deploy Infrastructure

```bash
# Clone repository
git clone https://github.com/cyberdine-skynet/skynet-platform.git
cd skynet-platform

# Deploy Argo CD via Terraform
cd terraform
terraform init
terraform apply

# Deploy GitOps applications
kubectl apply -f ../apps/root-app-simple.yaml

# Verify deployment
kubectl get applications -n argocd
```

### 2. Access Services

**Argo CD Dashboard:**

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access via NodePort
open http://192.168.1.175:30180
# Login: admin / <password-from-above>
```

**Traefik Dashboard:**

```bash
# Direct access (if on same network)
open http://192.168.1.201:9000/dashboard/

# Port-forward (if external access issues)
./scripts/traefik-dashboard.sh
open http://localhost:8080/dashboard/
```

### 3. Verify Installation

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

### 3. Get Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Deploy Root Application

```bash
kubectl apply -f apps/root-app-simple.yaml
```

## � Current Applications

| Application | Namespace | Status | Description |
|-------------|-----------|--------|-------------|
| Argo CD | `argocd` | ✅ Running | GitOps controller (Terraform managed) |
| Demo App | `demo-app` | ✅ Running | Secure nginx demo workload |

## 🔧 Platform Features

### Argo CD Features

- **Terraform Managed**: Infrastructure as Code approach
- **NodePort Service**: Exposed on ports 30180 (HTTP) and 30543 (HTTPS)
- **Talos Optimized**: Security context and resource limits configured for bare metal
- **GitOps Ready**: Connects to public GitHub repository
- **Self-Healing**: Automatic sync and pruning enabled

### Demo Application Features

- **Security Hardened**: Non-root user, read-only filesystem, dropped capabilities
- **Production Ready**: Health checks, resource limits, proper volume mounts
- **Nginx Based**: Custom configuration via ConfigMap on port 8080
- **GitOps Managed**: Deployed and synced via Argo CD

## 🔒 Security

- Security contexts with non-root users
- Read-only root filesystems
- Capability dropping (ALL capabilities removed)
- Resource limits and requests configured
- Network policies ready for implementation

## �️ Customization

### Argo CD Configuration

Edit `terraform/values/argocd-values.yaml` to customize:

- Resource limits and requests
- NodePort configurations
- Security contexts
- Additional Argo CD features

### Adding New Applications

1. Create application directory in `apps/workloads/`
2. Add `app.yaml` with Argo CD Application definition
3. Create manifests in `manifests/` directory
4. Commit and push - Argo CD will auto-sync

## 🧹 Maintenance

### Clean Argo CD Installation

If you need to completely reset Argo CD:

```bash
./cleanup-argocd.sh
cd terraform && terraform apply
```

### Repository Cleanup

The repository has been cleaned of:

- Old Autopilot configurations
- Manual secrets and ConfigMaps
- Outdated deployment scripts
- Unused application directories

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes in your Talos cluster
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
