locals {
  account_name   = "SandboxQA"
  aws_account_id = "562840999172" # TODO: replace me with your AWS account ID!
  aws_profile    = "non-prod"
  environment = "qa"

  #versions
  eks_version = "1.24"
}