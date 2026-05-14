output "asg_name" {
  value = aws_autoscaling_group.frontend.name
}

output "launch_template_id" {
  value = aws_launch_template.frontend.id
}
