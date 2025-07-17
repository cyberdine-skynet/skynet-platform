# Skynet Platform - Complete Infrastructure Documentation

## 🚀 Overview

The Skynet Platform is a modern, cloud-native GitOps infrastructure built on Talos OS Kubernetes for bare metal
NUC deployment.
It implements a clean, modular, Helm-based approach with encrypted secrets management and
comprehensive CI/CD workflows.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Skynet Platform Architecture                 │
├─────────────────────────────────────────────────────────────────┤
│  External Access                                                │
│  ┌─────────────────┐    ┌─────────────────────────────────────┐ │
│  │   Internet      │────│  MetalLB LoadBalancer               │ │
│  │                 │    │  IP: 192.168.1.201                  │ │
│  └─────────────────┘    └─────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Ingress Layer                        │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │              Traefik Ingress Controller                    │ │
│  │  - HTTP/HTTPS Routing                                      │ │
│  │  - TLS Termination (cert-manager)                          │ │
│  │  - Dashboard: :9000/dashboard/                             │ │
│  │  - Metrics: Prometheus                                     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  GitOps Layer                         │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │                Argo CD                                     │ │
│  │  - GitOps Continuous Deployment                            │ │
│  │  - App-of-Apps Pattern                                     │ │
│  │  - UI: NodePort :30180                                     │ │
│  │  - UI: Ingress argocd.fle.api64.de                        │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Infrastructure Services              │                         │
│  ┌─────────────────┐ ┌───────────────┐ ┌─────────────────────┐   │
│  │   MetalLB       │ │ cert-manager  │ │     Traefik         │   │
│  │ LoadBalancer    │ │ TLS Certs     │ │ Ingress Controller  │   │
│  │ IP Pool Mgmt    │ │ Let's Encrypt │ │ HTTP/HTTPS Routing  │   │
│  └─────────────────┘ └───────────────┘ └─────────────────────┘   │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Application Layer                    │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │              Demo Applications                              │ │
│  │  - Demo App (nginx)                                        │ │
│  │  - Test Applications                                       │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Security & Secrets                   │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │               SOPS + AGE Encryption                         │ │
│  │  - Encrypted Secrets Management                            │ │
│  │  - Age Key-based Encryption                                │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Infrastructure as Code               │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │                Terraform                                   │ │
│  │  - Argo CD Deployment                                      │ │
│  │  - Helm Provider                                           │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                       │                         │
├───────────────────────────────────────┼─────────────────────────┤
│  Kubernetes Platform                  │                         │
│  ┌─────────────────────────────────────┼─────────────────────────┐ │
│  │              Talos OS Kubernetes                           │ │
│  │  - Node: 192.168.1.175 (control-plane)                    │ │
│  │  - Version: v1.32.3                                       │ │
│  │  - Container Runtime: containerd 2.0.3                    │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 📊 Component Matrix

| Component | Status | Version | Access Method | URL/Endpoint | Purpose |
|-----------|--------|---------|---------------|--------------|---------|
| **Talos OS** | ✅ Running | v1.9.5 | SSH/talosctl | 192.168.1.175 | Kubernetes OS |
| **Kubernetes** | ✅ Running | v1.32.3 | kubectl | - | Container Orchestration |
| **Argo CD** | ✅ Healthy | v2.13.2 | Web UI | http://192.168.1.175:30180 | GitOps Controller |
| **Argo CD** | ✅ Healthy | v2.13.2 | Ingress | http://argocd.fle.api64.de | GitOps Controller |
| **Traefik** | ✅ Healthy | v3.1.5 | Web UI | http://192.168.1.201:9000/dashboard/ | Ingress Controller |
| **MetalLB** | ✅ Healthy | Latest | - | - | LoadBalancer Provider |
| **cert-manager** | ✅ Healthy | Latest | - | - | TLS Certificate Manager |
| **Demo App** | ✅ Running | nginx:alpine | Internal | demo-app.demo-app.svc.cluster.local | Test Workload |

## 🔧 Infrastructure Components

### 1

Talos OS Kubernetes Cluster

- **Purpose**: Immutable, secure Kubernetes OS
- **Node**: 192.168.1.175 (control-plane)
- **Network**: 192.168.1.x subnet
- **Features**: Minimal attack surface, API-driven configuration

### 2

Argo CD (GitOps Controller)

- **Purpose**: Continuous deployment from Git repositories
- **Pattern**: App-of-Apps for hierarchical application management
- **Repository**: https://github.com/cyberdine-skynet/skynet-platform
- **Access**:
  - NodePort: http://192.168.1.175:30180
  - Ingress: http://argocd.fle.api64.de (via Traefik)

### 3

Traefik (Ingress Controller)

- **Purpose**: HTTP/HTTPS routing, load balancing, TLS termination
- **LoadBalancer IP**: 192.168.1.201 (via MetalLB)
- **Dashboard**: http://192.168.1.201:9000/dashboard/
- **Features**:
  - Automatic HTTP→HTTPS redirect
  - cert-manager integration
  - Prometheus metrics
  - Kubernetes Ingress & CRD support

### 4

MetalLB (LoadBalancer Provider)

- **Purpose**: Bare metal LoadBalancer implementation
- **IP Pool**: 192.168.1.200-192.168.1.220
- **Mode**: L2 Advertisement
- **Features**: Automatic IP allocation for LoadBalancer services

### 5

cert-manager (TLS Certificate Manager)

- **Purpose**: Automatic TLS certificate provisioning
- **Issuers**: Let's Encrypt (staging & production)
- **Features**: ACME HTTP-01 challenge, automatic renewal

### 6

SOPS + Age (Secrets Management)

- **Purpose**: Encrypted secrets in Git
- **Encryption**: Age key-based encryption
- **Integration**: Kubernetes secrets, ConfigMaps

