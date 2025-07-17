# Skynet Platform - Command Reference Guide

## 🚀 Quick Access Commands

### Essential Service URLs

```bash
# Argo CD (GitOps Dashboard)
open http://192.168.1.175:30180

# Traefik Dashboard
open http://192.168.1.201:9000/dashboard/

# Get Argo CD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## 📊 Infrastructure Status Commands

### Overall Cluster Health

```bash
# All namespaces and pods
kubectl get pods --all-namespaces

# All applications in Argo CD
kubectl get applications -n argocd

# All LoadBalancer services
kubectl get svc --all-namespaces -o wide | grep LoadBalancer

# All ingress resources
kubectl get ingress --all-namespaces

# Node status
kubectl get nodes -o wide

# Cluster info
kubectl cluster-info
```

### Component-Specific Status

```bash
# Argo CD
kubectl get pods -n argocd
kubectl get applications -n argocd

# Traefik
kubectl get pods -n traefik-system
kubectl get svc traefik -n traefik-system
kubectl describe svc traefik -n traefik-system

# MetalLB
kubectl get pods -n metallb-system
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system

# cert-manager
kubectl get pods -n cert-manager
kubectl get clusterissuers
kubectl get certificates --all-namespaces

# Demo applications
kubectl get pods -n demo-app
kubectl get svc -n demo-app
```

## 🔄 GitOps Operations

### Application Management

```bash
# Sync specific application
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{}}}' --type merge

# Sync with prune (remove deleted resources)
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{"prune":true}}}' --type merge

# Refresh application (re-read from Git)
kubectl patch application <app-name> -n argocd \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"info":[{"name":"Reason","value":"Manual refresh"}]}}' \
  --type merge

# Get application details
kubectl describe application <app-name> -n argocd

# List all applications with status
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

### Git Workflow Commands

```bash
# Create feature branch
git checkout -b feature/<feature-name>

# Check status
git status

# Stage changes
git add .

# Commit changes
git commit -m "feat: <description>"

# Push branch
git push -u origin feature/<feature-name>

# Switch to main
git checkout main

# Pull latest
git pull origin main

# Merge feature branch
git merge feature/<feature-name>

# Push to main
git push origin main

# Delete feature branch
git branch -d feature/<feature-name>
```

## 🌐 Network & Connectivity Testing

### Service Connectivity

```bash
# Test Traefik LoadBalancer
curl -I http://192.168.1.201
curl -I http://192.168.1.201:9000/dashboard/

# Test Argo CD NodePort
curl -I http://192.168.1.175:30180

# Test internal service connectivity
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -I http://demo-app.demo-app.svc.cluster.local

# Test with specific host header
curl -H "Host: test.local" http://192.168.1.201

# Test HTTPS redirect
curl -I http://192.168.1.201  # Should return 301 redirect
```

### Network Debugging

```bash
# Check DNS resolution
nslookup 192.168.1.201
nslookup 192.168.1.175

# Check network connectivity
ping 192.168.1.201
ping 192.168.1.175

# Check ARP table (from node)
arp -a | grep 192.168.1.201

# Port scanning
nmap -p 80,443,9000 192.168.1.201
nmap -p 30180,30543 192.168.1.175
```

## 🔍 Troubleshooting Commands

### Log Analysis

```bash
# Argo CD logs
kubectl logs -n argocd deployment/argocd-server
kubectl logs -n argocd deployment/argocd-repo-server
kubectl logs -n argocd deployment/argocd-application-controller

# Traefik logs
kubectl logs -n traefik-system deployment/traefik
kubectl logs -n traefik-system deployment/traefik -f  # Follow logs

# MetalLB logs
kubectl logs -n metallb-system deployment/metallb-controller
kubectl logs -n metallb-system daemonset/metallb-speaker

# cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
kubectl logs -n cert-manager deployment/cert-manager-webhook
```

### Resource Inspection

```bash
# Describe resources for detailed info
kubectl describe application <app-name> -n argocd
kubectl describe pod <pod-name> -n <namespace>
kubectl describe svc <service-name> -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>

# Get resource YAML
kubectl get application <app-name> -n argocd -o yaml
kubectl get svc <service-name> -n <namespace> -o yaml

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### Performance Monitoring

```bash
# Resource usage
kubectl top nodes
kubectl top pods --all-namespaces
kubectl top pods -n <namespace>

# Storage usage
kubectl get pvc --all-namespaces

# Check resource limits
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Limits\|Requests"
```

## 🔐 Security & Secrets Management

### Secrets Operations

```bash
# List secrets
kubectl get secrets --all-namespaces

# Get secret value
kubectl get secret <secret-name> -n <namespace> -o jsonpath="{.data.<key>}" | base64 -d

# Create secret
kubectl create secret generic <secret-name> --from-literal=<key>=<value> -n <namespace>

# SOPS operations (if configured)
sops -e secrets/example-secret.yaml > secrets/example-secret.enc.yaml
sops -d secrets/example-secret.enc.yaml
```

### Certificate Management

```bash
# List certificates
kubectl get certificates --all-namespaces

# Check certificate status
kubectl describe certificate <cert-name> -n <namespace>

# Check certificate details from secret
kubectl get secret <cert-secret> -n <namespace> -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout

# List ClusterIssuers
kubectl get clusterissuers

