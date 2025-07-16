# Skynet Platform Setup Guide

This guide helps you deploy and configure the Helm-based GitOps setup for the Skynet platform.

## Prerequisites

You'll need:

1. GitHub Personal Access Token (PAT) with repo access
2. GitHub OAuth App for SSO (optional but recommended)
3. Your repository URL updated in root-app.yaml

## Quick Setup Commands

### 1. Get initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. Port forward to access Argo CD (alternative to NodePort)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 3. Login via CLI

```bash
argocd login localhost:8080 --username admin --password <password-from-step-1> --insecure
```

### 4. Add your private repository

```bash
argocd repo add https://github.com/cyberdine-skynet/skynet-platform \
  --username your-github-username \
  --password your-github-pat
```

### 5. Deploy the root application

```bash
kubectl apply -f apps/root-app.yaml
```

## Access URLs (with NodePort)

- HTTP: `http://NODE_IP:30080`
- HTTPS: `https://NODE_IP:30443`

Replace `NODE_IP` with your Kubernetes node IP address.

## Security Notes

- The current configuration uses `--insecure` for development
- For production, configure proper TLS certificates
- Consider implementing GitHub SSO for better security
- Regularly rotate your GitHub PAT
