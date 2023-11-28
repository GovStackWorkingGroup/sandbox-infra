# Application load balancer for exposing Sandbox
# applications and building blocks

resource "aws_security_group" "sandbox_alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from all"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "allow_alb" {
    type = "ingress"
    security_group_id = module.eks.cluster_primary_security_group_id
    source_security_group_id = aws_security_group.sandbox_alb_sg.id
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
}

resource "aws_lb" "sandbox_alb" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sandbox_alb_sg.id]
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "sandbox_alb" {
  load_balancer_arn = aws_lb.sandbox_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    type             = "fixed-response"
    fixed_response {
        content_type = "text/html"
        status_code = "503"
    }
  }
}
