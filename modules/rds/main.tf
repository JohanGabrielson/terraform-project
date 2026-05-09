# Input variables
variable "private_subnets" { type = list(string) }
variable "rds_sg"          { type = string }
variable "instance_class"  { type = string }
variable "kms_key_id"      { type = string }
variable "db_username"     { type = string }
variable "db_password"     {
  type      = string
  sensitive = true
}

# Subnet group 
resource "aws_db_subnet_group" "this" {
  name       = "cloudcorp-rds-subnet-group"
  subnet_ids = var.private_subnets
  tags = { Name = "cloudcorp-rds-subnet-group" }
}

#  postgresql configuration
resource "aws_db_parameter_group" "postgres" {
  name        = "cloudcorp-postgres-params"
  family      = "postgres15"
  description = "Parameter group for CloudCorp"
  tags = { Name = "cloudcorp-postgres-params" }
}

# RDS multi-AZ,  automatic failover
resource "aws_db_instance" "this" {
  identifier             = "cloudcorp-db"
  engine                 = "postgres"
  engine_version         = "15.10"
  instance_class         = var.instance_class
  allocated_storage      = 20
  max_allocated_storage  = 100
  multi_az               = true
  storage_encrypted      = true
  kms_key_id             = var.kms_key_id
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg]
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  parameter_group_name   = aws_db_parameter_group.postgres.name
  tags = { Name = "cloudcorp-rds" }
}

output "endpoint" { value = aws_db_instance.this.address }
