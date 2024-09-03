# Exposed services for joget
resource "aws_lb_target_group" "joget_bb_ui" {
  name        = "joget-bb-ui-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "joget_bb_ui" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.joget_bb_ui]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.joget_bb_ui.name
      namespace = "joget"
    }
    spec = {
      serviceRef = {
        name = "joget"
        port = 8080
      }
      targetGroupARN = aws_lb_target_group.joget_bb_ui.arn
    }
  }
}


resource "aws_lb_listener_rule" "joget_bb" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.joget_bb_ui]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3404
  tags = {
    Name = "joget-bb main ui"
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
    target_group_arn = aws_lb_target_group.joget_bb_ui.arn
  }

  condition {
    host_header {
      values = ["joget-bb.${var.alb_domain}"]
    }
  }
}