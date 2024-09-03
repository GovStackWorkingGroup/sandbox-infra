# Exposed services for baserow
resource "aws_lb_target_group" "baserow_bb_ui" {
  name        = "baserow-bb-ui-tg"
  port        = 80
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "aws_lb_target_group" "baserow_backend" {
  name        = "baserow-backend-tg"
  port        = 8000
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  target_type = "ip"
}

resource "kubernetes_manifest" "baserow_bb_ui" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.baserow_bb_ui]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.baserow_bb_ui.name
      namespace = "baserow"
    }
    spec = {
      serviceRef = {
        name = "baserow-frontend"
        port = 3000
      }
      targetGroupARN = aws_lb_target_group.baserow_bb_ui.arn
    }
  }
}

resource "kubernetes_manifest" "baserow_backend" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.baserow_backend]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind       = "TargetGroupBinding"
    metadata = {
      name      = aws_lb_target_group.baserow_backend.name
      namespace = "baserow"
    }
    spec = {
      serviceRef = {
        name = "baserow-wsgi"
        port = 8000
      }
      targetGroupARN = aws_lb_target_group.baserow_backend.arn
    }
  }
}


resource "aws_lb_listener_rule" "baserow_bb" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.baserow_bb_ui]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3405
  tags = {
    Name = "baserow-bb main ui"
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
    target_group_arn = aws_lb_target_group.baserow_bb_ui.arn
  }

  condition {
    host_header {
      values = ["baserow-bb.${var.alb_domain}"]
    }
  }
}
resource "aws_lb_listener_rule" "baserow_backend" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.baserow_backend]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 3406
  tags = {
    Name = "baserow-wsgi"
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
    target_group_arn = aws_lb_target_group.baserow_backend.arn
  }

  condition {
    host_header {
      values = ["baserow-bb.${var.alb_domain}"]
    }
  }
}
