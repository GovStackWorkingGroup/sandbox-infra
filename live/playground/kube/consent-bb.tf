# Exposed services for ID-BB (Mosip)
resource "aws_lb_target_group" "consent_bb_api" {
  name        = "consent-bb-api-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "consent_bb_admin" {
  name        = "consent-bb-admin-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "consent_bb_privacy" {
  name        = "consent-bb-privacy-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "consent_bb_keycloak" {
  name        = "consent-bb-keycloak-tg"
  port        = 8080
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "consent_bb_api" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_api]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.consent_bb_api.name
      namespace = "consentbb"
    }
    spec = {
      serviceRef = {
        name = "consentbb-sandbox-api-svc"
        port = 80
      }
      targetGroupARN = aws_lb_target_group.consent_bb_api.arn
    }
  }
}

resource "kubernetes_manifest" "consent_bb_admin" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_admin]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.consent_bb_admin.name
      namespace = "consentbb"
    }
    spec = {
      serviceRef = {
        name = "consentbb-sandbox-admin-dashboard-svc"
        port = 80
      }
      targetGroupARN = aws_lb_target_group.consent_bb_admin.arn
    }
  }
}

resource "kubernetes_manifest" "consent_bb_privacy" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_privacy]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.consent_bb_privacy.name
      namespace = "consentbb"
    }
    spec = {
      serviceRef = {
        name = "consentbb-sandbox-privacy-dashboard-svc"
        port = 80
      }
      targetGroupARN = aws_lb_target_group.consent_bb_privacy.arn
    }
  }
}

resource "kubernetes_manifest" "consent_bb_keycloak" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_keycloak]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.consent_bb_keycloak.name
      namespace = "consentbb"
    }
    spec = {
      serviceRef = {
        name = "consentbb-sandbox-keycloak-svc"
        port = 8080
      }
      targetGroupARN = aws_lb_target_group.consent_bb_keycloak.arn
    }
  }
}


## ALB listener rules

# cluster-internal
resource "aws_lb_listener_rule" "consent_bb_api_internal" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.id_bb_public]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3000
  tags = {
    Name = "consent-bb api internal"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_api.arn
  }

  condition {
    host_header {
      values = ["api.consent-bb.${var.alb_domain}"]
    }
  }

  condition {
    source_ip {
      values = formatlist("%s/32", var.vpc_nat_gw_ip)
    }
  }
}

resource "aws_lb_listener_rule" "consent_bb_keycloak_internal" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.id_bb_internal]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3001
  tags = {
    Name = "consent-bb iam internal"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_keycloak.arn
  }

  condition {
    host_header {
      values = ["iam.consent-bb.${var.alb_domain}"]
    }
  }

  condition {
    source_ip {
      values = formatlist("%s/32", var.vpc_nat_gw_ip)
    }
  }
}

# external
resource "aws_lb_listener_rule" "consent_bb_keycloak" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_keycloak]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3100
  tags = {
    Name = "consent-bb iam"
  }

  action {
    type             = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn = "${var.user_pool_arn}"
      user_pool_client_id = "${var.user_pool_client_id}"
      user_pool_domain = "${var.user_pool_domain}"
      session_timeout = "7200"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_keycloak.arn
  }

  condition {
    host_header {
      values = ["iam.consent-bb.${var.alb_domain}"]
    }
  }

}

resource "aws_lb_listener_rule" "consent_bb_privacy_api" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_api]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3300
  tags = {
    Name = "consent-bb admin dashboard"
  }

  action {
    type             = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn = "${var.user_pool_arn}"
      user_pool_client_id = "${var.user_pool_client_id}"
      user_pool_domain = "${var.user_pool_domain}"
      session_timeout = "7200"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_api.arn
  }

  condition {
    host_header {
      values = ["privacy-dashboard.consent-bb.${var.alb_domain}"]
    }
  }
  condition {
    path_pattern {
      values = [
        "/v2/*",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "consent_bb_privacy" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_privacy]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3301
  tags = {
    Name = "consent-bb privacy"
  }

  action {
    type             = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn = "${var.user_pool_arn}"
      user_pool_client_id = "${var.user_pool_client_id}"
      user_pool_domain = "${var.user_pool_domain}"
      session_timeout = "7200"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_privacy.arn
  }

  condition {
    host_header {
      values = ["privacy-dashboard.consent-bb.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "consent_bb_admin_api" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_api]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3400
  tags = {
    Name = "consent-bb admin dashboard"
  }

  action {
    type             = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn = "${var.user_pool_arn}"
      user_pool_client_id = "${var.user_pool_client_id}"
      user_pool_domain = "${var.user_pool_domain}"
      session_timeout = "7200"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_api.arn
  }

  condition {
    host_header {
      values = ["admin-dashboard.consent-bb.${var.alb_domain}"]
    }
  }
  condition {
    path_pattern {
      values = [
        "/v2/*",
      ]
    }
  }
}

resource "aws_lb_listener_rule" "consent_bb_admin" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.consent_bb_admin]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3401
  tags = {
    Name = "consent-bb admin dashboard"
  }

  action {
    type             = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn = "${var.user_pool_arn}"
      user_pool_client_id = "${var.user_pool_client_id}"
      user_pool_domain = "${var.user_pool_domain}"
      session_timeout = "7200"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consent_bb_admin.arn
  }

  condition {
    host_header {
      values = ["admin-dashboard.consent-bb.${var.alb_domain}"]
    }
  }
}
