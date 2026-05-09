resource "aws_db_subnet_group" "this" {
  name       = "cloudcorp-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "cloudcorp-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "postgres" {
  name        = "cloudcorp-postgres-params"
  family      = "postgres15"
  description = "Parameter group for CloudCorp"

  tags = {
    Name = "cloudcorp-postgres-params"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "cloudcorp-db"
  engine                  = "postgres"
  engine_version = "15.10"
  instance_class          = var.instance_class
  allocated_storage       = 20
  max_allocated_storage   = 100

  multi_az                = true
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id

  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_sg]

  username                = var.db_username
  password                = var.db_password

  skip_final_snapshot     = true

  publicly_accessible     = false

  parameter_group_name    = aws_db_parameter_group.postgres.name

  tags = {
    Name = "cloudcorp-rds"
  }
}
