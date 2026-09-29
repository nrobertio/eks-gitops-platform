# Bootstrap Argo CD

```bash
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd -n argocd

# Root app-of-apps: Argo CD now manages the whole platform from Git.
kubectl apply -f bootstrap/argocd/root-app.yaml

# Get the initial admin password:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

Replace the `repoURL` in root-app.yaml and the platform Applications with your fork before applying.
