# EKS GitOps Platform

A production-style platform-engineering reference built on **Amazon EKS**, delivered end to end with **GitOps**. It provisions the cluster with Terraform, bootstraps **Argo CD** using the app-of-apps pattern, deploys a sample service with both **Helm** and **Kustomize**, enforces security guardrails with **Kyverno**, and ships CI on both **GitLab CI/CD** and **GitHub Actions**. A **Flux CD** variant shows the same GitOps flow with a second controller.

> Maintained by [nrobertio](https://github.com/nrobertio). A hands-on reference for multi-account AWS platform engineering, GitOps and DevSecOps.

## What this demonstrates

- **Infrastructure as Code**: VPC, EKS, managed node groups, OIDC/IRSA in modular Terraform.
- **GitOps delivery**: Argo CD app-of-apps as the single root of truth for the whole platform.
- **Progressive config**: one app shipped two ways, a Helm chart and a Kustomize base plus dev/staging/prod overlays.
- **DevSecOps**: Kyverno cluster policies (no :latest, required resource limits, required labels, allowed registries) plus tfsec and Trivy scanning in CI.
- **CI/CD**: reusable GitLab and GitHub pipelines that lint, validate, scan and build.
- **Portability**: a Flux CD variant of the same delivery model.

## Architecture

See [docs/architecture.md](docs/architecture.md). High level:

```
Git (this repo)  ->  Argo CD (app-of-apps)  ->  EKS
                         |-- kyverno (policies)
                         |-- kube-prometheus-stack (observability)
                         |-- demo-api (Helm)  ->  dev / staging / prod
```

Terraform builds the cluster once. After that, every platform change is a Git commit that Argo CD reconciles. No manual kubectl apply in normal operation.

## Repository layout

```
terraform/            EKS cluster, VPC, IRSA (deploy this first)
bootstrap/argocd/     Argo CD install and the root app-of-apps
platform/             Argo CD Applications and Kyverno policies
apps/demo-api/        Sample service: source, Dockerfile, Helm chart, Kustomize overlays
flux/                 Flux CD variant of the same delivery
.github/workflows/    GitHub Actions CI
.gitlab-ci.yml        GitLab CI/CD pipeline
docs/                 Architecture and runbook
```

## Quick start

1. **Provision the cluster** (see terraform/README.md):
   ```bash
   cd terraform && terraform init && terraform apply
   aws eks update-kubeconfig --name eks-gitops-platform --region eu-central-1
   ```
2. **Bootstrap Argo CD** (see bootstrap/argocd/install.md):
   ```bash
   kubectl create namespace argocd
   helm repo add argo https://argoproj.github.io/argo-helm
   helm install argocd argo/argo-cd -n argocd
   kubectl apply -f bootstrap/argocd/root-app.yaml
   ```
3. Argo CD then reconciles everything under platform/ and apps/ automatically.

## Cost note

EKS plus two t3.medium nodes and a NAT gateway costs roughly a few USD per day. Run `terraform destroy` when finished. Everything is tagged so cost is easy to track.

## License

MIT. See [LICENSE](LICENSE).
