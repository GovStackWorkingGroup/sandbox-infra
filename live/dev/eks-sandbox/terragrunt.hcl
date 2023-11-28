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
  instance_type = "t3.medium"
  disk_size = 50
  vpc_cidr = "10.44.0.0/16"
  cluster_name = "sandbox"
  alb_certificate_arn = "arn:aws:acm:eu-central-1:463471358064:certificate/290b553f-0a86-4d3e-bd51-56662d93c447"
  alb_domain = "dev.sandbox-playground.com"
  user_pool_arn = "arn:aws:cognito-idp:eu-central-1:463471358064:userpool/eu-central-1_IKcK2TBnN"
  user_pool_client_id = "6llccm86f7tq482epllespjn3v"
  user_pool_domain = "6llccm86f7tq482epllespjn3v.auth.eu-central-1.amazoncognito.com"
}
