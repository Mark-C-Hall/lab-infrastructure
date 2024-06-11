provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "github.com/mark-c-hall/modules//services/webserver-cluster?ref=v0.0.2"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "lab.markchall.com-terraform-state"
  db_remote_state_key    = "lab/prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}

resource "aws_autoscaling_schedule" "scale_out_business_hrs" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in_at_night"
  min_size              = 1
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

output "dns_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "ALB DNS Name"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}
