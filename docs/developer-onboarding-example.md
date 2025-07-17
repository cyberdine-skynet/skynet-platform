# Developer Onboarding Example

This comprehensive example shows how to deploy a complete application to the Skynet Platform using our GitOps infrastructure.

## 🎯 What We'll Build

We'll deploy a sample **Node.js API** application with:

- ✅ **GitOps deployment** via Argo CD
- ✅ **External access** via Traefik ingress
- ✅ **TLS certificates** via cert-manager
- ✅ **Security best practices** applied
- ✅ **Monitoring** integration ready

## 📋 Prerequisites

Before starting, ensure you have:

- Git access to the skynet-platform repository
- Basic understanding of Kubernetes concepts
- Docker image of your application (we'll use a sample Node.js app)

## 🚀 Step-by-Step Deployment Guide

### Step 1: Create Feature Branch

Following our GitOps workflow, always start with a feature branch:

```bash
# Clone the repository if you haven't already
git clone https://github.com/cyberdine-skynet/skynet-platform.git
cd skynet-platform

# Create and switch to feature branch
git checkout -b feature/deploy-sample-api

# Verify you're on the correct branch
git branch
```

### Step 2: Create Application Structure

Create the directory structure for your application:

```bash
# Create Argo CD application directory
mkdir -p apps/workloads/sample-api

# Create Kubernetes manifests directory
mkdir -p manifests/sample-api

# Verify structure
tree apps/workloads/sample-api
tree manifests/sample-api
```

### Step 3: Create Argo CD Application Definition

Create the Argo CD application that will manage your deployment:

**File: `apps/workloads/sample-api/app.yaml`**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-api
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "3"  # Deploy after infrastructure
  labels:
    app.kubernetes.io/name: sample-api
    app.kubernetes.io/component: application
    app.kubernetes.io/version: "1.0.0"
spec:
  destination:
    namespace: sample-api
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/cyberdine-skynet/skynet-platform.git
    targetRevision: HEAD
    path: manifests/sample-api
  syncPolicy:
    automated:
      prune: true      # Remove deleted resources
      selfHeal: true   # Auto-fix configuration drift
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
  revisionHistoryLimit: 10
```

### Step 4: Create Kubernetes Manifests

Create comprehensive Kubernetes resources following security best practices:

**File: `manifests/sample-api/namespace.yaml`**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sample-api
  labels:
    name: sample-api
    app.kubernetes.io/name: sample-api
    # Enable restricted PodSecurity for enhanced security
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**File: `manifests/sample-api/deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-api
  namespace: sample-api
  labels:
    app: sample-api
    component: backend
    version: "1.0.0"
spec:
  replicas: 2  # High availability
  selector:
    matchLabels:
      app: sample-api
  template:
    metadata:
      labels:
        app: sample-api
        component: backend
        version: "1.0.0"
    spec:
      # Security context for the pod
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534      # nobody user
        runAsGroup: 65534     # nobody group
        fsGroup: 65534
        seccompProfile:
          type: RuntimeDefault

      containers:
      - name: api
        # Sample Node.js API image (replace with your image)
        image: node:18-alpine
        command: ["/bin/sh"]
        args:
        - -c
        - |
          # Create a simple Node.js API for demonstration
          cat > server.js << 'EOF'
          const http = require('http');
          const port = process.env.PORT || 3000;

          const server = http.createServer((req, res) => {
            res.setHeader('Content-Type', 'application/json');

            if (req.url === '/health') {
              res.writeHead(200);
              res.end(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }));
            } else if (req.url === '/api/info') {
              res.writeHead(200);
              res.end(JSON.stringify({
                app: 'Sample API',
                version: '1.0.0',
                platform: 'Skynet Platform',
                node: process.version,
                uptime: process.uptime()
              }));
            } else {
              res.writeHead(200);
              res.end(JSON.stringify({
                message: 'Welcome to Skynet Platform Sample API',
                endpoints: ['/health', '/api/info'],
                documentation: 'https://docs.skynet.local'
              }));
            }
          });

          server.listen(port, '0.0.0.0', () => {
            console.log(`Sample API server running on port ${port}`);
          });
          EOF

          # Start the server
          node server.js

        ports:
        - containerPort: 3000
          name: http
          protocol: TCP

        # Environment variables
        env:
        - name: PORT
          value: "3000"
        - name: NODE_ENV
          value: "production"

        # Security context for the container
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: false  # Node.js needs write access

        # Resource limits and requests
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi

        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3

        readinessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
```

**File: `manifests/sample-api/service.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-api
  namespace: sample-api
  labels:
    app: sample-api
    component: backend
spec:
  type: ClusterIP
  selector:
    app: sample-api
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
```

**File: `manifests/sample-api/ingress.yaml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-api
  namespace: sample-api
  labels:
    app: sample-api
    component: ingress
  annotations:
    # Traefik configuration
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"

    # cert-manager configuration for automatic TLS
    cert-manager.io/cluster-issuer: letsencrypt-staging

    # Optional: Custom headers and middleware
    traefik.ingress.kubernetes.io/router.middlewares: sample-api-headers@kubernetescrd
spec:
  tls:
  - hosts:
    - api.skynet.local  # Replace with your domain
    secretName: sample-api-tls

  rules:
  - host: api.skynet.local  # Replace with your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-api
            port:
              number: 80
---
# Optional: Traefik middleware for security headers
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: sample-api-headers
  namespace: sample-api
