# MetalLB - Bare Metal Load Balancer

## Overview

MetalLB provides LoadBalancer services for bare metal Kubernetes clusters, enabling external access to services
without cloud provider load balancers.

## Deployment Details

- **Namespace**: `metallb-system`
- **Version**: Latest (from official Helm chart)
- **Deployment Method**: Argo CD + Helm
- **Mode**: L2 Advertisement (Layer 2)
- **Status**: ❌ **Deployed via Argo CD but NOT WORKING** - Requires complete redeployment

## 🚨 IMMEDIATE ACTION REQUIRED

**Current deployment is broken and needs to be completely removed and redeployed:**

### Step 1: Remove Current Broken Deployment

```bash
# Delete MetalLB application from Argo CD
kubectl delete application metallb -n argocd

# Remove MetalLB namespace and all resources
kubectl delete namespace metallb-system --force --grace-period=0

# Verify complete removal
kubectl get ns | grep metallb
kubectl get pods --all-namespaces | grep metallb
```

### Step 2: Fresh MetalLB Deployment

```bash
# Redeploy MetalLB via Argo CD with proper configuration
kubectl apply -f apps/workloads/metallb/app.yaml
kubectl apply -f apps/workloads/metallb-config/app.yaml

# Monitor deployment
kubectl get applications -n argocd | grep metallb
kubectl get pods -n metallb-system -w
```

### Step 3: Verify Working State

```bash
# Check all components are running
kubectl get pods -n metallb-system
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system

# Test with a LoadBalancer service
kubectl create service loadbalancer test-lb --tcp=80:80
kubectl get svc test-lb -o wide
# Should show EXTERNAL-IP from pool range

# Clean up test
kubectl delete svc test-lb
```

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

## Current Status & Issues

### ⚠️ Known Issues

**MetalLB is deployed via Argo CD but not functioning properly:**

1. **Load Balancer Services Pending**: Services remain in "Pending" state
2. **IP Allocation Failed**: No external IPs are being assigned
3. **Configuration Issues**: L2 advertisement may not be working correctly

### Current Allocations

| Service | Namespace | Allocated IP | Status |
|---------|-----------|--------------|--------|
| traefik | traefik-system | `<Pending>` | ❌ **Not Working** |

**Available IPs**: 192.168.1.200-192.168.1.220 (All unused due to configuration issues)

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

## Immediate Action Items

### � CRITICAL: Complete Redeployment Required

**The current MetalLB deployment is broken and must be completely removed and redeployed:**

1. **Delete Current Deployment**:
   ```bash
   # Remove from Argo CD
   kubectl delete application metallb -n argocd
   kubectl delete application metallb-config -n argocd

   # Force remove namespace
   kubectl delete namespace metallb-system --force --grace-period=0

   # Verify clean removal
   kubectl get ns | grep metallb
   kubectl get crd | grep metallb
   ```

2. **Fresh Deployment**:
   ```bash
   # Redeploy via Argo CD
   kubectl apply -f apps/workloads/metallb/app.yaml
   kubectl apply -f apps/workloads/metallb-config/app.yaml

   # Wait for deployment
   kubectl wait --for=condition=available --timeout=300s deployment/metallb-controller -n metallb-system
   ```

3. **Validation Steps**:
   ```bash
   # Verify all pods running
   kubectl get pods -n metallb-system

   # Check configuration applied
   kubectl get ipaddresspool,l2advertisement -n metallb-system

   # Test LoadBalancer service
   kubectl create service loadbalancer metallb-test --tcp=80:80
   kubectl get svc metallb-test -o wide
   # Should show EXTERNAL-IP from 192.168.1.200-220 range

   # Cleanup test
   kubectl delete svc metallb-test
   ```

### 🔧 Post-Deployment Verification

1. **Verify Argo CD Deployment**:
   ```bash
   # Check if MetalLB is deployed via Argo CD
   kubectl get applications -n argocd | grep metallb

   # Check application status
   kubectl describe application metallb -n argocd
   ```

2. **Validate Pod Status**:
   ```bash
   # Check if MetalLB pods are running
   kubectl get pods -n metallb-system

   # Check for any errors
   kubectl describe pods -n metallb-system
   ```

3. **Configuration Validation**:
   ```bash
   # Verify IP pool is created
   kubectl get ipaddresspool -n metallb-system

   # Verify L2 advertisement exists
   kubectl get l2advertisement -n metallb-system
   ```

4. **Test Service Creation**:
   ```bash
   # Check existing LoadBalancer services
   kubectl get svc --all-namespaces | grep LoadBalancer

   # Look for pending services
   kubectl get svc --all-namespaces | grep Pending
   ```

### 🚨 Priority Troubleshooting Steps

1. **Check MetalLB Controller Logs**:
   ```bash
   kubectl logs -n metallb-system deployment/metallb-controller --tail=50
   ```

2. **Check Speaker Logs**:
   ```bash
   kubectl logs -n metallb-system daemonset/metallb-speaker --tail=50
   ```

3. **Verify Network Configuration**:
   ```bash
   # Check if the IP range conflicts with existing network
   ip route show
   arp -a | grep 192.168.1
   ```

4. **Validate RBAC Permissions**:
   ```bash
   # Check if MetalLB has required permissions
   kubectl auth can-i --list --as=system:serviceaccount:metallb-system:controller
   kubectl auth can-i --list --as=system:serviceaccount:metallb-system:speaker
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
