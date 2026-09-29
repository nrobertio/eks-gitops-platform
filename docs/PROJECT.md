# Project Writeup: EKS GitOps Platform

This document explains **why** the project exists, **how** it was built, **why each technology** was chosen, and the **benefits** it delivers. It doubles as the talking-track for discussing the project in interviews.

## 1. The problem it solves

Teams that run Kubernetes on AWS usually hit the same three problems:

1. **Manual, drift-prone operations.** People run `kubectl apply` by hand, so the cluster state no longer matches any file in Git. Nobody can say with certainty what is running.
2. **Weak guardrails.** Anyone can ship a container with no resource limits, a `:latest` tag, or from an untrusted registry. Small mistakes become production incidents.
3. **No repeatable delivery.** Environments (dev, staging, prod) drift apart because they are configured differently by hand.

This platform fixes all three by making **Git the single source of truth** and letting controllers reconcile the cluster to match it, with security enforced automatically at admission time.

## 2. How it was developed

The build followed a deliberate order, provisioning first, then delivery, then guardrails:

1. **Infrastructure as Code first.** Terraform provisions the VPC, EKS control plane, a managed node group and the OIDC provider for IRSA. This is the only step run by a human, once.
2. **GitOps bootstrap.** Argo CD is installed once, then a single root Application (the app-of-apps pattern) points at the `platform/` directory. From that moment, everything else is delivered by committing to Git.
3. **Workload delivery.** A sample service is packaged as a Helm chart (the Argo CD source of truth) and, separately, as a Kustomize base with per-environment overlays, to demonstrate both approaches.
4. **Security guardrails.** Kyverno policies are deployed as just another GitOps-managed component and enforce rules at admission time.
5. **CI in two ecosystems.** Pipelines for both GitLab CI/CD and GitHub Actions lint, validate and security-scan the code on every change.
6. **A second GitOps controller.** A Flux CD variant reconciles the same workload, to show the pattern is not tied to one tool.

Everything is committed with clean history and no secrets; Terraform state and any credentials are gitignored.

## 3. Why each technology

- **Terraform (not ClickOps):** the cluster and network are reproducible, reviewable and destroyable. Community modules (VPC, EKS) are pinned to major versions for stability.
- **Amazon EKS:** managed control plane removes the burden of running Kubernetes masters; OIDC enables IRSA.
- **IRSA (IAM Roles for Service Accounts):** pods get least-privilege AWS access scoped to a single service account, instead of broad node-wide credentials. This is the secure default on EKS.
- **Argo CD with app-of-apps:** one root Application manages every platform component. Adding a component is a one-file pull request; Argo CD reconciles and self-heals drift. Delivery becomes auditable through Git history.
- **Helm and Kustomize (both):** Helm for templated, parameterised packaging; Kustomize for overlay-based, template-free environment differences. Showing both demonstrates fluency and lets a reader pick the right tool per case.
- **Kyverno:** policy-as-code in plain YAML (no new language to learn, unlike some alternatives). Policies are version-controlled and delivered through the same GitOps flow they govern.
- **Flux CD (alongside Argo CD):** proves the GitOps model is portable across controllers and shows familiarity with both market leaders.
- **GitLab CI/CD and GitHub Actions:** most teams use one or the other; supporting both shows the pipeline design transfers. Both run tfsec (Terraform security) and Trivy (config and image scanning).

## 4. The DevSecOps guardrails, and why they matter

Kyverno enforces, at admission time (a bad manifest is rejected before it runs):

- **No `:latest` image tags** so deployments are reproducible and rollbacks are precise.
- **CPU and memory requests and limits required** so one workload cannot starve the node.
- **A required `app.kubernetes.io/name` label** so everything is discoverable and cost-attributable.
- **Approved registries only** so a typo or a supply-chain attack cannot pull an untrusted image.

These are the small, boring controls that prevent most real production incidents.

## 5. Benefits

- **Auditability:** every change to the platform is a Git commit with an author and a diff. There is a complete history of who changed what and when.
- **Consistency:** dev, staging and prod come from the same base, so "works in staging, breaks in prod" largely disappears.
- **Self-healing:** if someone changes the cluster by hand, Argo CD reverts it to match Git.
- **Security by default:** guardrails are enforced automatically, not left to reviewer memory.
- **Fast, safe onboarding:** a new service is a pull request, not a runbook of manual steps.
- **Cost control:** required limits and labels make spend predictable and attributable, and the whole stack tears down with one `terraform destroy`.

## 6. Interview talking points

Be ready to explain, in your own words:

- Why GitOps beats `kubectl apply`: single source of truth, drift detection, self-heal, auditability.
- Why app-of-apps: one root manages many components; scaling the platform is a pull request.
- IRSA vs node instance roles: least privilege per workload rather than per node.
- Helm vs Kustomize: templating and packaging vs overlay-based, template-free customisation.
- How Kyverno stops a bad deploy: admission-time validation, and the specific rules above.
- What you would add next: sealed secrets or external-secrets, an ingress controller with TLS, progressive delivery (Argo Rollouts), and policy reporting.

## 7. How to run it

See the top-level `README.md` for the quick start: `terraform apply`, bootstrap Argo CD, then Argo CD reconciles the rest. Run `terraform destroy` when finished to stop incurring cost.