# Argo CD - GitOps Controller

## 📋 Overview

Argo CD is our GitOps continuous deployment controller that automatically syncs applications from our Git repository to the Kubernetes cluster.

## 🚀 Deployment Details

- **Namespace**: `argocd`
- **Version**: v2.13.2
- **Deployment Method**: Terraform + Helm
- **Repository**: <https://github.com/cyberdine-skynet/skynet-platform>

## 🌐 Access Methods

### Web UI (NodePort)

```bash
URL: http://192.168.1.175:30180
Username: admin
Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Web UI (Ingress via Traefik)

```bash
URL: http://argocd.fle.api64.de
# Requires DNS entry or /etc/hosts entry:
# 192.168.1.201 argocd.fle.api64.de
```

### CLI Access

```bash
# Install Argo CD CLI
brew install argocd

# Login
argocd login 192.168.1.175:30180 --username admin --password <password>

# List applications
argocd app list

# Sync application
argocd app sync <app-name>
```

## 🏗️ Architecture Pattern

We use the **App-of-Apps** pattern for hierarchical application management:

```
Root App (root-app-simple.yaml)
├── demo-app
├── metallb
├── metallb-config
├── cert-manager
├── cert-manager-issuers
└── traefik
```

## 📁 Configuration Files

```
terraform/main.tf              # Argo CD Helm deployment
apps/root-app-simple.yaml      # Root application
apps/workloads/*/app.yaml      # Individual applications
```

## 🔧 Common Commands

### Check Application Status

```bash
# All applications
kubectl get applications -n argocd

# Specific application details
kubectl describe application <app-name> -n argocd

# Application logs
kubectl logs -n argocd deployment/argocd-server
```

### Manual Sync

```bash
# Force sync an application
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{}}}' --type merge

# Sync with prune (remove deleted resources)
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{"prune":true}}}' --type merge
```

### Troubleshooting

```bash
# Check Argo CD server logs
kubectl logs -n argocd deployment/argocd-server

# Check repo server logs (for Git sync issues)
kubectl logs -n argocd deployment/argocd-repo-server

# Check application controller logs
kubectl logs -n argocd deployment/argocd-application-controller
```

## 🔐 Security Configuration

- **RBAC**: Enabled with role-based access control
- **TLS**: Configured for HTTPS access
- **Git Access**: Public repository (read-only)
- **Secrets**: Managed via SOPS encryption

## ⚙️ Sync Policies

All applications are configured with:

```yaml
syncPolicy:
  automated:
    prune: true      # Remove deleted resources
    selfHeal: true   # Auto-fix drift
  syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
```

## 📊 Monitoring

- **Health Status**: Available in Web UI
- **Sync Status**: Automatic drift detection
- **Metrics**: Prometheus metrics available
- **Notifications**: Webhook integration (planned)

## 🚨 Troubleshooting Guide

### Application Not Syncing

1. Check application status: `kubectl get application <app-name> -n argocd`
2. Check sync operation: `kubectl describe application <app-name> -n argocd`
3. Manual sync: `kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{}}}' --type merge`

### Git Repository Issues

1. Check repo server logs: `kubectl logs -n argocd deployment/argocd-repo-server`
2. Verify repository URL in application spec
3. Check network connectivity from cluster

### Authentication Issues

1. Reset admin password:

   ```bash
   # Delete the secret to regenerate
   kubectl delete secret argocd-initial-admin-secret -n argocd

   # Get new password
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Performance Issues

1. Check resource usage: `kubectl top pods -n argocd`
2. Scale components if needed:

   ```bash
   kubectl scale deployment argocd-server --replicas=2 -n argocd
   kubectl scale deployment argocd-repo-server --replicas=2 -n argocd
   ```

## 📚 References

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [App-of-Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [Sync Strategies](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/)

---

*Part of the Skynet Platform Infrastructure*
