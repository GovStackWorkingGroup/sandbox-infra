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
  backends = {
    usct_frontend = {
      namespace = "usct"
      service = "frontend"
      tg = aws_lb_target_group.usct_frontend
    }
    usct_backend = {
      namespace = "usct"
      service = "backend"
      tg = aws_lb_target_group.usct_backend
    }
    bp_frontend = {
      namespace = "bp"
      service = "frontend"
      tg = aws_lb_target_group.bp_frontend
    }
    rpc_backend = {
      namespace = "rpc-backend"
      service = "rpc-backend-service"
      tg = aws_lb_target_group.rpc_backend
    }
  }
}

resource "kubernetes_namespace" "backend" {
  for_each = toset([for key,value in local.backends: value.namespace])
  metadata {
    name = each.value
  }
}

resource "kubernetes_manifest" "backend" {
  for_each = local.backends
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "${each.value.service}-tg"
      namespace = "${each.value.namespace}"
    }
    spec = {
      serviceRef = {
          name = "${each.value.service}"
          port = "${each.value.tg.port}"
        }
      targetGroupARN = "${each.value.tg.arn}"
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
      values = [
        "/api/*",
        "/v3/*",
        "/swagger-ui/*"
      ]
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
      values = ["rpc-backend.${var.alb_domain}"]
    }
  }
}
