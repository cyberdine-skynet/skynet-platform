# Skynet Platform

A clean, production-ready GitOps platform ## 📊 Current Applications

| Application | Namespace | Status | Description | Access |
|-------------|-----------|--------|-------------|---------|
| **Argo CD** | `argocd` | ✅ Running | GitOps controller (Terraform managed) | NodePort 30180/30543 |
| **Demo App** | `demo-app` | ✅ Running | Secure nginx demo workload | ClusterIP:80 → 8080 |

## 📈 Live Cluster Status

- **Argo CD Applications**: 2 deployed (skynet-root-app, demo-app)
- **Helm Releases**: 1 (argocd v2.10.7 via chart 6.7.12)
- **Active Namespaces**: argocd, demo-app, cert-manager, plus system namespaces
- **Demo App Replicas**: 2 pods running healthyTerraform and Helm to deploy Argo CD on Talos OS Kubernetes clusters.

## 🏗️ Architecture

This platform follows Infrastructure as Code (IaC) and GitOps principles:

```text
skynet-platform/
├── terraform/                     # Infrastructure as Code
│   ├── main.tf                   # Argo CD deployment via Helm
│   ├── values/                   # Helm values for Argo CD
│   └── providers.tf              # Terraform providers
├── apps/
│   ├── root-app-simple.yaml     # Root App-of-Apps
│   └── workloads/                # Application workloads
│       └── demo-app/             # Demo application
├── manifests/                    # Kubernetes manifests
│   └── demo-app/                 # Demo app deployment
└── cleanup-argocd.sh            # Cleanup utility
```

## 🚀 Quick Start

### Prerequisites
- Talos OS Kubernetes cluster (bare metal)
- Terraform installed
- kubectl configured for your cluster

### 1. Deploy Argo CD via Terraform

```bash
cd terraform
terraform init
terraform apply
```

### 2. Access Argo CD

**NodePort Access:**
- HTTP: `http://NODE_IP:30180`
- HTTPS: `https://NODE_IP:30543`

**Port Forward (alternative):**
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