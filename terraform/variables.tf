variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "skynet-platform"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}
