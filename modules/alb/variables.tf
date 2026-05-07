variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "certificate_arn" {
  type = string
}
