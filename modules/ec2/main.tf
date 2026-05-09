# Input variables
variable "ami"              { type = string }
variable "instance_type"    { type = string }
variable "private_subnet_a" { type = string }
variable "private_subnet_b" { type = string }
variable "frontend_sg"      { type = string }
variable "backend_sg"       { type = string }
variable "frontend_profile" { type = string }
variable "backend_profile"  { type = string }

# Frontend instances - no public IP, only reachable from ALB
resource "aws_instance" "frontend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_a
  vpc_security_group_ids = [var.frontend_sg]
  iam_instance_profile   = var.frontend_profile
  tags = { Name = "frontend-a" }
}

resource "aws_instance" "frontend_b" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_b
  vpc_security_group_ids = [var.frontend_sg]
  iam_instance_profile   = var.frontend_profile
  tags = { Name = "frontend-b" }
}

# Backend instances - no public IP, only reachable from frontend
resource "aws_instance" "backend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_a
  vpc_security_group_ids = [var.backend_sg]
  iam_instance_profile   = var.backend_profile
  tags = { Name = "backend-a" }
}

resource "aws_instance" "backend_b" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_b
  vpc_security_group_ids = [var.backend_sg]
  iam_instance_profile   = var.backend_profile
  tags = { Name = "backend-b" }
}

output "frontend_a_id" { value = aws_instance.frontend.id }
output "frontend_b_id" { value = aws_instance.frontend_b.id }
output "backend_a_id"  { value = aws_instance.backend.id }
output "backend_b_id"  { value = aws_instance.backend_b.id }
