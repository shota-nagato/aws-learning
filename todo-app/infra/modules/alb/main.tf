locals {
  prefix = "${var.project_settings.project}-${var.project_settings.environment}"
}

resource "aws_lb" "this" {
  name = "${local.prefix}-alb"

  security_groups = [var.alb_settings.sg_id]
  subnets         = var.alb_settings.subnet_ids

  internal = false

  load_balancer_type = "application"

  access_logs {
    bucket  = var.alb_settings.bucket_name
    enabled = true
    prefix  = ""
  }

  enable_deletion_protection = false

  tags = {
    Name = "${local.prefix}-alb"
  }
}

resource "aws_lb_target_group" "ecs" {
  name     = "${local.prefix}-alb-ecs-tg"
  protocol = "HTTP"
  port     = 8080
  vpc_id   = var.alb_settings.vpc_id

  target_type = "ip"

  health_check {
    path                = "/public/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.prefix}-alb-ecs-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${local.prefix}-alb-http-listener"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_settings.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  tags = {
    Name = "${local.prefix}-alb-https-listener"
  }
}

resource "aws_lb_listener_rule" "allow_only_domain" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  condition {
    host_header {
      values = [var.alb_settings.alb_domain_name]
    }
  }
}

resource "aws_route53_record" "api" {
  zone_id = var.alb_settings.zone_id
  name    = var.alb_settings.alb_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