## 📁 Repository Structure

```
skynet-platform/
├── README.md                           # This documentation
├── SETUP.md                           # Setup instructions
├── .github/workflows/                 # CI/CD workflows
│   ├── tfsec.yml                      # Terraform security scanning
│   └── dependency-review.yml          # Dependency security review
├── terraform/                         # Infrastructure as Code
│   ├── main.tf                        # Argo CD deployment
│   ├── provider.tf                    # Terraform providers
│   └── variables.tf                   # Configuration variables
├── apps/                              # Argo CD Applications
│   ├── root-app-simple.yaml          # Root app-of-apps
│   └── workloads/                     # Application definitions
│       ├── demo-app/                  # Demo application
│       ├── metallb/                   # MetalLB Helm app
│       ├── metallb-config/            # MetalLB configuration
│       ├── cert-manager/              # cert-manager Helm app
│       ├── cert-manager-issuers/      # TLS certificate issuers
│       └── traefik/                   # Traefik Helm app
├── manifests/                         # Kubernetes manifests
│   ├── demo-app/                      # Demo app deployment
│   ├── metallb-config/                # MetalLB IP pools
│   └── cert-manager-issuers/          # ClusterIssuers
├── secrets/                           # Encrypted secrets (SOPS)
│   ├── .sops.yaml                     # SOPS configuration
│   └── age-key.txt                    # Age encryption key
└── scripts/                           # Utility scripts
    └── traefik-dashboard.sh           # Dashboard access script
```

## 🚀 Installation Timeline

### Phase 1: Foundation (Completed ✅)

1.

**Terraform Setup** - Argo CD deployment via Helm
2.
**GitOps Bootstrap** - Connected GitHub repository
3.
**App-of-Apps Pattern** - Hierarchical application management

### Phase 2: Networking (Completed ✅)

1.

**MetalLB** - LoadBalancer IP pool configuration
2.
**Traefik** - Ingress controller with dashboard
3.
**cert-manager** - TLS certificate automation

### Phase 3: Security (Completed ✅)

1.

**SOPS Configuration** - Age-based encryption setup
2.
**Encrypted Secrets** - Secure secrets management
3.
**CI/CD Security** - TFSec and dependency scanning

### Phase 4: Applications (In Progress 🔄)

1.

**Demo Applications** - Test workloads
2.
**Monitoring Stack** - Prometheus, Grafana, Loki (Planned)
3.
**Authentication** - Authentik identity provider (Planned)

## 🔐 Security Features

### Secrets Management

- **SOPS + Age encryption** for all sensitive data
- **Kubernetes secrets** automatically decrypted
- **No plaintext secrets** in Git repository

### Network Security

- **TLS termination** at ingress level
- **Automatic HTTP→HTTPS redirect**
- **Let's Encrypt certificates** for production domains

### CI/CD Security

- **TFSec scanning** for Terraform security issues
- **Dependency review** for supply chain security
- **Branch protection** rules (planned)

## 📈 Monitoring & Observability

### Current Metrics

- **Traefik metrics** - Available at `/metrics` endpoint
- **cert-manager metrics** - Certificate renewal status
- **Kubernetes metrics** - Built-in cluster metrics

### Planned Monitoring

- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **Loki** - Log aggregation
- **AlertManager** - Alerting rules

## 🔄 GitOps Workflow

### Branch Strategy

```
main branch (protected)
├── feature/metallb-setup
├── feature/cert-manager
├── feature/traefik-ingress
└── fix/traefik-dashboard
```

### Deployment Process

1.

**Feature Branch** - Create branch for changes
2.
**Development** - Make infrastructure changes
3.
**Testing** - Validate in development
4.
**Pull Request** - Code review process
5.
**Merge to Main** - Automatic deployment via Argo CD
6.
**Sync & Health** - Monitor application status

### Argo CD Apps Health

```bash
$ kubectl get applications -n argocd
NAME                  SYNC STATUS   HEALTH STATUS
root-app             Synced        Healthy
demo-app             Synced        Healthy
metallb              Synced        Healthy
metallb-config       Synced        Healthy
cert-manager         Synced        Healthy
cert-manager-issuers Synced        Healthy
traefik              Synced        Healthy
```

## 🎯 Next Steps

### Immediate (Next Sprint)

1.

**Authentication** - Deploy Authentik identity provider
2.
**Monitoring** - Add Prometheus + Grafana stack
3.
**Documentation** - Component-specific README files

### Medium Term

1.

**Backup Strategy** - Velero backup solution
2.
**Service Mesh** - Istio or Linkerd integration
3.
**Multi-tenancy** - Namespace isolation

### Long Term

1.

**Multi-cluster** - Cluster federation
2.
**Edge Computing** - Edge node integration
3.
**AI/ML Workloads** - GPU support and ML pipelines

## 🛠️ Quick Start Commands

### Access Services

```bash
# Argo CD UI
open http://192.168.1.175:30180

# Traefik Dashboard
open http://192.168.1.201:9000/dashboard/

# Get Argo CD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward Traefik dashboard
kubectl port-forward -n traefik-system svc/traefik 8080:9000
```

### Check Status

```bash
# All applications
kubectl get applications -n argocd

# All pods
kubectl get pods --all-namespaces

# LoadBalancer services
kubectl get svc --all-namespaces -o wide | grep LoadBalancer

# Ingress rules
kubectl get ingress --all-namespaces
```

### Troubleshooting

```bash
# Argo CD sync issues
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{}}}' --type merge

# Check logs
kubectl logs -n <namespace> deployment/<deployment-name>

# Describe resources
kubectl describe application <app-name> -n argocd
```

---

*Built with ❤️ by the Cyberdine Skynet Team*
*Last Updated: July 17, 2025*
