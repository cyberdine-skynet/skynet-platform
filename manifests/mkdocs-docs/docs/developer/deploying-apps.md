# Deploying Applications

This guide covers the step-by-step process for deploying applications to the Skynet Platform.

## Application Deployment Workflow

The Skynet Platform follows a GitOps deployment model:

1. **Code** → Application code and Dockerfile
2. **Build** → Container image built and pushed to registry
3. **Configure** → Kubernetes manifests and ArgoCD application
4. **Deploy** → Git commit triggers automatic deployment
5. **Monitor** → Observe application health and performance

## Application Types

### Stateless Applications

Most web applications, APIs, and microservices:

- Use Deployment resource
- Horizontal Pod Autoscaler for scaling
- Service for internal communication
- Ingress for external access

### Stateful Applications

Databases, message queues, and applications requiring persistent storage:

- Use StatefulSet resource
- Persistent Volume Claims for storage
- Headless services for stable network identities
- Consider using operators for complex stateful workloads

### Background Jobs

Batch jobs and scheduled tasks:

- Use Job resource for one-time tasks
- Use CronJob resource for scheduled tasks
- Consider resource limits and cleanup policies

## Application Configuration

### Environment-Specific Configuration

Use different approaches based on your needs:

**ConfigMaps** for non-sensitive configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "db.example.com"
  log.level: "INFO"
  feature.enabled: "true"
```

**Secrets** for sensitive data:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  database.password: "your-password"
  api.key: "your-api-key"
```

**Environment Variables** in deployment:

```yaml
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DATABASE_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database.password
```

### Resource Management

Always specify resource requests and limits:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

**Guidelines:**

- Requests: Minimum resources needed
- Limits: Maximum resources allowed
- Memory limits prevent OOM kills of other pods
- CPU limits prevent resource contention

### Health Checks

Implement proper health checks:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## Networking and Ingress

### Internal Services

For service-to-service communication:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### External Access

For public-facing applications:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.middlewares: default-security-headers@kubernetescrd
spec:
  tls:
  - hosts:
    - app.example.com
    secretName: app-tls
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Database and Storage

### Persistent Volumes

For applications requiring persistent storage:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-path
```

Mount in deployment:

```yaml
spec:
  template:
    spec:
      containers:
      - name: app
        volumeMounts:
        - name: app-data
          mountPath: /data
      volumes:
      - name: app-data
        persistentVolumeClaim:
          claimName: app-storage
```

### Database Connections

Use services to connect to databases:

```yaml
# Database connection example
DATABASE_URL: postgresql://username:password@postgres-service:5432/dbname
```

## Security Considerations

### Pod Security Context

Run containers as non-root:

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: app
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
```

### Network Policies

Control network traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Scaling and Performance

### Horizontal Pod Autoscaler

Automatically scale based on resource usage:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Pod Disruption Budget

Ensure availability during updates:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: myapp
```

## Monitoring and Observability

### Metrics

Expose application metrics:

```yaml
# Add to service
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

### Logging

Configure structured logging:

```yaml
# Environment variables for logging
- name: LOG_LEVEL
  value: "INFO"
- name: LOG_FORMAT
  value: "json"
```

## Deployment Strategies

### Rolling Updates

Default strategy for zero-downtime deployments:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

### Blue-Green Deployments

Use ArgoCD's built-in support or implement manually:

```yaml
# Use different labels for blue/green versions
metadata:
  labels:
    app: myapp
    version: blue  # or green
```

## Troubleshooting Deployments

### Common Issues

1. **Image Pull Errors**
   - Check image name and tag
   - Verify registry access
   - Check image pull secrets

2. **Resource Constraints**
   - Review resource requests/limits
   - Check node capacity
   - Monitor resource usage

3. **Health Check Failures**
   - Verify health endpoints
   - Check startup times
   - Review probe configuration

4. **Network Issues**
   - Test service connectivity
   - Check ingress configuration
   - Verify DNS resolution

### Debugging Commands

```bash
# Check pod status
kubectl get pods -n namespace

# View pod logs
kubectl logs -f pod-name -n namespace

# Describe resources
kubectl describe pod pod-name -n namespace
kubectl describe service service-name -n namespace

# Check events
kubectl get events -n namespace --sort-by='.lastTimestamp'

# Test connectivity
kubectl exec -it pod-name -n namespace -- curl service-name
```

## Next Steps

- Review [Best Practices](best-practices.md) for production deployments
- Learn about [GitOps Workflow](gitops-workflow.md) patterns
- Explore [Examples](examples.md) of common application patterns
