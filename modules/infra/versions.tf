terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "govstack-sandbox-terraform-dev"
    key    = "terraformstates"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}
