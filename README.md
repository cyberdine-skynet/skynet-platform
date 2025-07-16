# Skynet Platform

A Helm-based GitOps platform using Argo CD for managing Kubernetes applications and infrastructure.

## 🏗️ Architecture

This platform uses the App-of-Apps pattern to manage multiple applications through a single root application:

```text
skynet-platform/
├── apps/
│   ├── root-app.yaml              # Root App-of-Apps
│   ├── argocd/                    # Argo CD GitOps controller
│   ├── cert-manager/              # Certificate management
│   ├── traefik/                   # Ingress controller
│   └── cluster-issuer/            # TLS certificate issuers
├── SETUP.md                       # Setup instructions
├── GITHUB_SSO.md                  # GitHub SSO configuration
└── README.md
```

## 🚀 Quick Start

**Your platform is pre-configured and ready to deploy!**

1. **Deploy the complete platform:**

   ```bash
   ./deploy.sh
   ```

2. **Access Argo CD:**
   - **Domain**: `https://argocd.fle.api64.de` (once DNS is configured)
   - **NodePort**: `https://NODE_IP:30443`
   - **Port-forward**: `kubectl port-forward svc/argocd-server -n argocd 8080:443`

3. **Login with GitHub SSO:**
   - Use your GitHub account from the `cyberdine-skynet` organization
   - Or use the default admin account (get password with the deploy script)

## 📋 Applications

| Application | Namespace | Description | Wave |
|-------------|-----------|-------------|------|
| Argo CD | `argocd` | GitOps controller | 1 |
| Cert-Manager | `cert-manager` | Certificate management | 2 |
| Traefik | `traefik-system` | Ingress controller | 3 |
| Cluster Issuer | `cert-manager` | TLS certificate issuers | 4 |

## 🔧 Configuration

### Argo CD Features

- **NodePort Service**: Exposed on ports 30080 (HTTP) and 30443 (HTTPS)
- **GitHub SSO Ready**: Pre-configured for GitHub authentication
- **RBAC**: Role-based access control templates
- **Monitoring**: Prometheus metrics enabled

### Traefik Features

- **LoadBalancer Service**: With MetalLB support
- **Let's Encrypt**: Automatic TLS certificate management
- **Dashboard**: Available at `traefik.fle.api64.de`
- **High Availability**: 2 replicas with pod anti-affinity

### Cert-Manager Features

- **Multiple Issuers**: Let's Encrypt staging/prod and self-signed
- **Prometheus Monitoring**: Metrics collection enabled
- **Security**: Non-root containers with minimal privileges

## 🔒 Security

- GitHub SSO integration (see `GITHUB_SSO.md`)
- RBAC policies for fine-grained access control
- TLS encryption for all services
- Security contexts and pod security standards
- Network policies ready for implementation

## 📚 Documentation

- [Setup Guide](SETUP.md) - Detailed deployment instructions
- [GitHub SSO](GITHUB_SSO.md) - Single Sign-On configuration
- [Architecture](docs/architecture.md) - System design and components

## 🛠️ Customization

Each application can be customized by editing its `values.yaml` file:

- `apps/argocd/values.yaml` - Argo CD configuration
- `apps/traefik/values.yaml` - Traefik ingress settings
- `apps/cert-manager/values.yaml` - Certificate manager options

## 🔍 Monitoring

The platform includes built-in monitoring capabilities:

- Prometheus metrics for all components
- Service monitors for metric collection
- Dashboard access through ingress controllers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes in a development environment
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.