#!/bin/bash
# Run these commands to import existing AWS resources into Terraform state
# Run: bash import.sh

echo "=== Importerar VPC-resurser ==="
terraform import module.vpc.aws_vpc.main vpc-06c9580f75d4b2149
terraform import module.vpc.aws_subnet.public_a subnet-09e66d57813d531fa
terraform import module.vpc.aws_subnet.public_b subnet-0d2f4017ec5a3db88
terraform import module.vpc.aws_subnet.private_a subnet-04d704525cf3572c4
terraform import module.vpc.aws_subnet.private_b subnet-08cc4630c5b8211b6
terraform import module.vpc.aws_internet_gateway.main igw-0bb1673d63052e490
terraform import module.vpc.aws_route_table.public rtb-0301d58257f95303c
terraform import module.vpc.aws_route_table.private_a rtb-05083d4986d10b911
terraform import module.vpc.aws_route_table.private_b rtb-0aa3dc2f36c6b6a85

echo "=== Importerar Security Groups ==="
terraform import module.security_groups.aws_security_group.alb sg-05d0cc0b3cec5b7b9
terraform import module.security_groups.aws_security_group.frontend sg-0404bf5ab212227f2
terraform import module.security_groups.aws_security_group.backend sg-0b64e452e28a76283
terraform import module.security_groups.aws_security_group.rds sg-0a1d06300ce851c7a
terraform import module.security_groups.aws_security_group.cache sg-028c0bd4038a9373e

echo "=== Klart! Kör 'terraform plan' för att verifiera ==="
