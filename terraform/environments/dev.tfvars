# Development environment configuration
cluster_name = "skynet-dev"
domain       = "fle.api64.de"
github_org   = "cyberdine-skynet"
github_repo  = "skynet-platform"

# These will be prompted or set via environment variables
# github_pat                 = "github_pat_..." 
# github_oauth_client_id     = "Ov23li..."
# github_oauth_client_secret = "11630d..."

argocd_namespace       = "argocd"
cert_manager_namespace = "cert-manager"
traefik_namespace      = "traefik-system"

letsencrypt_email = "admin@fle.api64.de"

argocd_admin_teams     = ["admin", "maintainers"]
argocd_developer_teams = ["developers"]
