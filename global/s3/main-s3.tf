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


### Sourdough Website
resource "aws_s3_bucket" "sourdough" {
  bucket = "sourdough.${var.domain_name}"

  tags = {
    Name        = "Sourdough-Website-Bucket"
    Environment = "Production"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "enforce_object_ownership" {
  bucket = aws_s3_bucket.sourdough.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.sourdough.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront_distribution" {
  bucket = aws_s3_bucket.sourdough.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_distribution.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_distribution" {
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
