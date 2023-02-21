resource "aws_ecr_repository" "ecr_open_imis" {
  name                 = "${var.environment}-open-imis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos" {
  name                 = "${var.environment}-mifos"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}