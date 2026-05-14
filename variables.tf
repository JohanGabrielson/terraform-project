variable "region" {
  type    = string
  default = "eu-north-1"
}


variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for frontend/backend"
  type        = string
  default     = "t3.micro"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "cache_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "cloudcorp"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
