locals {
  account_name   = "SandboxQA"
  aws_account_id = "809246460732" # TODO: replace me with your AWS account ID!
  aws_profile    = "non-prod"
  environment = "qa"

  aws_region = "eu-central-1"
  product = "sandbox"

  # versions
  eks_version = "1.24"

  # EKS inputs
  cluster_name = "Govstack-${local.product}-cluster-${local.environment}"

}