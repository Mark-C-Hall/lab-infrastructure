provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

resource "aws_db_instance" "mysql" {
  identifier_prefix   = "webserver-cluser-mysql"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "mydb"

  username = var.db_username
  password = var.db_password
}
