resource "aws_launch_template" "backend" {
  name_prefix   = "cloudcorp-backend-"
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
apt install -y python3 python3-pip

mkdir -p /opt/backend
cd /opt/backend

cat << 'APP' > app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/api/message")
def message():
    return {"message": "Hello from backend"}
APP

pip3 install fastapi uvicorn

nohup uvicorn app:app --host 0.0.0.0 --port 8080 &
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "cloudcorp-backend"
      Environment = var.environment
    }
  }
}
