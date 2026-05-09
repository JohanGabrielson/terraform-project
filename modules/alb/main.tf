# Input variables
variable "public_subnets" { type = list(string) }
variable "vpc_id"         { type = string }
variable "alb_sg"         { type = string }

# Application Load Balancer - single entry point for external traffic
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

# Target group - forwards traffic to frontend instances
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

# HTTP listener - forwards to frontend target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

output "alb_dns" { value = aws_lb.this.dns_name }
output "target_group_arn" { value = aws_lb_target_group.frontend.arn }
