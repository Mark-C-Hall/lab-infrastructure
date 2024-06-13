provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "lab.markchall.com-terraform-state"
  db_remote_state_key    = "lab/stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 1
  max_size      = 1

  custom_tags = {
    Owner    = "mark-c-hall"
    MangedBy = "Terraform"
  }
}

output "dns_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "value of the ALB DNS Name"
}
variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}
