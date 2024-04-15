# Exposed services for ID-BB (Mifos)
resource "aws_lb_target_group" "mifos_bb_ui" {
  name        = "mifos-bb-ui-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "mifos_bb_ui" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.mifos_bb_ui]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.mifos_bb_ui.name
      namespace = "paymenthub"
    }
    spec = {
      serviceRef = {
        name = "ph-ee-operations-web"
        port = 80
      }
      targetGroupARN = aws_lb_target_group.mifos_bb_ui.arn
    }
  }
}


resource "aws_lb_listener_rule" "mifos_bb_admin" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.mifos_bb_ui]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3401
  tags = {
    Name = "mifos-bb admin dashboard"
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
    target_group_arn = aws_lb_target_group.mifos_bb_ui.arn
  }

  condition {
    host_header {
      values = ["admin-dashboard.mifos-bb.${var.alb_domain}"]
    }
  }
}