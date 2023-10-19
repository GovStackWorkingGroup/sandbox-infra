locals {
  account_name   = "SandboxQA"
  aws_account_id = "809246460732"
  aws_profile    = "non-prod"
  environment = "qa"

  aws_region = "eu-central-1"
  product = "sandbox"

  # versions
  eks_version = "1.28"

  # EKS inputs
  cluster_name = "Govstack-${local.product}-cluster-${local.environment}"

  # CircleCI
  org_id = "a9a7f9cb-bb2c-4787-b2a7-b7963c3172f8"
  ssl_thumbprints = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  
  projects = []
}