### Terraform setup for school project
This repository contains a Terraform implementation of a secure AWS  architecture designed for a school project. 

The environment follows least privilege, defense in depth, segmentation, secure by default.

## Project structure
terraform-cloudcorp/
│
├── main.tf               # Root module: orchestrates all submodules
├── variables.tf          # Input variables for the root module
├── outputs.tf            # Outputs from the root module
├── terraform.tfvars      # Variable values (do not commit secrets)
│
├── modules/
│   ├── network/          # VPC, subnets, routing, endpoints
│   ├── alb/              # Application Load Balancer + target groups
│   ├── frontend_asg/     # Frontend Auto Scaling Group + launch template
│   ├── backend_asg/      # Backend Auto Scaling Group + launch template
│   ├── rds/              # RDS Multi-AZ PostgreSQL
│   ├── elasticache/      # Redis cluster
│   └── s3/               # S3 bucket with KMS + replication
│
└── scripts/ (optional)   # local helper scripts, to be expanded in the future to set variables for easy modification


## Getting started

Initialize Terraform

~~~
terraform init
~~~ 

Validate configuration

~~~
terraform validate
~~~

Preview changes 
 
~~~
terraform plan
~~~

Deploy infrastructure

~~~
terraform apply 
~~~

Destroy infrastructure 

~~~
terraform destroy
~~~
