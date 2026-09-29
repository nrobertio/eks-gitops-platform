# demo-api

A tiny FastAPI service used to exercise the delivery paths. It exposes `/`, `/healthz` and `/readyz`, reads `APP_ENV` and `APP_VERSION` from the environment, and runs as a non-root user on port 8080.

Delivered three ways:
- **Helm**: `helm/` (the Argo CD source of truth).
- **Kustomize**: `kustomize/base` plus `kustomize/overlays/{dev,staging,prod}`.
- **Flux CD**: see `../../flux/`.

Build locally:
```bash
docker build -t demo-api:0.1.0 .
docker run -p 8080:8080 demo-api:0.1.0
```
