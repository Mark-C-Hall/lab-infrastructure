provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "lab.markchall.com-terraform-state"
    key            = "lab/global/iam/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-terraform-locks"
    encrypt        = true
  }
}

resource "aws_iam_user" "example" {
  for_each = toset(var.usernames)
  name     = each.value
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch_read_only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_read_and_write" {
  name   = "cloudwatch_read_and_write"
  policy = data.aws_iam_policy_document.cloudwatch_read_and_write.json
}

data "aws_iam_policy_document" "cloudwatch_read_and_write" {
  statement {
    effect = "Allow"

    actions = ["cloudwatch:*"]

    resources = ["*"]
  }
}

variable "usernames" {
  description = "A list of usernames to create"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

variable "hero_with_1000_faces" {
  description = "map"
  type        = map(string)
  default = {
    "neo"      = "The One"
    "trinity"  = "The Beloved"
    "morpheus" = "The Mentor"
  }
}

output "all_usernames" {
  value = aws_iam_user.example
}

output "all_arns" {
  value = values(aws_iam_user.example)[*].arn
}

output "upper_names" {
  value = [for name in values(aws_iam_user.example) : upper(name.name)]
}

output "bios" {
  value = [for name, bio in var.hero_with_1000_faces : "${name} is the ${bio}"]
}
