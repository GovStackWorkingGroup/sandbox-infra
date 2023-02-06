resource "aws_iam_role" "kube_rds_controller_role" {
    name = "StupidRole"
    assume_role_policy = data.aws_iam_policy_document.eks_role_assume_document.json

}

data "aws_iam_policy_document" "eks_role_assume_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = ["arn:aws:iam::463471358064:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/8F486C6A0B85FE0B75B81E11593ACE3B"]
    }
    condition {
      test = "StringLike"
      values = ["sts.amazonaws.com"]
      variable = "oidc.eks.eu-central-1.amazonaws.com/id/8F486C6A0B85FE0B75B81E11593ACE3B:aud"
    }
    condition {
      test = "StringLike"
      values = ["system:serviceaccount:govstack-backend:ack-rds-controller"]
      variable = "oidc.eks.eu-central-1.amazonaws.com/id/8F486C6A0B85FE0B75B81E11593ACE3B:sub"
    }
  }
}


resource "aws_iam_role_policy_attachment" "EKSRDSPolicyAttachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.kube_rds_controller_role.name
}