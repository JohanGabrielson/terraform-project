variable "vpc_id" { type = string }
variable "alb_sg_id" { type = string }
variable "frontend_sg_id" { type = string }
variable "backend_sg_id" { type = string }
variable "rds_sg_id" { type = string }
variable "cache_sg_id" { type = string }

# Importerade security groups
# terraform import module.security_groups.aws_security_group.alb sg-05d0cc0b3cec5b7b9
resource "aws_security_group" "alb" {
  name        = "CloudCorp-alb-sg"
  description = "alb security group"
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

# terraform import module.security_groups.aws_security_group.frontend sg-0404bf5ab212227f2
resource "aws_security_group" "frontend" {
  name        = "CloudCorp-frontend-sg"
  description = "Frontend security group"
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

# terraform import module.security_groups.aws_security_group.backend sg-0b64e452e28a76283
resource "aws_security_group" "backend" {
  name        = "CloudCorp-backend-sg"
  description = "backend api - only allow frontend"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "CloudCorp-backend-sg" }
}

# terraform import module.security_groups.aws_security_group.rds sg-0a1d06300ce851c7a
resource "aws_security_group" "rds" {
  name        = "CloudCorp-rds-sg"
  description = "RDS SG - only allow backend"
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

# terraform import module.security_groups.aws_security_group.cache sg-028c0bd4038a9373e
resource "aws_security_group" "cache" {
  name        = "CloudCorp-cache-sg"
  description = "Cache - only allow backend"
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
