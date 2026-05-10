#!/bin/bash
# start.sh - Deploy CloudCorp infrastructure

echo "=== Updating AMI ID ==="
AMI=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" "Name=architecture,Values=x86_64" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text \
  --region eu-north-1)

sed -i "s/ami = \"ami-.*\"/ami = \"$AMI\"/" terraform.tfvars
echo "Using AMI: $AMI"

echo "=== Initializing Terraform ==="
terraform init

echo "=== Deploying infrastructure ==="
terraform apply -auto-approve

echo "=== Done! Outputs: ==="
terraform output
