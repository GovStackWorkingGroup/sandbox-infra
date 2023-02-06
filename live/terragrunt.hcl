locals {
  

  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars   = read_terragrunt_config(find_in_parent_folders("common/common.hcl"))

  environment   = local.env_vars.locals.environment
  account_id    = local.env_vars.locals.aws_account_id
  aws_region    = local.common_vars.locals.aws_region
  product       = local.common_vars.locals.product  

}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
    region = "${local.aws_region}"
    allowed_account_ids = ["${local.account_id}"]
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "govstack-sandbox-${local.product}-${local.environment}"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "sandbox-${local.product}-${local.environment}-lock-table"
  }
}

inputs = merge(
    local.env_vars.locals
)