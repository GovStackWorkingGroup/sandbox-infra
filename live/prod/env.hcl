locals {
  account_name   = "SandboxProd"
  aws_account_id = "557833966917" # TODO: replace me with your AWS account ID!
  aws_profile    = "prod"
  environment = "prod"

  aws_region = "eu-central-1"
  product = "sandbox"

  # versions
  eks_version = "1.24"

  # EKS inputs
 #cluster_name = "Govstack-${local.product}-cluster-${local.environment}"
  cluster_name = "Govstack-${local.product}-cluster-${local.environment}"

}