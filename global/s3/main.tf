provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}
