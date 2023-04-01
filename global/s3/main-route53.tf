## Sourdough Website Route53 Record

data "aws_route53_zone" "zone" {
  name = var.domain_name
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

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
