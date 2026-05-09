variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_a_id" { type = string }
variable "public_subnet_b_id" { type = string }
variable "private_subnet_a_id" { type = string }
variable "private_subnet_b_id" { type = string }
variable "igw_id" { type = string }
variable "public_rt_id" { type = string }
variable "private_rt_a_id" { type = string }
variable "private_rt_b_id" { type = string }
variable "public_nacl_id" { type = string }
variable "private_nacl_id" { type = string }

# Imported resources - defined so Terraform can manage them
# Run: terraform import module.vpc.aws_vpc.main vpc-06c9580f75d4b2149
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "CloudCorp-VPC" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  tags = { Name = "CloudCorp-public-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  tags = { Name = "CloudCorp-public-subnet-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"
  tags = { Name = "CloudCorp-private-subnet-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"
  tags = { Name = "CloudCorp-private-subnet-b" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "CloudCorp-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "CloudCorp-public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "CloudCorp-private-rt-a" }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "CloudCorp-private-rt-b" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_a_id" { value = aws_subnet.public_a.id }
output "public_subnet_b_id" { value = aws_subnet.public_b.id }
output "private_subnet_a_id" { value = aws_subnet.private_a.id }
output "private_subnet_b_id" { value = aws_subnet.private_b.id }
output "private_rt_a_id" { value = aws_route_table.private_a.id }
output "private_rt_b_id" { value = aws_route_table.private_b.id }


resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = { Name = "cloudcorp-nat-eip-a" }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = { Name = "cloudcorp-nat-eip-b" }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "CloudCorp-NAT-A" }
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags          = { Name = "CloudCorp-NAT-B" }
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_b_nat" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}
