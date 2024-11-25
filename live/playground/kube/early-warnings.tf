resource "aws_lb_target_group" "early_warnings_backend" {
    name = "early-warnings-backend-tg"
    port = 8080
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}
resource "aws_lb_target_group" "early_warnings_fronted" {
  name        = "early-warnings-frontend-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

locals {
  early_warnings = {
    early_warnings_fronted = {
      namespace = "early-warnings"
      service = "frontend-service"
      tg = aws_lb_target_group.early_warnings_fronted
    }
    usct_backend = {
      namespace = "early-warnings"
      service = "user-service"
      tg = aws_lb_target_group.early_warnings_backend
    }
  }
}

resource "kubernetes_manifest" "early-warnings" {
  for_each = local.early_warnings
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

resource "aws_lb_listener_rule" "early_warnings_backend" {

  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3415

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.early_warnings_backend.arn
  }
    condition {
      path_pattern {
        values = [
          "/api/*"
        ]
      }
    }

  condition {
    host_header {
      values = ["early-warnings.${var.alb_domain}"]
    }
  }
}
resource "aws_lb_listener_rule" "early_warnings_fronted" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3416

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.early_warnings_fronted.arn
  }

  condition {
    host_header {
      values = ["early-warnings.${var.alb_domain}"]
    }
  }
}