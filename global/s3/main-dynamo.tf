# Create a DynamoDB table to store the state lock
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "lab-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
