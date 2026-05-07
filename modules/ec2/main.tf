resource "aws_instance" "frontend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_a
  vpc_security_group_ids = [var.frontend_sg]
  iam_instance_profile   = var.frontend_profile

  tags = {
    Name = "frontend-a"
  }
}

resource "aws_instance" "frontend_b" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_b
  vpc_security_group_ids = [var.frontend_sg]
  iam_instance_profile   = var.frontend_profile

  tags = {
    Name = "frontend-b"
  }
}

resource "aws_instance" "backend" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_a
  vpc_security_group_ids = [var.backend_sg]
  iam_instance_profile   = var.backend_profile

  tags = {
    Name = "backend-a"
  }
}

resource "aws_instance" "backend_b" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_b
  vpc_security_group_ids = [var.backend_sg]
  iam_instance_profile   = var.backend_profile

  tags = {
    Name = "backend-b"
  }
}
