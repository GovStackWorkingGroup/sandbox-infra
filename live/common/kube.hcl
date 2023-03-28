terraform {
   # source = local.base_source_url
   source = local.base_source
}

locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  //common_vars = read_terragrunt_config(find_in_parent_folders("common/common.hcl"))

  # Extract out common variables for reuse
  env = local.env_vars.locals.environment
  product = local.env_vars.locals.product

  eks_version = local.env_vars.locals.eks_version
  account_id = local.env_vars.locals.aws_account_id

  cluster_name = local.env_vars.locals.cluster_name

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the terraform block in the child terragrunt configurations.
 # base_source_url = "git@github.com:GovStackWorkingGroup/sandbox-portal-magiclink-backend.git//terraform"
 base_source =  "../../../modules//kube"
}

#Inputs common in every environment
inputs = {
   #region = local.env_vars.aws_region
   environment = local.env
   product = local.product

   cluster_name = local.cluster_name
   account_id = local.account_id
}

