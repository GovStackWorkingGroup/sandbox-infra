# Exposed services for joget
resource "aws_lb_target_group" "early_warnings_ui" {
  name        = "early-warnings-ui-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "early_warnings_ui" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.early_warnings_ui]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.early_warnings_ui.name
      namespace = "early-warnings"
    }
    spec = {
      serviceRef = {
        name = "user-service"
        port = 8080
      }
      targetGroupARN = aws_lb_target_group.early_warnings_ui.arn
    }
  }
}


resource "aws_lb_listener_rule" "early_warnings_bb" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.early_warnings_ui]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3405
  tags = {
    Name = "joget-bb main ui"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.early_warnings_ui.arn
  }

  condition {
    host_header {
      values = ["joget-bb.${var.alb_domain}"]
    }
  }
}