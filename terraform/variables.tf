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
