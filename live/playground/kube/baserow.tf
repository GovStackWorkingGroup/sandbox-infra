# Exposed services for baserow
resource "aws_lb_target_group" "baserow_backend" {
  name        = "baserow-backend-tg"
  port        = 8000
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "baserow_bb_ui" {
  name = "baserow-bb-ui-tg"
  port = 80
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"
}

locals {
  baserow_backends = {
    baserow_bb_ui = {
      namespace = "baserow"
      service = "baserow-frontend"
      tg = aws_lb_target_group.baserow_bb_ui
    }
    baserow_backend = {
      namespace = "baserow"
      service = "baserow-wsgi"
      tg = aws_lb_target_group.baserow_backend
    }
  }
}

resource "kubernetes_manifest" "baserow_backends" {
  for_each = local.baserow_backends
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
resource "aws_lb_listener_rule" "baserow_backend" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3406

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.baserow_backend.arn
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
      values = ["baserow-bb.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "baserow_bb_ui" {
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3405

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.baserow_bb_ui.arn
  }

  condition {
    host_header {
      values = ["baserow-bb.${var.alb_domain}"]
    }
  }
}
