resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudcorp-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "cloudcorp-igw"
  }
}

# -------------------------
# Public Subnets
# -------------------------
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = "eu-north-1${each.key}"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${each.key}"
  }
}

# -------------------------
# Private Subnets
# -------------------------
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = "eu-north-1${each.key}"

  tags = {
    Name = "private-${each.key}"
  }
}

# -------------------------
# NAT Gateways (one per AZ)
# -------------------------
resource "aws_eip" "nat" {
  for_each = var.public_subnets

  vpc = true

  tags = {
    Name = "nat-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = var.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "nat-${each.key}"
  }
}

# -------------------------
# Route Tables
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# -------------------------
# VPC Endpoint for S3
# -------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for rt in aws_route_table.private : rt.id
  ]

  tags = {
    Name = "s3-endpoint"
  }
}
