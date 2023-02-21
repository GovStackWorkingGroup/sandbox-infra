resource "aws_ecr_repository" "ecr_mifos_ph_ee_ams" {
  name                 = "${var.environment}-ph-ee-ams"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_open_imis" {
  name                 = "${var.environment}-open-imis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_mojaloop" {
  name                 = "${var.environment}-phee-mojaloop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_channel" {
  name                 = "${var.environment}-phee-channel"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_ops_bk" {
  name                 = "${var.environment}-ph-ee-ops-bk"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_ops_web" {
  name                 = "${var.environment}-phee-ops-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_pphee_gsma" {
  name                 = "${var.environment}-phee-gsma"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_slcb" {
  name                 = "${var.environment}-ph-ee-slcb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_mpesa" {
  name                 = "${var.environment}-ph-mpesa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_roster" {
  name                 = "${var.environment}-phee-roster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_connector_ams_paygops" {
  name                 = "${var.environment}-phee-connector-ams-paygops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_notifications" {
  name                 = "${var.environment}-ph-ee-notifications"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_bulk_processor" {
  name                 = "${var.environment}-phee-bulk-processor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_zeebe_ops" {
  name                 = "${var.environment}-phee-zeebe-ops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_message_gateway" {
  name                 = "${var.environment}-phee-message-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_es_importer" {
  name                 = "${var.environment}-ph-es-importer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_importer_rdbms" {
  name                 = "${var.environment}-phee-importer-rdbms"
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