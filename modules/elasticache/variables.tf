variable "private_subnets" {
  type = list(string)
}

variable "cache_sg" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}
