data "aws_caller_identity" "current" {}

locals {
  circleci_url = "${var.provider_url}/${var.org_id}"
  rolename     = "CircleCI-${var.environment}"
}

resource "aws_iam_openid_connect_provider" "cicd_oicd" {
  url            = local.circleci_url
  client_id_list = [var.org_id]

  thumbprint_list = var.ssl_thumbprints
}

module "CircleCIRole" {

  for_each = { for project in var.projects : project.name => project }

  source       = "..//circlecirole"
  circleci_url = local.circleci_url
  org_id       = var.org_id
  environment  = var.environment

  project_id = each.value.project_id
  name       = each.key

  oidc_arn = aws_iam_openid_connect_provider.cicd_oicd.arn

}

output "oidc_arn" {
  value = aws_iam_openid_connect_provider.cicd_oicd.arn
}

output "CircleCIRoleArns" {
  value = module.CircleCIRole[*]
}
