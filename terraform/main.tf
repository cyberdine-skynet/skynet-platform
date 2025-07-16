# Create namespaces
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name"    = "argocd"
      "app.kubernetes.io/part-of" = "skynet-platform"
    }
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace
    labels = {
      "app.kubernetes.io/name"    = "cert-manager"
      "app.kubernetes.io/part-of" = "skynet-platform"
    }
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.traefik_namespace
    labels = {
      "app.kubernetes.io/name"    = "traefik"
      "app.kubernetes.io/part-of" = "skynet-platform"
    }
  }
}

# Install Argo CD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values/argocd-values.yaml", {
      domain                    = var.domain
      github_oauth_client_id    = var.github_oauth_client_id
      github_oauth_client_secret = var.github_oauth_client_secret
      github_org               = var.github_org
    })
  ]

  depends_on = [
    module.secrets
  ]
}

# Secrets module
module "secrets" {
  source = "./modules/secrets"
  
  namespace                   = var.argocd_namespace
  github_pat                 = var.github_pat
  github_oauth_client_id     = var.github_oauth_client_id
  github_oauth_client_secret = var.github_oauth_client_secret
  github_org                 = var.github_org
  github_repo                = var.github_repo
  domain                     = var.domain
  admin_teams               = var.argocd_admin_teams
  developer_teams           = var.argocd_developer_teams
  
  depends_on = [kubernetes_namespace.argocd]
}

# Deploy the root App-of-Apps
resource "kubectl_manifest" "root_app" {
  yaml_body = templatefile("${path.module}/../apps/root-app.yaml", {
    github_org  = var.github_org
    github_repo = var.github_repo
  })

  depends_on = [helm_release.argocd]
}
