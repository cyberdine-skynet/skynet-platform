variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "skynet-platform"
}

variable "domain" {
  description = "Base domain for the platform"
  type        = string
  default     = "fle.api64.de"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "cyberdine-skynet"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "skynet-platform"
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_oauth_client_id" {
  description = "GitHub OAuth App Client ID"
  type        = string
  sensitive   = true
}

variable "github_oauth_client_secret" {
  description = "GitHub OAuth App Client Secret"
  type        = string
  sensitive   = true
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "cert_manager_namespace" {
  description = "Namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "traefik_namespace" {
  description = "Namespace for Traefik"
  type        = string
  default     = "traefik-system"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
  default     = "admin@fle.api64.de"
}

variable "argocd_admin_teams" {
  description = "GitHub teams with admin access to Argo CD"
  type        = list(string)
  default     = ["admin", "maintainers"]
}

variable "argocd_developer_teams" {
  description = "GitHub teams with developer access to Argo CD"
  type        = list(string)
  default     = ["developers"]
}

# Infrastructure and platform variables
variable "infrastructure_type" {
  description = "Type of infrastructure (baremetal-talos, cloud-managed, etc.)"
  type        = string
  default     = "baremetal-talos"
}

variable "cluster_type" {
  description = "Cluster configuration type"
  type        = string
  default     = "single-node"
  validation {
    condition     = contains(["single-node", "multi-node"], var.cluster_type)
    error_message = "Cluster type must be either 'single-node' or 'multi-node'."
  }
}

variable "storage_class" {
  description = "Default storage class for persistent volumes"
  type        = string
  default     = "local-path"
}

variable "node_port_range" {
  description = "NodePort range for services"
  type        = string
  default     = "30000-32767"
}

variable "letsencrypt_server" {
  description = "Let's Encrypt ACME server URL"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

# Resource management variables
variable "enable_resource_quotas" {
  description = "Enable resource quotas for namespaces"
  type        = bool
  default     = true
}

variable "default_cpu_limit" {
  description = "Default CPU limit for containers"
  type        = string
  default     = "2000m"
}

variable "default_memory_limit" {
  description = "Default memory limit for containers"
  type        = string
  default     = "4Gi"
}

# High availability and scaling variables
variable "enable_pod_disruption_budgets" {
  description = "Enable pod disruption budgets (disable for single-node)"
  type        = bool
  default     = false
}

variable "enable_affinity_rules" {
  description = "Enable pod affinity/anti-affinity rules"
  type        = bool
  default     = false
}

# Monitoring and observability variables
variable "enable_metrics" {
  description = "Enable Prometheus metrics collection"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana dashboard deployment"
  type        = bool
  default     = false
}
