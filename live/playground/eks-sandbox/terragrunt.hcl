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
  cicd_rolearns = []
  instance_type = "t3a.medium"
  disk_size = 50
  vpc_cidr = "10.42.0.0/16"
  cluster_name = "sandbox"
  alb_certificate_arn = "arn:aws:acm:eu-central-1:161826879607:certificate/430f767a-1c67-4494-8660-0576dbb32366"
}
