# Skynet Platform Setup Guide

Complete setup guide for the Terraform/Helm-based GitOps platform on Talos OS.

## Prerequisites

- Talos OS Kubernetes cluster (bare metal)
- Terraform ≥ 1.0
- kubectl configured for your cluster
- Helm 3.x (used by Terraform)

## Quick Setup

### 1. Deploy Argo CD Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

This deploys Argo CD via Helm with Talos-optimized configurations.

### 2. Verify Argo CD Deployment

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### 3. Access Argo CD

**NodePort (recommended for Talos):**

- HTTP: `http://NODE_IP:30180`
- HTTPS: `https://NODE_IP:30543`

**Port Forward (alternative):**

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:80
```

### 4. Get Admin Credentials

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Username is: admin
```

### 5. Deploy Root Application

```bash
kubectl apply -f apps/root-app-simple.yaml
```

### 6. Verify GitOps Setup

```bash
# Check Argo CD applications
kubectl get applications -n argocd

# Check demo app deployment
kubectl get pods -n demo-app
kubectl get svc -n demo-app
```

## Connecting to GitHub Repository

1. **Login to Argo CD UI** using admin credentials
2. **Go to Settings > Repositories**
3. **Add Repository:**
   - Repository URL: `https://github.com/cyberdine-skynet/skynet-platform.git`
   - Connection Method: HTTPS
   - Username: Your GitHub username
   - Password: GitHub Personal Access Token

## Troubleshooting

### Clean Argo CD Installation

If you encounter issues, use the cleanup script:

```bash
./cleanup-argocd.sh
cd terraform && terraform apply
```

### Common Issues

**Pods not starting:**

```bash
kubectl describe pods -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

**NodePort not accessible:**

```bash
kubectl get nodes -o wide
kubectl get svc -n argocd argocd-server
```

**Application sync issues:**

```bash
kubectl get applications -n argocd -o wide
kubectl describe application skynet-root-app -n argocd
```

## Security Notes

- Default setup uses `--insecure` flag for HTTP access
- For production, configure proper TLS certificates
- Consider implementing additional RBAC policies
- Regularly rotate admin passwords and access tokens

## Next Steps

1. **Add more workloads** by creating new directories in `apps/workloads/`
2. **Configure ingress** for external access to applications
3. **Set up monitoring** with Prometheus and Grafana
4. **Implement backup strategies** for cluster state
