provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/prod/static-sites/portfolio/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

module "portfolio_website" {
  source              = "../../../modules/static-site"
  bucket_name         = "www.${var.domain_name}"
  domain_alias        = "www.${var.domain_name}"
  acm_certificate_arn = data.aws_acm_certificate.cert.arn
  route53_zone_id     = data.aws_route53_zone.zone.zone_id
  environment         = "Production"
  is_forwarded_site   = false
  domain_name         = var.domain_name
}

module "root_website" {
  source              = "../../../modules/static-site"
  bucket_name         = var.domain_name
  domain_alias        = var.domain_name
  acm_certificate_arn = data.aws_acm_certificate.cert.arn
  route53_zone_id     = data.aws_route53_zone.zone.zone_id
  environment         = "Production"
  is_forwarded_site   = true
  domain_name         = var.domain_name
}



data "aws_route53_zone" "zone" {
  name = var.domain_name
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}


