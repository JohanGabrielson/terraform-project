terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# -------------------------
# KMS (för RDS/S3 m.m.)
# -------------------------
resource "aws_kms_key" "general" {
  description             = "KMS key for CloudCorp data"
  enable_key_rotation     = true

  tags = {
    Name = "cloudcorp-kms"
  }
}

# -------------------------
# VPC
# -------------------------
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }

  private_subnets = {
    a = "10.0.11.0/24"
    b = "10.0.12.0/24"
  }
}

# -------------------------
# Security Groups
# -------------------------
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# -------------------------
# ALB
# -------------------------
module "alb" {
  source = "./modules/alb"

  public_subnets = [
    module.vpc.public_subnets["a"].id,
    module.vpc.public_subnets["b"].id
  ]

  vpc_id        = module.vpc.vpc_id
  alb_sg        = module.security_groups.alb_sg
  certificate_arn = var.certificate_arn
}

# -------------------------
# IAM-roller  EC2
# -------------------------
resource "aws_iam_role" "frontend" {
  name = "cloudcorp-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "backend" {
  name = "cloudcorp-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "frontend" {
  name = "cloudcorp-frontend-profile"
  role = aws_iam_role.frontend.name
}

resource "aws_iam_instance_profile" "backend" {
  name = "cloudcorp-backend-profile"
  role = aws_iam_role.backend.name
}


# -------------------------
# EC2 Frontend + Backend
# -------------------------
module "ec2" {
  source = "./modules/ec2"

  ami            = var.ami
  instance_type  = "t3.micro"

  private_subnet_a = module.vpc.private_subnets["a"].id
  private_subnet_b = module.vpc.private_subnets["b"].id

  frontend_sg = module.security_groups.frontend_sg
  backend_sg  = module.security_groups.backend_sg

  frontend_profile = aws_iam_instance_profile.frontend.name
  backend_profile  = aws_iam_instance_profile.backend.name
}

# -------------------------
# RDS Multi-AZ
# -------------------------
module "rds" {
  source = "./modules/rds"

  private_subnets = [
    module.vpc.private_subnets["a"].id,
    module.vpc.private_subnets["b"].id
  ]

  rds_sg = module.security_groups.backend_sg

  instance_class = "db.t3.micro"
  kms_key_id     = var.kms_key_id

  db_username = var.db_username
  db_password = var.db_password
}

# -------------------------
# ElastiCache Redis
# -------------------------
module "elasticache" {
  source = "./modules/elasticache"

  private_subnets = [
    module.vpc.private_subnets["a"].id,
    module.vpc.private_subnets["b"].id
  ]

  cache_sg = module.security_groups.backend_sg
  node_type = "cache.t3.micro"
}
