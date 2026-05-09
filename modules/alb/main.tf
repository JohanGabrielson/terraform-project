resource "aws_lb" "this" {
  name                       = "cloudcorp-alb"
  load_balancer_type         = "application"
  subnets                    = var.public_subnets
  security_groups            = [var.alb_sg]
  enable_deletion_protection = false
  tags = {
    Name = "cloudcorp-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
