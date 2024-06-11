variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "Database Username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database Password"
  type        = string
  sensitive   = true
}