spec:
  headers:
    customRequestHeaders:
      X-Forwarded-Proto: "https"
    customResponseHeaders:
      X-Frame-Options: "DENY"
      X-Content-Type-Options: "nosniff"
      Referrer-Policy: "strict-origin-when-cross-origin"
```

### Step 5: Deploy Using GitOps

Commit and deploy your application using our GitOps workflow:

```bash
# Stage all changes
git add .

# Commit with descriptive message
git commit -m "feat: add sample-api application deployment

🚀 New Application Deployment:
- Created Argo CD application definition for sample-api
- Added comprehensive Kubernetes manifests with security best practices
- Configured Traefik ingress with automatic TLS via cert-manager
- Implemented health checks and resource limits
- Added security middleware for enhanced protection

Features:
- Node.js API with health endpoints
- High availability with 2 replicas
- Restricted PodSecurity policies
- Automatic HTTPS with Let's Encrypt
- Production-ready configuration

Co-authored-by: francesco2323 <francesco2323@users.noreply.github.com>"

# Push to remote repository
git push -u origin feature/deploy-sample-api
```

### Step 6: Create Pull Request & Merge

1. **Create Pull Request** on GitHub:
   - Go to the repository on GitHub
   - Create a pull request from `feature/deploy-sample-api` to `main`
   - Add detailed description of the changes

2. **Review and Merge**:
   - Review the changes
   - Merge the pull request to `main`

3. **Automatic Deployment**:
   - Argo CD will automatically detect the changes
   - The application will be deployed within minutes

### Step 7: Verify Deployment

Monitor and verify your deployment:

```bash
# Check Argo CD application status
kubectl get applications -n argocd
kubectl describe application sample-api -n argocd

# Check pods and services
kubectl get pods -n sample-api
kubectl get svc -n sample-api
kubectl get ingress -n sample-api

# Check deployment logs
kubectl logs -n sample-api deployment/sample-api -f

# Test health endpoint
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- \
  curl http://sample-api.sample-api.svc.cluster.local/health
```

### Step 8: Test External Access

Test your application through the Traefik ingress:

```bash
# Test via LoadBalancer IP (with Host header)
curl -H "Host: api.skynet.local" http://192.168.1.201/

# Test API endpoints
curl -H "Host: api.skynet.local" http://192.168.1.201/api/info
curl -H "Host: api.skynet.local" http://192.168.1.201/health

# Test HTTPS (once certificate is issued)
curl -H "Host: api.skynet.local" https://192.168.1.201/ -k
```

## 🎉 Success Indicators

Your application is successfully deployed when you see:

- ✅ **Argo CD Application**: `Synced` and `Healthy` status
- ✅ **Pods Running**: All replicas are `Running` and `Ready`
- ✅ **Service Available**: ClusterIP assigned and endpoints populated
- ✅ **Ingress Working**: External access via LoadBalancer IP
- ✅ **TLS Certificate**: Automatic certificate provisioned by cert-manager

## 📊 Monitoring Your Application

### Argo CD Dashboard

Monitor deployment status in Argo CD:

```bash
# Access Argo CD dashboard
open http://192.168.1.175:30180

# Login credentials
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Traefik Dashboard

Monitor ingress routing in Traefik:

```bash
# Access Traefik dashboard
open http://192.168.1.201:9000/dashboard/

# Check HTTP routers and services
```

### Application Logs

Monitor application logs:

```bash
# Follow application logs
kubectl logs -n sample-api deployment/sample-api -f

# Get logs from specific pod
kubectl logs -n sample-api <pod-name> -f

# Check recent events
kubectl get events -n sample-api --sort-by='.lastTimestamp'
```

## 🛠️ Troubleshooting Common Issues

### Application Not Syncing

```bash
# Force sync the application
kubectl patch application sample-api -n argocd -p '{"operation":{"sync":{}}}' --type merge

# Check Argo CD application status
kubectl describe application sample-api -n argocd
```

### Pods Not Starting

```bash
# Check pod status and events
kubectl describe pod -n sample-api <pod-name>

# Check deployment status
kubectl rollout status deployment/sample-api -n sample-api

# View recent events
kubectl get events -n sample-api --sort-by='.lastTimestamp'
```

### Ingress Not Working

```bash
# Check ingress configuration
kubectl describe ingress sample-api -n sample-api

# Verify service endpoints
kubectl get endpoints -n sample-api

# Check Traefik routing (in dashboard)
open http://192.168.1.201:9000/dashboard/
```

### TLS Certificate Issues

```bash
# Check certificate status
kubectl get certificates -n sample-api
kubectl describe certificate sample-api-tls -n sample-api

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

## 🎯 Next Steps

Now that you've successfully deployed your first application, you can:

1. **Scale Your Application**: Modify replicas in the deployment
2. **Add Environment-Specific Configs**: Use ConfigMaps and Secrets
3. **Implement Monitoring**: Add Prometheus metrics
4. **Set Up Alerts**: Configure AlertManager rules
5. **Add Database**: Deploy PostgreSQL or other services
6. **Implement CI/CD**: Set up automated builds and deployments

## 📚 Additional Resources

- [Best Practices Guide](best-practices.md)
- [GitOps Workflow](gitops-workflow.md)
- [Troubleshooting Guide](../operations/troubleshooting.md)
- [Command Reference](../operations/commands.md)

---

**Congratulations! 🎉 You've successfully deployed your first application to the Skynet Platform using GitOps!**
