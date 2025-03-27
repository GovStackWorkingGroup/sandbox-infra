# Exposed services for OpenCost
resource "aws_lb_target_group" "opencost_bb_ui" {
  name        = "opencost-bb-ui-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "opencost_bb_ui" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.opencost_bb_ui]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.opencost_bb_ui.name
      namespace = "opencost"
    }
    spec = {
      serviceRef = {
        name = "opencost"
        port = 9090
      }
      targetGroupARN = aws_lb_target_group.opencost_bb_ui.arn
    }
  }
}


resource "aws_lb_listener_rule" "opencost_bb_admin" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.opencost_bb_ui]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3405
  tags = {
    Name = "opencost-bb admin dashboard"
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
    target_group_arn = aws_lb_target_group.opencost_bb_ui.arn
  }

  condition {
    host_header {
      values = ["admin-dashboard-opencost.${var.alb_domain}"]
    }
  }
}