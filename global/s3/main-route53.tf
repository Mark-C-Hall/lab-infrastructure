data "aws_route53_zone" "zone" {
  name = var.domain_name
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

#####################################
# Portfolio Website Route53 Records #
#####################################

# WWW A record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Root A record
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root-portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root-portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# WWW AAAA record
resource "aws_route53_record" "www-ipv6" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Root AAAA record
resource "aws_route53_record" "root-ipv6" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.root-portfolio-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root-portfolio-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

#####################################
# Sourdough Website Route53 Records #
#####################################

# A record
resource "aws_route53_record" "sourdough" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "sourdough.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.sourdough-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.sourdough-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# AAAA record
resource "aws_route53_record" "sourdough-ipv6" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "sourdough.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.sourdough-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.sourdough-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
