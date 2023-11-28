#
# Target groups
# TargetGroupBinding resource binds actual endpoints to the tg
#
resource "aws_lb_target_group" "usct_backend" {
    name = "usct-backend-tg"
    port = "8080"
    vpc_id = module.vpc.vpc_id
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
    vpc_id = module.vpc.vpc_id
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
    vpc_id = module.vpc.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}

resource "aws_lb_target_group" "bp_frontend" {
    name = "bp-frontend-tg"
    port = 80
    vpc_id = module.vpc.vpc_id
    protocol = "HTTP"
    target_type = "ip"
}

locals {
  xroad_servers = ["cs", "ss1", "ss2", "ss3"]
}

resource "aws_lb_target_group" "im_xroad" {
    for_each = toset(local.xroad_servers)

    name = "im-xroad-${each.key}-tg"
    port = 4000
    vpc_id = module.vpc.vpc_id
    protocol = "HTTPS"
    target_type = "ip"
    health_check {
      protocol = "HTTPS"
      port = 4000
      matcher = "200,302"
    }
}

#
# Listener rules (public)
#
resource "aws_lb_listener_rule" "usct_backend" {
  listener_arn = aws_lb_listener.sandbox_alb.arn
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
  listener_arn = aws_lb_listener.sandbox_alb.arn
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
  listener_arn = aws_lb_listener.sandbox_alb.arn
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
  listener_arn = aws_lb_listener.sandbox_alb.arn
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

  listener_arn = aws_lb_listener.sandbox_alb.arn
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

#
# Outputs
#

output "usct_backend_tg" {
    value = aws_lb_target_group.usct_backend.arn
    description = "USCT backend target group"
}

output "usct_frontend_tg" {
    value = aws_lb_target_group.usct_frontend.arn
    description = "USCT frontend target group"
}

output "rpc_backend_tg" {
    value = aws_lb_target_group.rpc_backend.arn
    description = "rpc backend target group"
}

output "bp_frontend_tg" {
    value = aws_lb_target_group.bp_frontend.arn
    description = "BP frontend target group"
}

output "im_xroad_tg" {
    value = {
      for k, v in aws_lb_target_group.im_xroad : k => v.arn
    }
    description = "X-Road target group"
}
