# cert-manager - TLS Certificate Management

## 📋 Overview

cert-manager automates the management and issuance of TLS certificates from various certificate authorities, including Let's Encrypt, in Kubernetes clusters.

## 🚀 Deployment Details

- **Namespace**: `cert-manager`
- **Version**: Latest (from official Helm chart)
- **Deployment Method**: Argo CD + Helm
- **Certificate Authority**: Let's Encrypt (staging & production)

## 🏗️ Architecture & Components

### Core Components

1. **cert-manager Controller**: Main certificate management logic
2. **cert-manager Webhook**: Validates and mutates cert-manager resources
3. **cert-manager CAInjector**: Injects CA bundles into resources

### Certificate Workflow

```
Certificate Request → ClusterIssuer → ACME Challenge → Let's Encrypt → TLS Certificate
```

## 📁 Configuration Files

```
apps/workloads/cert-manager/app.yaml              # Helm chart deployment
apps/workloads/cert-manager-issuers/app.yaml      # ClusterIssuer manifests
manifests/cert-manager-issuers/cluster-issuers.yaml # Let's Encrypt issuers
```

## 🔧 Certificate Issuers

### Let's Encrypt Staging

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: admin@example.com  # UPDATE THIS
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: traefik
```

### Let's Encrypt Production

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com  # UPDATE THIS
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

## 🔧 Common Commands

### Check Status

```bash
# cert-manager pods
kubectl get pods -n cert-manager

# ClusterIssuers
kubectl get clusterissuers

# Certificates
kubectl get certificates --all-namespaces

# Certificate requests
kubectl get certificaterequests --all-namespaces
```

### Certificate Management

```bash
# Describe certificate
kubectl describe certificate <cert-name> -n <namespace>

# Check certificate details
kubectl get secret <cert-secret> -o yaml

# Manual certificate creation
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: default
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
  dnsNames:
  - example.com
EOF
```

### Debugging

```bash
# cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Webhook logs
kubectl logs -n cert-manager deployment/cert-manager-webhook

# CAInjector logs
kubectl logs -n cert-manager deployment/cert-manager-cainjector

# Check certificate events
kubectl describe certificate <cert-name> -n <namespace>
```

## 🌍 Usage Examples

### Automatic Certificate with Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
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
```

### Manual Certificate Resource

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: my-app-tls
  namespace: default
spec:
  secretName: my-app-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - my-app.example.com
  - www.my-app.example.com
```

### Traefik IngressRoute with TLS

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-app
spec:
  entryPoints:
  - websecure
  routes:
  - match: Host(`my-app.example.com`)
    kind: Rule
    services:
    - name: my-app
      port: 80
  tls:
    certResolver: letsencrypt  # Configured in Traefik
```

## 📊 Certificate Monitoring

### Certificate Status

```bash
# List all certificates with status
kubectl get certificates --all-namespaces -o wide

# Check certificate ready status
kubectl get certificates --all-namespaces -o custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status,SECRET:.spec.secretName,ISSUER:.spec.issuerRef.name
```

### Certificate Expiration

```bash
# Check certificate expiration
kubectl get certificates --all-namespaces -o custom-columns=NAME:.metadata.name,EXPIRATION:.status.notAfter

# Certificate details from secret
kubectl get secret <cert-secret> -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```

## 🚨 Troubleshooting Guide

### Certificate Not Issued

1. **Check ClusterIssuer Status**:

   ```bash
   kubectl describe clusterissuer <issuer-name>
   ```

2. **Check Certificate Status**:

   ```bash
   kubectl describe certificate <cert-name> -n <namespace>
   ```

3. **Check ACME Challenge**:

   ```bash
   kubectl get challenges --all-namespaces
   kubectl describe challenge <challenge-name> -n <namespace>
   ```

### ACME HTTP-01 Challenge Issues

1. **Verify Ingress Configuration**:

   ```bash
   kubectl get ingress --all-namespaces
   kubectl describe ingress <ingress-name> -n <namespace>
   ```

2. **Test Challenge Endpoint**:

   ```bash
   # ACME challenge is served at /.well-known/acme-challenge/
   curl http://example.com/.well-known/acme-challenge/<token>
   ```

3. **Check Traefik Routing**:

   ```bash
   # Verify in Traefik dashboard
   # http://192.168.1.201:9000/dashboard/
   ```

### Rate Limiting Issues

Let's Encrypt has rate limits:

- **Certificates per Registered Domain**: 50 per week
- **Duplicate Certificates**: 5 per week
- **Solution**: Use staging environment for testing

```bash
# Switch to staging issuer
kubectl patch certificate <cert-name> -n <namespace> --type='merge' -p='{"spec":{"issuerRef":{"name":"letsencrypt-staging"}}}'
```

### Webhook Issues

1. **Check Webhook Status**:

   ```bash
   kubectl get validatingwebhookconfiguration
   kubectl get mutatingwebhookconfiguration
   ```

2. **Webhook Logs**:

   ```bash
   kubectl logs -n cert-manager deployment/cert-manager-webhook
   ```

## ⚙️ Configuration Customization

### Custom CA Issuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair
```

### DNS-01 Challenge (for wildcard certificates)

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-dns
    solvers:
    - dns01:
        cloudflare:
          email: user@example.com
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
```

## 🔐 Security Considerations

### Private Key Security

- Private keys are stored as Kubernetes secrets
- Secrets should be encrypted at rest
- Consider using external secret management (SOPS)

### Certificate Rotation

- cert-manager automatically renews certificates
- Default renewal: 2/3 of certificate lifetime
- Monitor renewal events and failures

## 📚 References

- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [ACME Challenge Types](https://cert-manager.io/docs/configuration/acme/)
- [Traefik cert-manager Integration](https://cert-manager.io/docs/usage/ingress/)

---

*Part of the Skynet Platform Infrastructure*
