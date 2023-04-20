data "aws_caller_identity" "current" {}

locals {
  rolename = "CircleCI_${var.name}_Role_${var.environment}"
}

data "aws_iam_policy_document" "cicd_pipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_arn]
    }
    condition {
      test     = "StringEquals"
      values   = [var.org_id]
      variable = "${var.circleci_url}:aud"
    }
    condition {
      test     = "StringLike"
      values   = ["org/${var.org_id}/project/${var.project_id}/user"]
      variable = "${var.circleci_url}:sub"
    }
  }
  #   statement {
  #     sid     = "Statement1"
  #     actions = ["sts:AssumeRole"]
  #     principals {
  #       type        = "AWS"
  #       identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${local.rolename}/CircleSession"]
  #     }
  #   }
}

resource "aws_iam_role" "CICDRole" {

  name               = "CICDPipeline_${var.name}_Role_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cicd_pipeline_assume_role_policy.json
}

data "aws_iam_policy_document" "CircleCIEKSPolicyDocument" {
  statement {
    sid = "1"
    actions = [
      "eks:DescribeCluster",
      "eks:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "CircleCIEKSPolicy" {
  name   = "CircleCIEKSIamPolicyfor${var.name}"
  policy = data.aws_iam_policy_document.CircleCIEKSPolicyDocument.json
}

resource "aws_iam_role_policy_attachment" "ImageBuilderforContainerPolicyAttatchment" {
  role       = aws_iam_role.CICDRole.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

resource "aws_iam_role_policy_attachment" "CircleCIEKSPolicyAttachment" {
  role       = aws_iam_role.CICDRole.name
  policy_arn = aws_iam_policy.CircleCIEKSPolicy.arn
}

output "RoleARN" {
  value = aws_iam_role.CICDRole.arn
}
