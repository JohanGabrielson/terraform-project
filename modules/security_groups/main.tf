variable "vpc_id" { type = string }

resource "aws_security_group" "alb" {
  name        = "CloudCorp-alb-sg"
  description = "ALB security group - allows HTTP and HTTPS from internet"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "CloudCorp-alb-sg" }
}

resource "aws_security_group" "frontend" {
  name        = "CloudCorp-frontend-sg"
  description = "Frontend - only allow traffic from ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "CloudCorp-frontend-sg" }
}

resource "aws_security_group" "backend" {
  name        = "CloudCorp-backend-sg"
  description = "Backend - only allow traffic from frontend and ALB health checks"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "CloudCorp-backend-sg" }
}

resource "aws_security_group" "rds" {
  name        = "CloudCorp-rds-sg"
  description = "RDS - only allow PostgreSQL traffic from backend"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "CloudCorp-rds-sg" }
}

resource "aws_security_group" "cache" {
  name        = "CloudCorp-cache-sg"
  description = "Cache - only allow Redis traffic from backend"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "CloudCorp-cache-sg" }
}

output "alb_sg"      { value = aws_security_group.alb.id }
output "frontend_sg" { value = aws_security_group.frontend.id }
output "backend_sg"  { value = aws_security_group.backend.id }
output "rds_sg"      { value = aws_security_group.rds.id }
output "cache_sg"    { value = aws_security_group.cache.id }
