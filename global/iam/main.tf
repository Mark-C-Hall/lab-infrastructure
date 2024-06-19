provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/global/iam/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

module "iam" {
  source = "../../../modules/iam"
  allowed_repos_branches = [{
    org    = "Mark-C-Hall"
    repo   = "Portfolio"
    branch = "main"
  }]
}
