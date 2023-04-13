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
  cluster_name = "Govstack-${local.product}-cluster-${local.environment}"


 # CICD 
 provider = "https://oidc.circleci.com/org"
 org_id = ["a9a7f9cb-bb2c-4787-b2a7-b7963c3172f8"]
 ssl_thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}