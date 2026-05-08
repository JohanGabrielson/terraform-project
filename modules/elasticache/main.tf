resource "aws_elasticache_subnet_group" "this" {
  name       = "cloudcorp-cache-subnet-group"
  subnet_ids = var.private_subnets
  tags = {
    Name = "cloudcorp-cache-subnet-group"
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "cloudcorp-cache"
  description                = "Redis for CloudCorp"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = var.node_type
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [var.cache_sg]
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  tags = {
    Name = "cloudcorp-cache"
  }
}
