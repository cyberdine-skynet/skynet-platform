# Developer Onboarding Guide

Welcome to the Skynet Platform! This guide will help you get started with deploying applications using our GitOps workflow.

## Prerequisites

Before you begin, ensure you have:

- Access to the Skynet Platform git repository
- Basic knowledge of Kubernetes concepts
- Familiarity with YAML configuration files
- Git command line tools installed

## Platform Overview

The Skynet Platform uses a GitOps approach where:

1. **Everything is code**: All configurations are stored in Git
2. **Automated deployments**: Changes to Git trigger automatic deployments
3. **Declarative configuration**: You describe what you want, not how to get there
4. **Self-healing**: The platform automatically corrects drift from desired state

## Quick Start: Deploy Your First Application

### Step 1: Create Application Manifests

Create your Kubernetes manifests in the appropriate directory structure:

```text
apps/workloads/your-app/
├── app.yaml              # ArgoCD Application definition
└── manifests/
    ├── deployment.yaml   # Kubernetes Deployment
    ├── service.yaml      # Kubernetes Service
    └── ingress.yaml      # Traefik Ingress (optional)
```

### Step 2: ArgoCD Application Definition

Create `apps/workloads/your-app/app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: your-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/cyberdine-skynet/skynet-platform
    targetRevision: HEAD
    path: manifests/your-app
  destination:
    server: https://kubernetes.default.svc
    namespace: your-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### Step 3: Kubernetes Manifests

Create your application manifests in `manifests/your-app/`:

**deployment.yaml**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: your-app
  namespace: your-namespace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: your-app
  template:
    metadata:
      labels:
        app: your-app
    spec:
      containers:
      - name: your-app
        image: your-registry/your-app:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

**service.yaml**:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: your-app
  namespace: your-namespace
spec:
  selector:
    app: your-app
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
  type: ClusterIP
```

**ingress.yaml** (if you need external access):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: your-app
  namespace: your-namespace
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
  - hosts:
    - your-app.example.com
    secretName: your-app-tls
  rules:
  - host: your-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: your-app
            port:
              number: 80
```

### Step 4: Commit and Deploy

1. Create a feature branch:

   ```bash
   git checkout -b feature/deploy-your-app
   ```

2. Add your files:

   ```bash
   git add apps/workloads/your-app/
   git add manifests/your-app/
   ```

3. Commit with co-author:

   ```bash
   git commit -m "Deploy your-app to skynet platform

   Co-authored-by: francesco2323 <francesco2323@users.noreply.github.com>"
   ```

4. Push and create pull request:

   ```bash
   git push origin feature/deploy-your-app
   ```

5. After PR approval and merge, ArgoCD will automatically deploy your application!

## Monitoring Your Application

### ArgoCD Dashboard

1. Access ArgoCD UI: `https://argocd.skynet.local`
2. Find your application in the dashboard
3. Monitor sync status and health

### Checking Application Status

```bash
# Check pods
kubectl get pods -n your-namespace

# Check application logs
kubectl logs -f deployment/your-app -n your-namespace

# Check ingress
kubectl get ingress -n your-namespace
```

## Directory Structure Reference

Here's how the Skynet Platform repository is organized:

```text
skynet-platform/
├── apps/                    # ArgoCD Application definitions
│   ├── infrastructure/      # Core platform components
│   └── workloads/          # User applications
│       └── your-app/       # Your app ArgoCD definition
├── manifests/              # Kubernetes manifests
│   ├── infrastructure/     # Platform component manifests
│   └── your-app/          # Your app Kubernetes manifests
├── docs/                   # Documentation
└── terraform/             # Infrastructure as Code
```

## Best Practices

### Resource Management

- Always specify resource requests and limits
- Use appropriate resource values for your workload
- Consider using HPA for scaling

### Security

- Use non-root containers when possible
- Implement health checks (readiness/liveness probes)
- Follow least privilege principle
- Use network policies if needed

### Configuration

- Use ConfigMaps for configuration data
- Use Secrets for sensitive information
- Version your container images with tags (avoid `latest`)

### Monitoring

- Include appropriate labels for monitoring
- Expose metrics endpoints if applicable
- Configure proper logging

## Common Patterns

### Config and Secrets

```yaml
# ConfigMap example
apiVersion: v1
kind: ConfigMap
metadata:
  name: your-app-config
  namespace: your-namespace
data:
  app.properties: |
    database.host=db.example.com
    log.level=INFO

---
# Secret example
apiVersion: v1
kind: Secret
metadata:
  name: your-app-secrets
  namespace: your-namespace
type: Opaque
data:
  database.password: <base64-encoded-password>
```

### Health Checks

```yaml
# Add to your deployment container spec
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Troubleshooting

### Application Not Deploying

1. Check ArgoCD application status
2. Verify YAML syntax
3. Check namespace exists
4. Review resource quotas

### Application Not Accessible

1. Verify service is running: `kubectl get svc -n your-namespace`
2. Check ingress configuration: `kubectl get ingress -n your-namespace`
3. Verify DNS configuration
4. Check TLS certificate status

### Performance Issues

1. Check resource usage: `kubectl top pods -n your-namespace`
2. Review application logs
3. Check HPA status if configured
4. Monitor cluster resources

## Getting Help

- **ArgoCD Documentation**: Built-in help in ArgoCD UI
- **Kubernetes Documentation**: [kubernetes.io](https://kubernetes.io/docs/)
- **Platform Issues**: Create an issue in the platform repository
- **Slack**: #skynet-platform channel

## Next Steps

- Review [Best Practices](best-practices.md) for production deployments
- Learn about [GitOps Workflow](gitops-workflow.md) in detail
- Explore [Examples](examples.md) of common application patterns
- Check [Troubleshooting Guide](../operations/troubleshooting.md) for common issues
