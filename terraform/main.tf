# Create Argo CD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name"    = "argocd"
      "app.kubernetes.io/part-of" = "skynet-platform"
    }
  }
}

# Deploy Argo CD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.1.3"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}
