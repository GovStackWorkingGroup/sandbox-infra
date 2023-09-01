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
 instance_type = "t3.2xlarge"
 disk_size = 100
 vpc_cidr = "10.42.0.0/16"
}