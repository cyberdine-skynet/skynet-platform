# Command Reference

This page contains essential commands for managing and operating the Skynet Platform.

## Quick Access

### Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| ArgoCD | `http://192.168.1.175:30180` | GitOps Dashboard |
| Traefik | `http://192.168.1.201:9000/dashboard/` | Load Balancer Dashboard |

### Get Admin Credentials

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Infrastructure Status

### Cluster Overview

```bash
# All namespaces and pods
kubectl get pods --all-namespaces

# All ArgoCD applications
kubectl get applications -n argocd

# All LoadBalancer services
kubectl get svc --all-namespaces -o wide | grep LoadBalancer

# All ingress resources
kubectl get ingress --all-namespaces

# Node status
kubectl get nodes -o wide

# Cluster information
kubectl cluster-info
```

### Component Status

**ArgoCD:**

```bash
kubectl get pods -n argocd
kubectl get applications -n argocd
```

**Traefik:**

```bash
kubectl get pods -n traefik-system
kubectl get svc traefik -n traefik-system
kubectl describe svc traefik -n traefik-system
```

**MetalLB:**

```bash
kubectl get pods -n metallb-system
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system
```

**cert-manager:**

```bash
kubectl get pods -n cert-manager
kubectl get clusterissuers
kubectl get certificates --all-namespaces
```

## GitOps Operations

### Application Management

**Sync Application:**

```bash
# Standard sync
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{}}}' --type merge

# Sync with prune (remove deleted resources)
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{"prune":true}}}' --type merge
```

**Refresh Application:**

```bash
# Refresh (re-read from Git)
kubectl patch application <app-name> -n argocd -p '{"operation":{"initiatedBy":{"username":"admin"},"info":[{"name":"Reason","value":"Manual refresh"}]}}' --type merge
```

**Application Information:**

```bash
# Get application details
kubectl describe application <app-name> -n argocd

# List all applications with status
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

### Git Workflow

**Branch Management:**

```bash
# Create feature branch
git checkout -b feature/<feature-name>

# Check status
git status

# Stage and commit changes
git add .
git commit -m "feat: <description>

Co-authored-by: francesco2323 <francesco2323@users.noreply.github.com>"

# Push branch
git push -u origin feature/<feature-name>
```

**Integration:**

```bash
# Switch to main
git checkout main

# Pull latest changes
git pull origin main

# Merge feature branch
git merge feature/<feature-name>

# Push to main
git push origin main

# Clean up feature branch
git branch -d feature/<feature-name>
```

## Network Testing

### Connectivity Tests

**External Access:**

```bash
# Test Traefik LoadBalancer
curl -I http://192.168.1.201
curl -I http://192.168.1.201:9000/dashboard/

# Test ArgoCD NodePort
curl -I http://192.168.1.175:30180
```

**Internal Connectivity:**

```bash
# Test service connectivity
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -I http://service-name.namespace.svc.cluster.local

# Test with specific host header
curl -H "Host: test.local" http://192.168.1.201
```

### Network Debugging

```bash
# Check DNS resolution
nslookup 192.168.1.201

# Test pod-to-pod communication
kubectl exec -it pod-name -n namespace -- ping other-pod-ip

# Check network policies
kubectl get networkpolicies --all-namespaces
```

## Application Debugging

### Pod Debugging

```bash
# Get pod status
kubectl get pods -n namespace

# Describe pod for events
kubectl describe pod pod-name -n namespace

# View pod logs
kubectl logs -f pod-name -n namespace

# Previous container logs (if crashed)
kubectl logs pod-name -n namespace --previous

# Execute commands in pod
kubectl exec -it pod-name -n namespace -- /bin/sh
```

### Service Debugging

```bash
# Check service endpoints
kubectl get endpoints service-name -n namespace

# Test service connectivity from within cluster
kubectl run debug --image=busybox --rm -it --restart=Never -- wget -qO- service-name.namespace.svc.cluster.local
```

### Resource Debugging

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n namespace

# Check resource quotas
kubectl get resourcequota -n namespace

# Check persistent volumes
kubectl get pv
kubectl get pvc -n namespace
```

## Certificate Management

### Check Certificate Status

```bash
# List all certificates
kubectl get certificates --all-namespaces

# Check specific certificate
kubectl describe certificate cert-name -n namespace

# Check certificate secret
kubectl get secret cert-name-tls -n namespace -o yaml
```

### Certificate Troubleshooting

```bash
# Check cert-manager logs
kubectl logs -f deployment/cert-manager -n cert-manager

# Check certificate requests
kubectl get certificaterequests -n namespace

# Check ACME challenges
kubectl get challenges -n namespace
```

## Backup and Recovery

### Configuration Backup

```bash
# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-applications.yaml

# Backup secrets
kubectl get secrets --all-namespaces -o yaml > cluster-secrets.yaml

# Backup configmaps
kubectl get configmaps --all-namespaces -o yaml > cluster-configmaps.yaml
```

### Disaster Recovery

```bash
# Restore ArgoCD applications
kubectl apply -f argocd-applications.yaml

# Force sync all applications
kubectl get applications -n argocd -o name | xargs -I {} kubectl patch {} -n argocd -p '{"operation":{"sync":{}}}' --type merge
```

## Performance Monitoring

### Resource Monitoring

```bash
# Monitor resource usage in real-time
watch kubectl top nodes
watch kubectl top pods --all-namespaces

# Check HPA status
kubectl get hpa --all-namespaces

# Check pod disruption budgets
kubectl get pdb --all-namespaces
```

### Event Monitoring

```bash
# Watch events in real-time
kubectl get events --all-namespaces --sort-by='.lastTimestamp' -w

# Filter events by type
kubectl get events --all-namespaces --field-selector type=Warning
```

## Security Operations

### Security Scanning

```bash
# Check pod security contexts
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.spec.securityContext}{"\n"}{end}'

# Check network policies
kubectl get networkpolicies --all-namespaces

# Check RBAC
kubectl get clusterroles
kubectl get clusterrolebindings
```

### Access Control

```bash
# Check user permissions
kubectl auth can-i --list --as=user@example.com

# Check service account permissions
kubectl auth can-i --list --as=system:serviceaccount:namespace:serviceaccount-name

# Verify cluster admin access
kubectl auth can-i "*" "*" --all-namespaces
```

## Emergency Procedures

### Application Recovery

```bash
# Restart deployment
kubectl rollout restart deployment/deployment-name -n namespace

# Scale deployment to zero and back
kubectl scale deployment deployment-name --replicas=0 -n namespace
kubectl scale deployment deployment-name --replicas=3 -n namespace

# Force delete stuck pod
kubectl delete pod pod-name -n namespace --grace-period=0 --force
```

### Cluster Recovery

```bash
# Drain node for maintenance
kubectl drain node-name --ignore-daemonsets --delete-emptydir-data

# Uncordon node after maintenance
kubectl uncordon node-name

# Check cluster health
kubectl get componentstatuses
```

## Useful Aliases

Add these to your shell profile for convenience:

```bash
# kubectl aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias kex='kubectl exec -it'

# ArgoCD specific
alias argoapp='kubectl get applications -n argocd'
alias argosync='kubectl patch application'

# Quick cluster overview
alias kpods='kubectl get pods --all-namespaces'
alias ksvc='kubectl get svc --all-namespaces'
alias kingress='kubectl get ingress --all-namespaces'
```
