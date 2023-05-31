resource "aws_ecr_repository" "ecr_open_imis_backend" {
  name                 = "open-imis/${var.environment}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_open_imis_db" {
  name                 = "open-imis/${var.environment}-db"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_ams" {
  name                 = "payment-hub/${var.environment}-ph-ee-ams"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_mojaloop" {
  name                 = "payment-hub/${var.environment}-phee-mojaloop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_channel" {
  name                 = "payment-hub/${var.environment}-phee-channel"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_ops_bk" {
  name                 = "payment-hub/${var.environment}-ph-ee-ops-bk"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_ops_web" {
  name                 = "payment-hub/${var.environment}-phee-ops-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_pphee_gsma" {
  name                 = "payment-hub/${var.environment}-phee-gsma"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_slcb" {
  name                 = "payment-hub/${var.environment}-ph-ee-slcb"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_mpesa" {
  name                 = "payment-hub/${var.environment}-ph-mpesa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_roster" {
  name                 = "payment-hub/${var.environment}-phee-roster"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_connector_ams_paygops" {
  name                 = "payment-hub/${var.environment}-phee-connector-ams-paygops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_ee_notifications" {
  name                 = "payment-hub/${var.environment}-ph-ee-notifications"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_bulk_processor" {
  name                 = "payment-hub/${var.environment}-phee-bulk-processor"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_zeebe_ops" {
  name                 = "payment-hub/${var.environment}-phee-zeebe-ops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_message_gateway" {
  name                 = "payment-hub/${var.environment}-phee-message-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_ph_es_importer" {
  name                 = "payment-hub/${var.environment}-ph-es-importer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_phee_importer_rdbms" {
  name                 = "payment-hub/${var.environment}-phee-importer-rdbms"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_fineract" {
  name                 = "payment-hub/${var.environment}-fineract"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos_community-app" {
  name                 = "payment-hub/${var.environment}-community-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos-phee-ns-web-self-service-app" {
  name                 = "payment-hub/phee-ns/${var.environment}-web-self-service-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_mifos-phee-ns-web-app" {
  name                 = "payment-hub/phee-ns/${var.environment}-web-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr_sris_mock" {
  name                 = "sris-mock/${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}