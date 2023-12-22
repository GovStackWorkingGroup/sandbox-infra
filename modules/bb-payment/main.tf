resource "aws_iam_user" "pbu" {
  name = "payment-bucket-user-${var.cluster_name}"
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.pbu.name
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
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.pbb.arn,
    ]
  }

  statement {
    sid = "2"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.pbb.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "pbb" {
  bucket = "govstack-paymenthub-ee-${var.cluster_name}"
}

# Create the object inside the token bucket
resource "aws_s3_object" "tokens" {
  bucket                 = aws_s3_bucket.pbb.id
  key                    = "keys.txt"
  server_side_encryption = "AES256"
  content_type = "text/plain"
  content = <<EOF
access_id: ${aws_iam_access_key.key.id}
access_secret: ${aws_iam_access_key.key.secret}
EOF
}
