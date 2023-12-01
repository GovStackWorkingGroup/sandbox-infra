dependency "eks" {
  config_path = "../eks-sandbox"
}

include "root" {
  path = find_in_parent_folders()
}

include "commons" {
    path = "${dirname(find_in_parent_folders())}/common/kube.hcl"
    expose = true
}

#environment specific inputs

inputs = {
  vpc_id = dependency.eks.outputs.vpc_id
  cluster_name = dependency.eks.outputs.cluster_name
  sandbox_alb_arn = dependency.eks.outputs.sandbox_alb_arn
  sandbox_alb_listener_arn = dependency.eks.outputs.sandbox_alb_listener_arn

  alb_domain = "playground.sandbox-playground.com"
  user_pool_arn = "arn:aws:cognito-idp:eu-central-1:161826879607:userpool/eu-central-1_62aW2eUn0"
  user_pool_client_id = "114lishck94fs01oi01qdunvgj"
  user_pool_domain = "sandbox-playground.auth.eu-central-1.amazoncognito.com"
}