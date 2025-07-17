# 🚀 MkDocs Argo CD Deployment Guide

## ✅ Problem: MkDocs Not Deployed in Argo CD

You're right! The MkDocs documentation was not deployed in Argo CD. I've now created the complete Argo CD application configuration.

## 📁 Files Created/Updated

### 1. Argo CD Application
- **File**: `apps/workloads/mkdocs-docs/app.yaml`
- **Purpose**: Argo CD application definition for MkDocs
- **Auto-sync**: Enabled with prune and self-heal

### 2. Fixed Deployment Configuration
- **File**: `manifests/mkdocs-docs/deployment.yaml`
- **Fixed**: Namespace changed from `docs` to `mkdocs-docs`
- **Fixed**: Image updated to `ghcr.io/cyberdine-skynet/skynet-platform/mkdocs:latest`
- **Includes**: Deployment, Service, and Ingress

### 3. Namespace Configuration
- **File**: `manifests/mkdocs-docs/namespace.yaml`
- **Purpose**: Creates the `mkdocs-docs` namespace

## 🚀 Deployment Instructions

### Method 1: Automatic (Recommended)
The MkDocs application will be automatically deployed by the root Argo CD app:

```bash
# The root app automatically scans for apps/workloads/*/app.yaml
# Your MkDocs app will be picked up automatically within 3 minutes
```

### Method 2: Manual Deployment (Immediate)
If you want to deploy immediately:

```bash
# Apply the MkDocs Argo CD application
kubectl apply -f apps/workloads/mkdocs-docs/app.yaml

# Check if the application is created
kubectl get application mkdocs-docs -n argocd

# Monitor the deployment
kubectl get application mkdocs-docs -n argocd -w
```

### Method 3: Via Argo CD UI
1. Open Argo CD dashboard
2. Click "New App"
3. Or wait for auto-discovery of the new application

## 📊 Verification Steps

### 1. Check Argo CD Application
```bash
# Check if MkDocs application exists
kubectl get applications -n argocd | grep mkdocs

# Check application status
kubectl describe application mkdocs-docs -n argocd

# Check sync status
kubectl get application mkdocs-docs -n argocd -o yaml | grep -A5 -B5 status
```

### 2. Check Namespace and Pods
```bash
# Check if namespace is created
kubectl get namespace mkdocs-docs

# Check if pods are running
kubectl get pods -n mkdocs-docs

# Check pod logs if needed
kubectl logs -n mkdocs-docs deployment/mkdocs-docs
```

### 3. Check Service and Ingress
```bash
# Check service
kubectl get svc -n mkdocs-docs

# Check ingress
kubectl get ingress -n mkdocs-docs

# Test access (if ingress is working)
curl -I https://docu.fle.api64.de
```

## 🔄 How the Complete Flow Works

### 1. Code Push with Documentation Changes
```bash
# When you push with [docs] tag or modify documentation
git commit -m "Update documentation [docs]"
git push
```

### 2. CI/CD Pipeline Builds Image
```bash
# Pipeline detects docs changes and:
# 1. Builds MkDocs container image
# 2. Pushes to ghcr.io/cyberdine-skynet/skynet-platform/mkdocs:latest
# 3. Reports deployment status in PR comments
```

### 3. Argo CD Deploys Automatically
```bash
# Argo CD detects the new image and:
# 1. Pulls the latest image
# 2. Updates the deployment
# 3. Documentation site becomes available at https://docu.fle.api64.de
```

## 🛠️ Troubleshooting

### If Application Not Appearing
```bash
# Check root application status
kubectl get application skynet-root-app -n argocd

# Force refresh of root app
kubectl patch application skynet-root-app -n argocd --type='merge' -p='{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"now"}}}'

# Or manually apply
kubectl apply -f apps/workloads/mkdocs-docs/app.yaml
```

### If Pods Not Starting
```bash
# Check events
kubectl get events -n mkdocs-docs --sort-by='.lastTimestamp'

# Check if image exists
docker pull ghcr.io/cyberdine-skynet/skynet-platform/mkdocs:latest

# Check deployment status
kubectl describe deployment mkdocs-docs -n mkdocs-docs
```

### If Ingress Not Working
```bash
# Check if Traefik is running
kubectl get pods -n traefik-system

# Check if cert-manager is working
kubectl get certificates -n mkdocs-docs

# Check ingress details
kubectl describe ingress mkdocs-docs -n mkdocs-docs
```

## 📋 Next Steps

1. **Commit and Push** these configuration files
2. **Monitor Argo CD** for the new application
3. **Trigger Documentation Build** by including `[docs]` in commit message
4. **Verify Deployment** at https://docu.fle.api64.de

The MkDocs documentation will now be properly deployed and managed by Argo CD! 🎉
