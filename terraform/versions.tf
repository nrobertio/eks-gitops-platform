terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }

  # For a real multi-account setup, use a remote backend:
  # backend "s3" {
  #   bucket         = "my-tfstate-bucket"
  #   key            = "eks-gitops-platform/terraform.tfstate"
  #   region         = "eu-central-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.cluster_name
      ManagedBy   = "terraform"
      Environment = "shared"
    }
  }
}
