# Traefik - Ingress Controller & Load Balancer

## 📋 Overview

Traefik is our cloud-native ingress controller that provides HTTP/HTTPS routing, load balancing, and TLS termination for all services in the Skynet Platform.

## 🚀 Deployment Details

- **Namespace**: `traefik-system`
- **Version**: v3.1.5 (Chart: 32.1.0)
- **Deployment Method**: Argo CD + Helm
- **LoadBalancer IP**: 192.168.1.201 (via MetalLB)

## 🌐 Access Methods

### Dashboard

```bash
# Via LoadBalancer
URL: http://192.168.1.201:9000/dashboard/

# Via NodePort
URL: http://192.168.1.175:32170/dashboard/

# Via Port-Forward (if external access issues)
kubectl port-forward -n traefik-system svc/traefik 8080:9000
URL: http://localhost:8080/dashboard/
```

### API Endpoints

```bash
# Routers
http://192.168.1.201:9000/api/http/routers

# Services
http://192.168.1.201:9000/api/http/services

# Overview
http://192.168.1.201:9000/api/overview
```

## 🏗️ Architecture & Features

### Core Capabilities

- **HTTP/HTTPS Routing**: Automatic routing based on host/path rules
- **TLS Termination**: Automatic HTTPS with cert-manager integration
- **Load Balancing**: Multiple algorithms (round-robin, weighted, etc.)
- **Middleware Support**: Rate limiting, auth, compression, etc.
- **Service Discovery**: Kubernetes Ingress & CRD integration

### Configuration

```yaml
# Key configuration highlights
ports:
  web: 80        # HTTP traffic
  websecure: 443 # HTTPS traffic
  traefik: 9000  # Dashboard & API

# Global redirect HTTP → HTTPS
globalArguments:
  - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
  - "--entrypoints.web.http.redirections.entrypoint.scheme=https"

# Providers
providers:
  kubernetesIngress: enabled    # Standard Ingress resources
  kubernetesCRD: enabled        # Traefik IngressRoute CRDs
```

## 📁 Configuration Files

```
apps/workloads/traefik/app.yaml    # Argo CD application
# Contains Helm values configuration
```

## 🔧 Common Commands

### Check Status

```bash
# Traefik pods
kubectl get pods -n traefik-system

# Service and LoadBalancer
kubectl get svc -n traefik-system

# Ingress resources
kubectl get ingress --all-namespaces
kubectl get ingressroutes --all-namespaces
```

### Logs and Debugging

```bash
# Traefik logs
kubectl logs -n traefik-system deployment/traefik

# Follow logs
kubectl logs -n traefik-system deployment/traefik -f

# Specific container logs
kubectl logs -n traefik-system pod/<pod-name> -c traefik
```

### Configuration Testing

```bash
# Test HTTP routing
curl -H "Host: example.com" http://192.168.1.201

# Test HTTPS redirect
curl -I http://192.168.1.201
# Should return 301 redirect to HTTPS

# Test specific service
curl -H "Host: test.local" http://192.168.1.201
```

## 🌍 Service Exposure Examples

### Standard Kubernetes Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
```

### Traefik IngressRoute (CRD)

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-app
spec:
  entryPoints:
  - web
  - websecure
  routes:
  - match: Host(`my-app.example.com`)
    kind: Rule
    services:
    - name: my-app
      port: 80
  tls:
    certResolver: letsencrypt
```

## 🔐 TLS/SSL Configuration

### cert-manager Integration

Traefik is configured to work with cert-manager for automatic TLS certificates:

```yaml
# Certificate resolver for Let's Encrypt
certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: /data/acme.json
      caServer: https://acme-v02.api.letsencrypt.org/directory
      httpChallenge:
        entryPoint: web
```

### TLS Configuration

- **Automatic HTTPS**: All HTTP traffic redirected to HTTPS
- **Let's Encrypt**: Automatic certificate provisioning
- **Certificate Storage**: Persistent storage for ACME certificates

## 📊 Monitoring & Metrics

### Prometheus Metrics

```yaml
metrics:
  prometheus:
    enabled: true
    addEntryPointsLabels: true
    addServicesLabels: true
```

Access metrics at: `http://192.168.1.201:9000/metrics`

### Access Logs

```yaml
logs:
  general:
    level: INFO
  access:
    enabled: true
```

## 🚨 Troubleshooting Guide

### Service Not Accessible

1. **Check Ingress Configuration**:

   ```bash
   kubectl get ingress <ingress-name> -o yaml
   kubectl describe ingress <ingress-name>
   ```

2. **Check Traefik Routing**:

   ```bash
   # Via dashboard: http://192.168.1.201:9000/dashboard/
   # Or API: http://192.168.1.201:9000/api/http/routers
   ```

3. **Check Service Endpoints**:

   ```bash
   kubectl get endpoints <service-name>
   kubectl describe service <service-name>
   ```

### TLS Certificate Issues

1. **Check Certificate Status**:

   ```bash
   kubectl get certificates
   kubectl describe certificate <cert-name>
   ```

2. **Check cert-manager Logs**:

   ```bash
   kubectl logs -n cert-manager deployment/cert-manager
   ```

3. **Manual Certificate Request**:

   ```bash
   kubectl describe certificaterequest <request-name>
   ```

### LoadBalancer Issues

1. **Check MetalLB Status**:

   ```bash
   kubectl get pods -n metallb-system
   kubectl logs -n metallb-system deployment/metallb-controller
   ```

2. **Check IP Allocation**:

   ```bash
   kubectl get svc traefik -n traefik-system -o wide
   ```

### Performance Issues

1. **Resource Usage**:

   ```bash
   kubectl top pods -n traefik-system
   ```

2. **Scale Replicas**:

   ```bash
   kubectl scale deployment traefik --replicas=2 -n traefik-system
   ```

## 🔧 Configuration Customization

### Adding Middleware

```yaml
# In Traefik Helm values
additionalArguments:
  - "--api.dashboard=true"
  - "--api.insecure=true"
  - "--metrics.prometheus=true"
```

### Custom Entry Points

```yaml
ports:
  custom:
    port: 8080
    expose: true
    exposedPort: 8080
```

## 🛡️ Security Features

- **TLS Termination**: Centralized TLS handling
- **Security Headers**: Configurable via middleware
- **Rate Limiting**: Built-in rate limiting capabilities
- **IP Whitelisting**: Source IP filtering
- **Basic Auth**: HTTP basic authentication

## 📚 References

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Kubernetes Ingress](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Traefik CRDs](https://doc.traefik.io/traefik/providers/kubernetes-crd/)
- [cert-manager Integration](https://cert-manager.io/docs/configuration/acme/http01/)

---

*Part of the Skynet Platform Infrastructure*
