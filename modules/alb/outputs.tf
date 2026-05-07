output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "frontend_tg" {
  value = aws_lb_target_group.frontend.arn
}
