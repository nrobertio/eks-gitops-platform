output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "region" {
  value = var.region
}

output "demo_api_irsa_role_arn" {
  description = "Annotate the demo-api service account with this role ARN."
  value       = aws_iam_role.demo_api.arn
}

output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
}
