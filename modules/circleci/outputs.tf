output "oidc_arn" {
  value = aws_iam_openid_connect_provider.cicd_oicd.arn
}

output "cicd_rolearns" {
  value = [ for k in module.CircleCIRole : k.RoleARN ]
}
