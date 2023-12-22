# Exposed services for IM (X-Road) BB

locals {
  xroad_servers = ["cs", "ss1", "ss2", "ss3"]
}

resource "aws_lb_target_group" "im_xroad_bb" {
    for_each = toset(local.xroad_servers)

    name = "im-xroad-bb-${each.key}-tg"
    port = 4000
    vpc_id = var.vpc_id
    protocol = "HTTPS"
    target_type = "ip"
    health_check {
      protocol = "HTTPS"
      port = 4000
      matcher = "200,302"
    }
}

resource "aws_lb_target_group" "im_xroad_bb_keycloak" {
  name = "im-xroad-bb-keycloak-tg"
  port = 8080
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "im_xroad_bb_management_ui" {
  name = "im-xroad-bb-management-ui-tg"
  port = 8080
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "im_xroad_bb_management_api" {
  name = "im-xroad-bb-management-api-tg"
  port = 8080
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"
}

resource "kubernetes_namespace" "im_xroad_bb" {
  metadata {
    name = "im-xroad"
  }
}

resource "kubernetes_manifest" "im_xroad_bb" {
  for_each = var.user_pool_arn != null ? aws_lb_target_group.im_xroad_bb : {}

  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "im-xroad-bb-${each.key}-tg"
      namespace = kubernetes_namespace.im_xroad_bb.metadata[0].name
    }
    spec = {
      serviceRef = {
          name = "sandbox-xroad-${each.key}"
          port = 4000
        }
      targetGroupARN = "${each.value.arn}"
    }
  }
}

resource "kubernetes_manifest" "im_xroad_bb_keycloak" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "im-xroad-bb-keycloak-tg"
      namespace = kubernetes_namespace.im_xroad_bb.metadata[0].name
    }
    spec = {
      serviceRef = {
          name = "keycloak"
          port = 8080
        }
      targetGroupARN = aws_lb_target_group.im_xroad_bb_keycloak.arn
    }
  }
}

resource "kubernetes_manifest" "im_xroad_bb_management_ui" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "im-xroad-bb-management-ui-tg"
      namespace = kubernetes_namespace.im_xroad_bb.metadata[0].name
    }
    spec = {
      serviceRef = {
          name = "management-ui"
          port = 8080
        }
      targetGroupARN = aws_lb_target_group.im_xroad_bb_management_ui.arn
    }
  }
}

resource "kubernetes_manifest" "im_xroad_bb_management_api" {
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "im-xroad-bb-management-api-tg"
      namespace = kubernetes_namespace.im_xroad_bb.metadata[0].name
    }
    spec = {
      serviceRef = {
          name = "management-api"
          port = 8080
        }
      targetGroupARN = aws_lb_target_group.im_xroad_bb_management_api.arn
    }
  }
}

## ALB listener rules
resource "aws_lb_listener_rule" "im_xroad_bb" {
  for_each = var.user_pool_arn != null ? aws_lb_target_group.im_xroad_bb : {}

  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10110 + index(local.xroad_servers, each.key)
  tags = {
    Name = "im-xroad-bb.${each.key}-admin"
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
    target_group_arn = each.value.arn
  }

  condition {
    host_header {
      values = ["${each.key}-im-xroad.${var.alb_domain}"]
    }

  }
}

resource "aws_lb_listener_rule" "im_xroad_bb_keycloak_internal" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10100
  tags = {
    Name = "im-xroad-bb-iam-internal"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.im_xroad_bb_keycloak.arn
  }

  condition {
    host_header {
      values = ["iam-im-xroad.${var.alb_domain}"]
    }
  }

  condition {
    source_ip {
      values = formatlist("%s/32",var.vpc_nat_gw_ip)
    }
  }
}

# Due to CORS, we need to expose some OIDC authentication endpoints
resource "aws_lb_listener_rule" "im_xroad_bb_keycloak_public" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10101
  tags = {
    Name = "im-xroad-bb-iam-internal"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.im_xroad_bb_keycloak.arn
  }

  condition {
    host_header {
      values = ["iam-im-xroad.${var.alb_domain}"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/realms/pubsub-realm/.well-known/openid-configuration",
        "/realms/pubsub-realm/protocol/openid-connect/userinfo",
        "/realms/pubsub-realm/protocol/openid-connect/token"
      ]
    }
  }
}

resource "aws_lb_listener_rule" "im_xroad_bb_keycloak" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10102
  tags = {
    Name = "im-xroad-bb-iam-admin"
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
    target_group_arn = aws_lb_target_group.im_xroad_bb_keycloak.arn
  }

  condition {
    host_header {
      values = ["iam-im-xroad.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "im_xroad_bb_management_api" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10120
  tags = {
    Name = "im-xroad-bb-management-api-admin"
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
    target_group_arn = aws_lb_target_group.im_xroad_bb_management_api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
  condition {
    host_header {
      values = ["management-ui-im-xroad.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "im_xroad_bb_management_ui" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10121
  tags = {
    Name = "im-xroad-bb-management-admin"
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
    target_group_arn = aws_lb_target_group.im_xroad_bb_management_ui.arn
  }

  condition {
    host_header {
      values = ["management-ui-im-xroad.${var.alb_domain}"]
    }
  }
}
