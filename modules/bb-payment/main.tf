resource "aws_iam_user" "pbu" {
  name = "payment-bucket-user"
}

resource "aws_iam_user_policy" "lb_ro" {
  name = "payment-bucket-policy"
  policy = data.aws_iam_policy_document.pb_s3_role_policy.json
  user   = aws_iam_user.pbu.name
}

data "aws_iam_policy_document" "pb_s3_role_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.pbb.arn,
    ]
  }
}

resource "aws_s3_bucket" "pbb" {
  bucket = "govstack-paymenthub-ee-dev"
}
