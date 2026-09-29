# Terraform: EKS cluster

Provisions the VPC, EKS control plane, a managed node group and the OIDC provider for IRSA. Uses the official community modules pinned to major versions.

## Usage

```bash
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name eks-gitops-platform --region eu-central-1
```

Copy `terraform.tfvars.example` to `terraform.tfvars` to override defaults. Remote state is left local here for simplicity; in a real account use an S3 backend with a DynamoDB lock table (a commented block is in versions.tf).

Run `terraform destroy` when finished to stop incurring cost.
