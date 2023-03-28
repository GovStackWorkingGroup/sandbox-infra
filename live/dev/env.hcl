locals {

  account_name   = "SandboxDev"
  aws_account_id = "463471358064" 
  aws_profile    = "non-prod"
  environment = "dev"

  aws_region = "eu-central-1"
  product = "sandbox"

  # versions
  eks_version = "1.24"

  # EKS inputs
 #cluster_name = "Govstack-${local.product}-cluster-${local.environment}"
  cluster_name = "Govstack-${local.product}-cluster-${local.environment}"

}