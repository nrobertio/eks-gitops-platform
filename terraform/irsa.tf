# Example IRSA role: least-privilege IAM for a workload service account.
# Demonstrates the pattern used for external-dns, load balancer controller, etc.

data "aws_iam_policy_document" "demo_api_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:demo-api:demo-api"]
    }
  }
}

resource "aws_iam_role" "demo_api" {
  name               = "${var.cluster_name}-demo-api-irsa"
  assume_role_policy = data.aws_iam_policy_document.demo_api_assume.json
}

# Least-privilege: read-only access to one S3 prefix, as an example.
data "aws_iam_policy_document" "demo_api_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.cluster_name}-demo-api/*"]
  }
}

resource "aws_iam_role_policy" "demo_api" {
  name   = "demo-api-read"
  role   = aws_iam_role.demo_api.id
  policy = data.aws_iam_policy_document.demo_api_policy.json
}
