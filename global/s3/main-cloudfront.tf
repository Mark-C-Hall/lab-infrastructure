## Sourdough Website CloudFront Distribution

resource "aws_cloudfront_distribution" "sourdough-distribution" {
  origin {
    domain_name              = aws_s3_bucket.sourdough.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.sourdough.id
    origin_id                = aws_s3_bucket.sourdough.bucket_regional_domain_name
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


  aliases = ["sourdough.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.sourdough.bucket_regional_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = data.aws_cloudfront_cache_policy.managed-cache-optimized.min_ttl
    default_ttl            = data.aws_cloudfront_cache_policy.managed-cache-optimized.default_ttl
    max_ttl                = data.aws_cloudfront_cache_policy.managed-cache-optimized.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Sourdough-Distribution"
    Environment = "Production"
    Terraform   = "True"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_origin_access_control" "sourdough" {
  name                              = "Sourdough-OAI"
  description                       = "Sourdough OAI Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "managed-cache-optimized" {
  name = "Managed-CachingOptimized"
}
