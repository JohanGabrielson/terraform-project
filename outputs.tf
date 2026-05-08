output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}

output "rds_endpoint" {
  value     = module.rds.endpoint
  sensitive = true
}

output "cache_primary_endpoint" {
  value = module.elasticache.primary_endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.data.bucket
}

output "kms_key_arn" {
  value = aws_kms_key.general.arn
}
