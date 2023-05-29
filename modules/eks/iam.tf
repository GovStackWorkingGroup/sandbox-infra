resource "aws_iam_role" "eks_fargate_role" {
  name = "EKSFargateRole"
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.fargate_role_assume_document.json

}

data "aws_iam_policy_document" "fargate_role_assume_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com", "eks-fargate-pods.amazonaws.com"]
    }
  }
}

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
    condition {
      test = "StringLike"
      values = ["system:serviceaccount:govstack-backend:ack-rds-controller"]
      variable = "${module.eks.oidc_provider}:sub"
    }
  }
}

resource "aws_iam_role_policy_attachment" "eksPodexectuonPolicyAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role.name
  
}