resource "aws_lb" "ingress" {
  name               = "${var.common.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.network.public_subnet_ids
  security_groups    = [var.network.security_group_alb_id]
  tags = {
    Name = "${var.common.prefix}-alb"
  }
}

resource "aws_lb_target_group" "blue" {
  name        = "${var.common.prefix}-alb-tg-blue"
  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = var.network.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.common.prefix}-alb-tg-green"
  target_type = "ip"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = var.network.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_lb.ingress.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = 0
      }
    }
  }
}

resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_lb.ingress.arn
  protocol          = "HTTP"
  port              = 9000

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}
