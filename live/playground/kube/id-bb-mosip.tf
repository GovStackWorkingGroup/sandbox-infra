# Exposed services for ID-BB (Mosip)
resource "aws_lb_target_group" "id_bb_public" {
    name = "id-bb-public-tg"
    port = 80
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"

    health_check {
        port = 15021
        protocol = "HTTP"
        path = "/healthz/ready"
    }
}

resource "aws_lb_target_group" "id_bb_internal" {
    name = "id-bb-internal-tg"
    port = 80
    vpc_id = var.vpc_id
    protocol = "HTTP"
    target_type = "ip"

    health_check {
        port = 15021
        protocol = "HTTP"
        path = "/healthz/ready"
    }
}

resource "kubernetes_manifest" "id_bb_public_tg" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_public ]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "id-bb-mosip-public-tg"
      namespace = "istio-system"
    }
    spec = {
      serviceRef = {
          name = "istio-ingressgateway"
          port = 80
        }
      targetGroupARN = aws_lb_target_group.id_bb_public.arn
    }
  }
}

resource "kubernetes_manifest" "id_bb_internal_tg" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_internal ]
  }
  manifest = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "id-bb-mosip-internal-tg"
      namespace = "istio-system"
    }
    spec = {
      serviceRef = {
          name = "istio-ingressgateway-internal"
          port = 80
        }
      targetGroupARN = aws_lb_target_group.id_bb_internal.arn
    }
  }
}

## ALB listener rules

# public API from cluster
resource "aws_lb_listener_rule" "id_bb_api_internal" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_public ]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 2000
  tags = {
    Name = "id-bb-api-from-cluster"
 }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.id_bb_public.arn
  }

  condition {
    host_header {
      values = ["api.id-bb.${var.alb_domain}"]
    }
  }

  condition {
    source_ip {
      values = formatlist("%s/32",var.vpc_nat_gw_ip)
    }
  }
}

# Internal resources from cluster
resource "aws_lb_listener_rule" "id_bb_internal" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_internal ]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 2001
  tags = {
    Name = "id-bb-internal-from-cluster"
 }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.id_bb_internal.arn
  }

  condition {
    host_header {
      values = ["*.id-bb.${var.alb_domain}"]
    }
  }

  condition {
    source_ip {
      values = formatlist("%s/32",var.vpc_nat_gw_ip)
    }
  }
}

# Public (external) access
resource "aws_lb_listener_rule" "id_bb_public" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_public ]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 2100
  tags = {
    Name = "id-bb-mosip-public"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.id_bb_public.arn
  }

  condition {
    host_header {
      values = [
        "api.id-bb.${var.alb_domain}",
        "esignet.id-bb.${var.alb_domain}",
        "healthservices.id-bb.${var.alb_domain}",
      ]
    }
  }
}

# Protected access
resource "aws_lb_listener_rule" "id_bb_protected_cors" {
  lifecycle {
    replace_triggered_by = [ aws_lb_target_group.id_bb_internal ]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 2200
  tags = {
    Name = "id-bb-mosip-public"
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.id_bb_internal.arn
  }

  condition {
    host_header {
      values = [
        "api-internal.id-bb.${var.alb_domain}"
      ]
    }
  }
  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }
  condition {
    http_header {
      http_header_name = "Origin"
      values = ["https://*.id-bb.${var.alb_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "id_bb_protected" {
  lifecycle {
    replace_triggered_by = [aws_lb_target_group.id_bb_internal]
  }
  listener_arn = var.sandbox_alb_listener_arn
  priority     = 2201
  tags = {
    Name = "ID-BB protected"
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
    target_group_arn = aws_lb_target_group.id_bb_internal.arn
  }

  condition {
    host_header {
      values = ["*.id-bb.${var.alb_domain}"]
    }
  }
}
