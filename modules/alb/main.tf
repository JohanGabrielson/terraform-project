# Input variables
variable "public_subnets" { type = list(string) }
variable "vpc_id"         { type = string }
variable "alb_sg"         { type = string }

# Application Load Balancer
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

# Frontend target group
resource "aws_lb_target_group" "frontend" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-499"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Backend target group (FIXED)
resource "aws_lb_target_group" "backend" {
  name     = "backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/api/message"
    port                = "8080"
    matcher             = "200-499"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener (HTTP 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Backend listener rule
resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
