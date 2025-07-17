# MetalLB - Bare Metal Load Balancer

## Overview

MetalLB provides LoadBalancer services for bare metal Kubernetes clusters, enabling external access to services
without cloud provider load balancers.

## Deployment Details

- **Namespace**: `metallb-system`
- **Version**: Latest (from official Helm chart)
- **Deployment Method**: Argo CD + Helm
- **Mode**: L2 Advertisement (Layer 2)

## Configuration

### IP Address Pool

```yaml
# IP Pool Configuration
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.200-192.168.1.220  # 20 available IPs
```

### L2 Advertisement

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
```

## Configuration Files

```text
apps/workloads/metallb/app.yaml              # Helm chart deployment
apps/workloads/metallb-config/app.yaml       # Configuration manifests
manifests/metallb-config/ip-pool.yaml        # IP pool & L2 advertisement
manifests/metallb-config/namespace.yaml      # Namespace with PodSecurity
```

## Common Commands

### Check Status

```bash
# MetalLB pods
kubectl get pods -n metallb-system

# IP address pools
kubectl get ipaddresspool -n metallb-system

# L2 advertisements
kubectl get l2advertisement -n metallb-system

# LoadBalancer services
kubectl get svc --all-namespaces -o wide | grep LoadBalancer
```

### Monitor IP Allocation

```bash
# Check which IPs are allocated
kubectl get svc --all-namespaces -o wide | grep LoadBalancer

# Check MetalLB controller logs
kubectl logs -n metallb-system deployment/metallb-controller

# Check speaker logs (L2 advertisement)
kubectl logs -n metallb-system daemonset/metallb-speaker
```

## Architecture

### Components

1. **Controller**: Manages IP allocation and configuration
2. **Speaker**: Announces IPs on the network (L2 mode)

### L2 Mode Operation

- **ARP/NDP**: Responds to ARP requests for allocated IPs
- **Failover**: Automatic failover between speaker nodes
- **Network**: Works on single subnet without special routing

## Security Configuration

### PodSecurity Policy

```yaml
# Namespace with privileged PodSecurity
apiVersion: v1
kind: Namespace
metadata:
  name: metallb-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
```

### RBAC

MetalLB requires elevated privileges for:

- Network interface manipulation
- ARP/NDP packet handling
- IP address binding

## Current Allocations

| Service | Namespace | Allocated IP | Status |
|---------|-----------|--------------|--------|
| traefik | traefik-system | 192.168.1.201 | ✅ Active |

Available IPs: 192.168.1.200, 192.168.1.202-192.168.1.220

## Troubleshooting Guide

### IP Not Allocated

1. **Check IP Pool Configuration**:

   ```bash
   kubectl get ipaddresspool -n metallb-system -o yaml
   ```

2. **Check Controller Logs**:

   ```bash
   kubectl logs -n metallb-system deployment/metallb-controller
   ```

3. **Verify Service Configuration**:

   ```bash
   kubectl describe svc <service-name>
   ```

### Service Not Reachable

1. **Check L2 Advertisement**:

   ```bash
   kubectl get l2advertisement -n metallb-system
   kubectl logs -n metallb-system daemonset/metallb-speaker
   ```

2. **Network Connectivity**:

   ```bash
   # From cluster node
   ping 192.168.1.201

   # ARP table
   arp -a | grep 192.168.1.201
   ```

3. **Speaker Node Status**:

   ```bash
   kubectl get pods -n metallb-system -o wide
   # Check which node is advertising the IP
   ```

### Configuration Issues

1. **Validate IP Pool**:

   ```bash
   kubectl describe ipaddresspool default-pool -n metallb-system
   ```

2. **Check Events**:

   ```bash
   kubectl get events -n metallb-system --sort-by='.lastTimestamp'
   ```

## Configuration Customization

### Multiple IP Pools

```yaml
# Production pool
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production-pool
spec:
  addresses:
  - 192.168.1.200-192.168.1.210

# Development pool
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: development-pool
spec:
  addresses:
  - 192.168.1.211-192.168.1.220
```

### Service-Specific Pool

```yaml
# Service annotation to specify pool
apiVersion: v1
kind: Service
metadata:
  annotations:
    metallb.universe.tf/address-pool: production-pool
spec:
  type: LoadBalancer
```

### Static IP Allocation

```yaml
# Request specific IP
apiVersion: v1
kind: Service
metadata:
  annotations:
    metallb.universe.tf/loadBalancer-class: metallb
    metallb.universe.tf/ip-allocated-from-pool: default-pool
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.1.205  # Specific IP request
```

## Network Requirements

### Subnet Configuration

- **Network**: 192.168.1.0/24
- **Gateway**: 192.168.1.1
- **MetalLB Range**: 192.168.1.200-192.168.1.220
- **Node IP**: 192.168.1.175

### Firewall Considerations

Ensure the following protocols are allowed:

- **ARP**: For IP address resolution
- **ICMP**: For network connectivity testing
- **Service Ports**: 80, 443, 9000, etc.

## Migration & Backup

### Configuration Backup

```bash
# Backup current configuration
kubectl get ipaddresspool -n metallb-system -o yaml > metallb-pools-backup.yaml
kubectl get l2advertisement -n metallb-system -o yaml > metallb-l2-backup.yaml
```

### IP Pool Updates

```bash
# Apply new pool configuration
kubectl apply -f manifests/metallb-config/ip-pool.yaml

# Check allocation changes
kubectl get svc --all-namespaces -o wide | grep LoadBalancer
```

## References

- [MetalLB Documentation](https://metallb.universe.tf/)
- [L2 Configuration](https://metallb.universe.tf/configuration/l2/)
- [Troubleshooting Guide](https://metallb.universe.tf/troubleshooting/)
