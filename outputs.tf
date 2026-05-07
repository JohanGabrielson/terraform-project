output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "cache_primary_endpoint" {
  value = module.elasticache.primary_endpoint
}
