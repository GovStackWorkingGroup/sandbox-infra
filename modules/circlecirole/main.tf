data "aws_caller_identity" "current" {}

locals {
  rolename = "CICDPipeline_${var.name}_Role_${var.environment}"
}

## Because assume role policy cannot contain resources that does not exist yet, we create incomplete policy at first
data "aws_iam_policy_document" "cicd_pipeline_temp_assume_policy" {
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
      values   = ["org/${var.org_id}/project/${var.project_id}/user/*"]
      variable = "${var.circleci_url}:sub"
    }
  }
}

## Final assume role policy to be applied after creation of the role
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
      values   = ["org/${var.org_id}/project/${var.project_id}/user/*"]
      variable = "${var.circleci_url}:sub"
    }
  }
  statement {
    sid     = "Statement1"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${local.rolename}/CircleSession"]
    }
  }
}

# The role to be created, it ignores changes to assume role policy after creation
resource "aws_iam_role" "CICDRole" {

  lifecycle {
    ignore_changes = [
      assume_role_policy,
    ]
  }

  name               = local.rolename
  assume_role_policy = data.aws_iam_policy_document.cicd_pipeline_temp_assume_policy.json
}

data "aws_iam_policy_document" "CircleCIEKSPolicyDocument" {
  statement {
    sid = "1"
    actions = [
      "eks:DescribeCluster",
      "eks:*",
      "s3:PutObject",
      "s3:GetObject"
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

# Updates the assume role policy of the role with aws cli as terraform does not support it out of the box (at least yet)
resource "null_resource" "update_assume_role_policy" {
  depends_on = [
    aws_iam_role.CICDRole,
    data.aws_iam_policy_document.cicd_pipeline_assume_role_policy
  ]
  provisioner "local-exec" {
    command = "aws iam update-assume-role-policy --role-name ${aws_iam_role.CICDRole.name} --policy-document '${data.aws_iam_policy_document.cicd_pipeline_assume_role_policy.json}'"
  }
  triggers = {
    trigger = sha256(data.aws_iam_policy_document.cicd_pipeline_assume_role_policy.json)
  }
}

