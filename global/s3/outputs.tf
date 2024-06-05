output "tf_state_s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}

output "portfolio_bucket_arn" {
  value       = aws_s3_bucket.portfolio.arn
  description = "The ARN of the Portfolio S3 bucket"
}

output "root_bucket_arn" {
  value       = aws_s3_bucket.root-portfolio.arn
  description = "The ARN of the Root S3 bucket"
}

output "sourdough_bucket_arn" {
  value       = aws_s3_bucket.sourdough.arn
  description = "The ARN of the Sourdough S3 bucket"
}

output "portfolio_distribution_id" {
  value       = aws_cloudfront_distribution.portfolio-distribution.id
  description = "The ID of the Portfolio CloudFront distribution"
}

output "sourdough_distribution_id" {
  value       = aws_cloudfront_distribution.sourdough-distribution.id
  description = "The ID of the Sourdough CloudFront distribution"
}
