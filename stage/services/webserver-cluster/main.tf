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
  source = "github.com/mark-c-hall/modules//services/webserver-cluster?ref=v0.0.1"

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "lab.markchall.com-terraform-state"
  db_remote_state_key    = "lab/stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 1
  max_size      = 1
}

output "dns_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "value of the ALB DNS Name"
}
variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}
