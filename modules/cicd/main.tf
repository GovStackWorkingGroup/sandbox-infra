resource "aws_iam_openid_connect_provider" "cicd_oicd" {
    url = "${var.oidc_url}/${var.audiences[0]}"
    client_id_list = var.audiences

    thumbprint_list = var.thumbprints
}

resource "aws_iam_role" "CiCDRole" {
  name = "Pipeline_"
}

data "aws_iam_policy_document" "cicd_pipeline_assume_role_policy" {
    statement {
      actions = ["sts:AssumeRole"]

      principals {
        type = "Federated"
        identifiers = [ aws_iam_openid_connect_provider.cicd_oicd.arn ]
      }
      condition {
        test = "StringLike"
        values ["sts.amazonaws.com"]
        variable = 
      }
    }
}