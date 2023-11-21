locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "circleci" {
  config_path = "../circleci"
}

include "root" {
  path = find_in_parent_folders()
}

include "commons" {
    path = "${dirname(find_in_parent_folders())}/common/eks.hcl"
    expose = true
}

#environment specific inputs 

inputs = {
 cicd_rolearns = dependency.circleci.outputs.cicd_rolearns
 instance_type = "t3a.medium"
 disk_size = 100
 vpc_cidr = local.env_vars.locals.vpc_cidr
}