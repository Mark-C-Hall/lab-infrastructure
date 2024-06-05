################
# State Bucket #
################

# Create an S3 bucket to store the Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "lab.${var.domain_name}-terraform-state"

  # Prevents accidental deletion of the bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning so you can see the full revision history of your
# state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#####################
# Portfolio Website #
#####################

# WWW S3 bucket
resource "aws_s3_bucket" "portfolio" {
  bucket = "www.${var.domain_name}"

  tags = {
    Name        = "Portfolio-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "portfolio-enforce_object_ownership" {
  bucket = aws_s3_bucket.portfolio.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "portfolio-block_public_access" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "portfolio-allow_access_from_cloudfront_distribution" {
  bucket = aws_s3_bucket.portfolio.id
  policy = data.aws_iam_policy_document.portfolio-allow_access_from_cloudfront_distribution.json
}

data "aws_iam_policy_document" "portfolio-allow_access_from_cloudfront_distribution" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio-distribution.arn]
    }
  }
}

# Root S3 bucket
resource "aws_s3_bucket" "root-portfolio" {
  bucket = var.domain_name

  tags = {
    Name        = "Root-Portfolio-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "root-enforce_object_ownership" {
  bucket = aws_s3_bucket.root-portfolio.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "root-block_public_access" {
  bucket = aws_s3_bucket.root-portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "root-website-config" {
  bucket = aws_s3_bucket.root-portfolio.id

  redirect_all_requests_to {
    host_name = "www.${var.domain_name}"
  }
}


#####################
# Sourdough Website #
#####################
resource "aws_s3_bucket" "sourdough" {
  bucket = "sourdough.${var.domain_name}"

  tags = {
    Name        = "Sourdough-Website-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "sourdough-enforce_object_ownership" {
  bucket = aws_s3_bucket.sourdough.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "sourdough-block_public_access" {
  bucket = aws_s3_bucket.sourdough.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "sourdough-allow_access_from_cloudfront_distribution" {
  bucket = aws_s3_bucket.sourdough.id
  policy = data.aws_iam_policy_document.sourdough-allow_access_from_cloudfront_distribution.json
}

data "aws_iam_policy_document" "sourdough-allow_access_from_cloudfront_distribution" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.sourdough.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.sourdough-distribution.arn]
    }
  }
}
