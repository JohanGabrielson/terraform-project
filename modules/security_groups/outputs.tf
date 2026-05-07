output "alb_sg" {
  value = aws_security_group.alb.id
}

output "frontend_sg" {
  value = aws_security_group.frontend.id
}

output "backend_sg" {
  value = aws_security_group.backend.id
}
