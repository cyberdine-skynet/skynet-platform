# Development environment configuration for Talos OS bare metal
# Cluster: skynetcluster (talos-5kn-42d)
# Talos Version: v1.9.5
# Kubernetes: v1.32.3
# Node IP: 192.168.1.175

cluster_name = "skynetcluster"  # Match your actual cluster name
domain       = "fle.api64.de"
github_org   = "cyberdine-skynet"
github_repo  = "skynet-platform"

# Infrastructure type
infrastructure_type = "baremetal-talos"
cluster_type        = "single-node"  # Confirmed single control-plane node

# Node configuration
node_ip = "192.168.1.175"  # Your actual node IP
node_name = "talos-5kn-42d"  # Your actual node name

# These will be prompted or set via environment variables
# github_pat                 = "github_pat_..." 
# github_oauth_client_id     = "Ov23li..."
# github_oauth_client_secret = "11630d..."

# Kubernetes namespaces
argocd_namespace       = "argocd"
cert_manager_namespace = "cert-manager"
traefik_namespace      = "traefik-system"

# SSL/TLS configuration
letsencrypt_email = "admin@fle.api64.de"
letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"  # production
# letsencrypt_server = "https://acme-staging-v02.api.letsencrypt.org/directory"  # staging

# RBAC teams
argocd_admin_teams     = ["admin", "maintainers"]
argocd_developer_teams = ["developers"]

# Talos/Bare metal specific configuration
storage_class = "local-path"  # Default Talos storage class
node_port_range = "30000-32767"

# Resource limits optimized for NUC
enable_resource_quotas = true
default_cpu_limit     = "2000m"    # Adjust based on your NUC specs
default_memory_limit  = "4Gi"      # Adjust based on your NUC specs

# High availability settings
enable_pod_disruption_budgets = false  # Disable for single node
enable_affinity_rules        = false  # Disable for single node

# Monitoring and observability
enable_metrics = true
enable_grafana = false  # Can be enabled later
