resource "aws_launch_template" "frontend" {
  name_prefix   = "cloudcorp-frontend-"
  image_id      = var.ami
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    security_groups = [var.security_group_id]
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
apt update -y
apt install -y nginx

cat << 'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>CloudCorp Frontend</title>
</head>
<body>
<h1>CloudCorp Frontend</h1>
<p>The frontend is running correctly behind the ALB.</p>
</body>
</html>
HTML

systemctl enable nginx
systemctl restart nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "cloudcorp-frontend"
      Environment = var.environment
    }
  }
}
