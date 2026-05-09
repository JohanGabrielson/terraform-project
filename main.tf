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
# KMS
# -------------------------
resource "aws_kms_key" "general" {
  description         = "KMS key for CloudCorp data"
  enable_key_rotation = true
  tags = {
    Name = "cloudcorp-kms"
  }
}

# -------------------------
# VPC
# -------------------------
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
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
  source         = "./modules/alb"
  public_subnets = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
  vpc_id         = module.vpc.vpc_id
  alb_sg         = module.security_groups.alb_sg
}


# -------------------------
# IAM-roles  EC2
# -------------------------
resource "aws_iam_role" "frontend" {
  name = "cloudcorp-frontend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "frontend_ssm" {
  role       = aws_iam_role.frontend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "backend" {
  name = "cloudcorp-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend_ssm" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
  source           = "./modules/ec2"
  ami              = var.ami
  instance_type    = var.instance_type
  private_subnet_a = module.vpc.private_subnet_a_id
  private_subnet_b = module.vpc.private_subnet_b_id
  frontend_sg      = module.security_groups.frontend_sg
  backend_sg       = module.security_groups.backend_sg
  frontend_profile = aws_iam_instance_profile.frontend.name
  backend_profile  = aws_iam_instance_profile.backend.name
}

# -------------------------
# RDS Multi-AZ
# -------------------------
module "rds" {
  source          = "./modules/rds"
  private_subnets = [module.vpc.private_subnet_a_id, module.vpc.private_subnet_b_id]
  rds_sg          = module.security_groups.rds_sg
  instance_class  = var.rds_instance_class
  kms_key_id      = aws_kms_key.general.arn
  db_username     = var.db_username
  db_password     = var.db_password
}

# -------------------------
# ElastiCache Redis
# -------------------------
module "elasticache" {
  source          = "./modules/elasticache"
  private_subnets = [module.vpc.private_subnet_a_id, module.vpc.private_subnet_b_id]
  cache_sg        = module.security_groups.cache_sg
  node_type       = var.cache_node_type
}

# -------------------------
# S3 bucket
# -------------------------
resource "aws_s3_bucket" "data" {
  bucket_prefix = "cloudcorp-customer-data-"
  tags = {
    Name = "cloudcorp-customer-data"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.general.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -------------------------
# VPC Gateway Endpoint for S3
# -------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [module.vpc.private_rt_a_id, module.vpc.private_rt_b_id]
  tags = {
    Name = "cloudcorp-s3-endpoint"
  }
}
