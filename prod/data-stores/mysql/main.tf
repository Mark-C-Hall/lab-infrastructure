provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/prod/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

module "aws_db_instance" {
  source = "../../../../modules/data-stores/mysql"

  db_instance_name = "mysql-prod"
  db_username      = var.db_username
  db_password      = var.db_password

}
