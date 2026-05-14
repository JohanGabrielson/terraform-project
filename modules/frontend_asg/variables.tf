variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "security_group_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "cpu_target" {
  type    = number
  default = 60
}
