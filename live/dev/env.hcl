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

  # CircleCI
  org_id = "a9a7f9cb-bb2c-4787-b2a7-b7963c3172f8"
  ssl_thumbprints = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  
  projects = [
    { name = "sandbox-bb-payments",             project_id = "cdc99791-edf8-4dd4-8fff-6fea9fb6c302" },
    { name = "sandbox-bb-digital-registries",   project_id = "36603874-7125-4106-8a22-4df79ede947f" },
    { name = "sandbox-bb-information-mediator", project_id = "2a76c4ba-3f19-4cf4-a3fd-01d5671b7437" }
 ]
}