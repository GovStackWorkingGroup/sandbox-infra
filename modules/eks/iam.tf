data "aws_iam_policy_document" "eks_role_assume_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test = "StringLike"
      values = ["sts.amazonaws.com"]
      variable = "${module.eks.oidc_provider}:aud"
    }
  }
}
