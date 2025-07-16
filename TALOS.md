# Skynet Platform on Talos OS

This guide provides specific instructions for deploying the Skynet Platform on Talos OS bare metal infrastructure.

## 🏗️ Talos OS Optimizations

The platform has been specifically optimized for Talos OS with the following considerations:

### **Storage**
- Uses `local-path` storage class (default in Talos)
- Persistent volumes optimized for single-node clusters
- ACME certificate storage configured for local persistence

### **Networking**
- NodePort services for direct access without LoadBalancer
- Optimized for bare metal networking
- DNS configuration for your domain (`fle.api64.de`)

### **Resource Management**
- Conservative resource limits for NUC hardware
- Single-replica deployments for single-node clusters
- Pod disruption budgets disabled for single-node

### **Security**
- Talos-specific security contexts
- Non-root containers with minimal privileges
- Read-only root filesystems where possible

## 🚀 Quick Deployment

### Option 1: Terraform Deployment (Recommended)

```bash
# Deploy with Terraform
./terraform-deploy.sh
```

### Option 2: Direct Helm Deployment

```bash
# Deploy with the original script
./deploy.sh
```

## 📋 Prerequisites

### **Required Tools**
- `kubectl` - Kubernetes CLI
- `terraform` - Infrastructure as Code
- `talosctl` - Talos OS management (optional but recommended)

### **Talos Cluster Requirements**
- Talos OS cluster running Kubernetes
- `local-path` storage provisioner (included by default)
- Network access to the internet for image pulls
- DNS configuration capability for your domain

### **Network Configuration**
Your NUC should have:
- Static IP address
- Ports 30080, 30443, 30900 accessible
- Domain `fle.api64.de` with subdomains pointing to the NUC IP

## 🔧 Talos-Specific Configuration

### **Storage Classes**
```bash
# Check available storage classes
kubectl get storageclass

# The platform uses 'local-path' by default
# Verify it's available and set as default
kubectl get storageclass local-path
```

### **Node Information**
```bash
# Get node information
kubectl get nodes -o wide

# Check Talos version
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}'
```

### **Resource Monitoring**
```bash
# Monitor resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

## 🌐 Access Methods

### **1. NodePort Access (Immediate)**
- **Argo CD**: `https://YOUR_NUC_IP:30443`
- **Traefik**: `http://YOUR_NUC_IP:30900`

### **2. Domain Access (Requires DNS)**
- **Argo CD**: `https://argocd.fle.api64.de`
- **Traefik**: `https://traefik.fle.api64.de`

### **3. Port Forwarding (Development)**
```bash
# Argo CD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Traefik Dashboard
kubectl port-forward svc/traefik -n traefik-system 9000:9000
```

## 🔐 DNS Configuration

Configure your DNS provider to point these subdomains to your NUC's IP:

```
argocd.fle.api64.de    → YOUR_NUC_IP
traefik.fle.api64.de   → YOUR_NUC_IP
*.fle.api64.de         → YOUR_NUC_IP  (wildcard for future services)
```

### **Local Testing (Optional)**
Add to your `/etc/hosts` file for local testing:
```
YOUR_NUC_IP argocd.fle.api64.de
YOUR_NUC_IP traefik.fle.api64.de
```

## 🛠️ Troubleshooting

### **Common Talos Issues**

#### **Storage Problems**
```bash
# Check storage provisioner
kubectl get pods -n kube-system | grep local-path

# Check PVC status
kubectl get pvc --all-namespaces
```

#### **Network Issues**
```bash
# Check node IP and ports
kubectl get nodes -o wide
kubectl get svc --all-namespaces | grep NodePort
```

#### **Resource Constraints**
```bash
# Check resource usage
kubectl describe nodes
kubectl top pods --all-namespaces --sort-by=memory
```

### **Talos-Specific Commands**

#### **Check Talos Status**
```bash
# If talosctl is available
talosctl health
talosctl dashboard
```

#### **System Information**
```bash
# Get system info through kubectl
kubectl get nodes -o yaml | grep -A 20 "nodeInfo:"
```

### **Application Issues**

#### **Argo CD Not Starting**
```bash
# Check Argo CD pods
kubectl get pods -n argocd

# Check logs
kubectl logs -n argocd deployment/argocd-server
```

#### **Certificates Not Generating**
```bash
# Check cert-manager
kubectl get pods -n cert-manager
kubectl logs -n cert-manager deployment/cert-manager

# Check certificate requests
kubectl get certificaterequests --all-namespaces
kubectl get certificates --all-namespaces
```

## 📊 Performance Considerations

### **NUC Hardware Recommendations**
- **CPU**: Intel NUC with at least 4 cores
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: SSD with at least 100GB free space
- **Network**: Gigabit Ethernet connection

### **Resource Scaling**
The configuration is optimized for single-node deployments. To scale:

1. **Add more nodes**: Update `cluster_type = "multi-node"` in `dev.tfvars`
2. **Increase resources**: Adjust CPU/memory limits in the tfvars file
3. **Enable HA features**: Set `enable_pod_disruption_budgets = true`

## 🔄 Updates and Maintenance

### **Updating Applications**
```bash
# Sync all applications
kubectl patch app -n argocd --type merge -p='{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Force refresh specific app
kubectl patch app argocd -n argocd --type merge -p='{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

### **Terraform Updates**
```bash
# Update Terraform configuration
cd terraform
terraform plan -var-file="../environments/dev.tfvars"
terraform apply
```

### **Talos Updates**
```bash
# If using talosctl, you can update Talos OS
talosctl upgrade --nodes YOUR_NODE_IP
```

## 📚 Additional Resources

- [Talos Documentation](https://www.talos.dev/docs/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)

## 🆘 Support

If you encounter issues specific to the Talos deployment:

1. Check the troubleshooting section above
2. Review Talos system logs: `talosctl logs`
3. Check Kubernetes events: `kubectl get events --sort-by=.metadata.creationTimestamp`
4. Verify network connectivity and DNS resolution