# Check ACME challenges
kubectl get challenges --all-namespaces
```

## 🛠️ Maintenance Operations

### Scaling Operations

```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=<count> -n <namespace>

# Scale Argo CD components
kubectl scale deployment argocd-server --replicas=2 -n argocd
kubectl scale deployment argocd-repo-server --replicas=2 -n argocd

# Scale Traefik
kubectl scale deployment traefik --replicas=2 -n traefik-system
```

### Restart Operations

```bash
# Restart deployment
kubectl rollout restart deployment <deployment-name> -n <namespace>

# Restart specific components
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout restart deployment traefik -n traefik-system

# Check rollout status
kubectl rollout status deployment <deployment-name> -n <namespace>
```

### Cleanup Operations

```bash
# Delete failed pods
kubectl delete pod <pod-name> -n <namespace>

# Delete stuck applications (force)
kubectl patch application <app-name> -n argocd --type json --patch='[{"op": "remove", "path": "/metadata/finalizers"}]'

# Cleanup completed pods
kubectl delete pods --field-selector=status.phase=Succeeded --all-namespaces

# Cleanup evicted pods
kubectl delete pods --field-selector=status.phase=Failed --all-namespaces
```

## 📦 Backup & Recovery

### Configuration Backup

```bash
# Backup Argo CD applications
kubectl get applications -n argocd -o yaml > backup-argocd-apps.yaml

# Backup Kubernetes manifests
kubectl get all --all-namespaces -o yaml > backup-all-resources.yaml

# Backup specific resources
kubectl get configmaps --all-namespaces -o yaml > backup-configmaps.yaml
kubectl get secrets --all-namespaces -o yaml > backup-secrets.yaml

# Backup MetalLB configuration
kubectl get ipaddresspool -n metallb-system -o yaml > backup-metallb-pools.yaml
kubectl get l2advertisement -n metallb-system -o yaml > backup-metallb-l2.yaml

# Backup cert-manager issuers
kubectl get clusterissuers -o yaml > backup-cert-issuers.yaml
```

### Disaster Recovery

```bash
# Restore from backup
kubectl apply -f backup-argocd-apps.yaml
kubectl apply -f backup-metallb-pools.yaml
kubectl apply -f backup-cert-issuers.yaml

# Force recreate from Git (GitOps recovery)
kubectl delete application <app-name> -n argocd
# Then re-apply from Git repository
```

## 🔧 Development & Testing

### Port Forwarding

```bash
# Traefik dashboard
kubectl port-forward -n traefik-system svc/traefik 8080:9000

# Argo CD (if NodePort not accessible)
kubectl port-forward -n argocd svc/argocd-server 8081:80

# Demo application
kubectl port-forward -n demo-app svc/demo-app 8082:80

# Access forwarded services
open http://localhost:8080/dashboard/  # Traefik
open http://localhost:8081             # Argo CD
open http://localhost:8082             # Demo app
```

### Quick Testing

```bash
# Deploy test application
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-nginx
  template:
    metadata:
      labels:
        app: test-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-nginx
  namespace: default
spec:
  selector:
    app: test-nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Test internal connectivity
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://test-nginx.default.svc.cluster.local

# Cleanup test resources
kubectl delete deployment test-nginx
kubectl delete service test-nginx
```

## 📱 Monitoring Commands

### Metrics Collection

```bash
# Traefik metrics
curl http://192.168.1.201:9000/metrics

# cert-manager metrics
kubectl port-forward -n cert-manager svc/cert-manager 9402:9402 &
curl http://localhost:9402/metrics

# Kubernetes metrics
kubectl top nodes
kubectl top pods --all-namespaces --sort-by=cpu
kubectl top pods --all-namespaces --sort-by=memory
```

### Health Checks

```bash
# Overall cluster health
kubectl get cs  # Component status

# Node conditions
kubectl describe nodes

# Pod readiness and liveness
kubectl get pods --all-namespaces -o custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status,NAMESPACE:.metadata.namespace

# Service endpoints
kubectl get endpoints --all-namespaces
```

---

## 🚨 Emergency Procedures

### Complete Infrastructure Reset

```bash
# 1. Scale down Argo CD (stop sync)
kubectl scale deployment argocd-application-controller --replicas=0 -n argocd

# 2. Delete all applications
kubectl delete applications --all -n argocd

# 3. Redeploy from Terraform
cd terraform
terraform apply

# 4. Recreate root application
kubectl apply -f apps/root-app-simple.yaml

# 5. Scale up Argo CD
kubectl scale deployment argocd-application-controller --replicas=1 -n argocd
```

### Network Connectivity Issues

```bash
# Check MetalLB speaker distribution
kubectl get pods -n metallb-system -o wide

# Restart MetalLB if needed
kubectl rollout restart daemonset metallb-speaker -n metallb-system
kubectl rollout restart deployment metallb-controller -n metallb-system

# Check IP allocation
kubectl describe svc traefik -n traefik-system

# Manual IP release/reallocation (if needed)
kubectl patch svc traefik -n traefik-system -p '{"spec":{"type":"ClusterIP"}}'
kubectl patch svc traefik -n traefik-system -p '{"spec":{"type":"LoadBalancer"}}'
```

---

*Keep this reference handy for daily operations and troubleshooting!*
