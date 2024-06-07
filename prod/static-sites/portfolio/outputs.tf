output "portfolio_s3_bucket_arn" {
  value       = module.portfolio_website.s3_bucket_arn
  description = "The ARN of the S3 bucket for the portfolio website"
}

output "portfolio_cloudfront_distribution_id" {
  value       = module.portfolio_website.cloudfront_distribution_id
  description = "The ID of the CloudFront distribution for the portfolio website"
}

output "root_s3_bucket_arn" {
  value       = module.root_website.s3_bucket_arn
  description = "The ARN of the S3 bucket for the root website"
}

output "root_cloudfront_distribution_id" {
  value       = module.root_website.cloudfront_distribution_id
  description = "The ID of the CloudFront distribution for the root website"
}
