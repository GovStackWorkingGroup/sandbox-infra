#
# Target groups
# TargetGroupBinding resource binds actual endpoints to the tg
#
resource "aws_lb_target_group" "usct_backend" {
    name = "usct-backend-tg"
    port = "8080"
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"

    health_check {
      protocol = "HTTP"
      path = "/actuator/health"
      port = "8080"
    }

    stickiness {
      enabled = true
      type = "app_cookie"
      cookie_name = "USCT_SESSION"
    }
}

resource "aws_lb_target_group" "rpc_backend" {
    name = "rpc-backend-tg"
    port = "8080"
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"

    health_check {
      protocol = "HTTP"
      path = "/actuator/health"
      port = "8080"
    }
}

resource "aws_lb_target_group" "usct_frontend" {
    name = "usct-frontend-tg"
    port = 80
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}

resource "aws_lb_target_group" "bp_frontend" {
    name = "bp-frontend-tg"
    port = 80
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}

locals {
  backends = {}
}

resource "kubernetes_manifest" "backend" {
  for_each = local.backends
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "${each.key}-tg"
      namespace = "${each.key}"
    }
    spec = {
      serviceRef = {
          name = "${each.key}"
          port = "${each.value.port}"
        }
      targetGroupARN = "${each.value.arn}"
    }
  }
}

locals {
  xroad_servers = ["cs", "ss1", "ss2", "ss3"]
}

resource "aws_lb_target_group" "im_xroad" {
    for_each = toset(local.xroad_servers)

    name = "im-xroad-${each.key}-tg"
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

resource "kubernetes_namespace" "im_xroad" {
  metadata {
    name = "im-sandbox"
  }
}

resource "kubernetes_manifest" "im_xroad" {
  for_each = var.user_pool_arn != null ? aws_lb_target_group.im_xroad : {}

  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "sandbox-xroad-${each.key}-tg"
      namespace = kubernetes_namespace.im_xroad.metadata[0].name
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

#
# Listener rules (public)
#
resource "aws_lb_listener_rule" "usct_backend" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.usct_backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  condition {
    host_header {
      values = ["usct.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "usct_frontend" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.usct_frontend.arn
  }

  condition {
    host_header {
      values = ["usct.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "bp_frontend" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bp_frontend.arn
  }

  condition {
    host_header {
      values = ["bp.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "rpc_backend" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rpc_backend.arn
  }

  condition {
    host_header {
      values = ["rpc.${var.alb_domain}"]
    }
  }
}

#
# Listener rules (with authentication)
#
resource "aws_lb_listener_rule" "im_xroad" {
  for_each = var.user_pool_arn != null ? aws_lb_target_group.im_xroad : {}

  listener_arn = var.sandbox_alb_listener_arn
  priority     = 10000 + index(local.xroad_servers, each.key)
  tags = {
    Name = "im-xroad.${each.key}-admin"
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
      values = ["im-xroad-${each.key}.${var.alb_domain}"]
    }

  }
}
