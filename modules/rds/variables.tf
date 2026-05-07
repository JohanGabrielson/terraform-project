variable "private_subnets" {
  type = list(string)
}

variable "rds_sg" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "kms_key_id" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
