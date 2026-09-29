# Flux CD variant

The same demo-api workload, delivered with Flux CD instead of Argo CD, to show fluency with both GitOps controllers.

Install Flux, then apply the cluster kustomization:

```bash
flux install
kubectl apply -k flux/clusters/dev
```

Flux watches this repo (GitRepository) and reconciles the Kustomize overlay (Kustomization) into the cluster.
