# Architecture

## Overview

This platform separates **provisioning** (done once with Terraform) from **delivery** (done continuously with GitOps). After the cluster exists, the Git repository is the single source of truth: Argo CD reconciles desired state from Git into the cluster, so there is no manual kubectl apply in normal operation.

## Provisioning layer (Terraform)

- **VPC**: three availability zones, public and private subnets, a single NAT gateway for cost control, tagged for Kubernetes load balancer discovery.
- **EKS**: managed control plane with the OIDC provider enabled for IRSA.
- **Managed node group**: t3.medium on-demand nodes, autoscaling range 2 to 4.
- **IRSA**: fine-grained IAM roles for service accounts, so pods get least-privilege AWS access without node-wide credentials.

## Delivery layer (GitOps)

Argo CD is installed once, then a single root Application (app-of-apps) points at platform/argocd-apps/. Each file there is an Argo CD Application that manages one platform component: kyverno, kube-prometheus-stack, and demo-api. Adding a component is a one-file pull request. Argo CD picks it up and reconciles it.

## Security (DevSecOps)

- **Kyverno cluster policies** enforce, at admission time: no :latest tags, CPU and memory requests and limits on every container, a required app.kubernetes.io/name label, and images only from approved registries.
- **Pipeline scanning**: tfsec on Terraform and Trivy on config and images, in both GitLab and GitHub pipelines.
- **IRSA** keeps AWS permissions least-privilege and per-workload.

## Delivery variants

The same demo workload is expressed three ways to show fluency: a Helm chart (the Argo CD source of truth), a Kustomize base with dev/staging/prod overlays, and a Flux CD variant under flux/ reconciling the same app with a different controller.
