# GitHub SSO Configuration for Argo CD

This file contains templates and instructions for setting up GitHub Single Sign-On (SSO) with your Argo CD deployment.

## ✅ Step 1: GitHub OAuth App - CONFIGURED

Your GitHub OAuth App is already configured with:
- **Client ID**: `Ov23liD7vhKxvYHgF1WE`
- **Client Secret**: `11630d854dd2d4bf9a46572e8e81575ba8a0d6c5`
- **Callback URL**: `https://argocd.fle.api64.de/api/dex/callback`

## ✅ Step 2: Repository Access - CONFIGURED

Your GitHub PAT is configured for repository access:
- **Token**: `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`

## 🚀 Ready to Deploy

Your platform is now fully configured with GitHub integration. Simply run:

```bash
./deploy.sh
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.fle.api64.de
  dex.config: |
    connectors:
      - type: github
        id: github
        name: GitHub
        config:
          clientID: YOUR_GITHUB_CLIENT_ID
          clientSecret: YOUR_GITHUB_CLIENT_SECRET
          orgs:
            - name: cyberdine-skynet
              teams:
                - YOUR_TEAM_NAME
          teamNameField: slug
          useLoginAsID: false
```

## Step 3: Configure RBAC

Update the RBAC configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
data:
  policy.default: role:readonly
  policy.csv: |
    # Admin access for GitHub organization owners
    g, cyberdine-skynet:admin, role:admin
    
    # Developer access for specific teams
    g, cyberdine-skynet:developers, role:developer
    
    # Custom role definitions
    p, role:developer, applications, get, */*, allow
    p, role:developer, applications, sync, */*, allow
    p, role:developer, repositories, get, *, allow
    p, role:developer, logs, get, */*, allow
    
    # Admin role (has all permissions)
    p, role:admin, *, *, *, allow
```

## Step 4: Apply Configuration

```bash
# Apply the updated ConfigMaps
kubectl apply -f github-sso-config.yaml

# Restart Argo CD components to pick up the changes
kubectl rollout restart deployment argocd-dex-server -n argocd
kubectl rollout restart deployment argocd-server -n argocd
```

## Step 5: Configure Repository Access

For private repositories, create a secret with your GitHub credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/cyberdine-skynet/skynet-platform
  username: YOUR_GITHUB_USERNAME
  password: YOUR_GITHUB_PAT
```

## Security Best Practices

1. **Use HTTPS**: Always use HTTPS for production deployments
2. **Rotate Secrets**: Regularly rotate GitHub PATs and OAuth secrets
3. **Least Privilege**: Grant minimum necessary permissions to users
4. **Audit Logs**: Monitor Argo CD access logs regularly
5. **Network Security**: Restrict access to Argo CD using network policies

## Troubleshooting

### Common Issues

1. **OAuth Callback URL Mismatch**
   - Ensure the callback URL in GitHub matches your Argo CD URL exactly
   
2. **Team Access Issues**
   - Verify team names are correct (use team slug, not display name)
   - Check that users are members of the specified teams

3. **Repository Access**
   - Ensure GitHub PAT has correct permissions
   - Verify repository URL format is correct

### Debug Commands

```bash
# Check Dex logs
kubectl logs -n argocd deployment/argocd-dex-server

# Check server logs
kubectl logs -n argocd deployment/argocd-server

# Verify ConfigMaps
kubectl get configmap argocd-cm -n argocd -o yaml
kubectl get configmap argocd-rbac-cm -n argocd -o yaml
```
