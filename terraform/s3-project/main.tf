terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge(
      local.common_tags,
      {
        Project     = "sauravbhattarai-s3"
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )
  }
}

# Data source to get EC2 instance ARN from remote state
data "terraform_remote_state" "ec2_project" {
  backend = "s3"
  config = {
    bucket = "sauravbhattarai-terraform-state"
    key    = "ec2-project/terraform.tfstate"
    region = "us-east-1"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-s3-bucket"
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = lookup(local.versioning_config, var.environment, "Enabled")
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "sauravbhattarai-lifecycle-rule"
    status = "Enabled"

    transition {
      days          = lookup(local.transition_days, var.environment, 30)
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = lookup(local.transition_days, var.environment, 90)
      storage_class = "GLACIER"
    }

    expiration {
      days = lookup(local.expiration_days, var.environment, 365)
    }
  }
}

# S3 Bucket Policy - Only allow EC2 instance to write
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2InstanceWrite"
        Effect = "Allow"
        Principal = {
          AWS = data.terraform_remote_state.ec2_project.outputs.instance_arn
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = data.terraform_remote_state.ec2_project.outputs.instance_arn
          }
        }
      },
      {
        Sid    = "DenyAllOtherPrincipals"
        Effect = "Deny"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = data.terraform_remote_state.ec2_project.outputs.instance_arn
          }
        }
      }
    ]
  })
}

# IAM Role for S3 access (if needed for other services)
resource "aws_iam_role" "s3_access_role" {
  name = "sauravbhattarai-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = data.terraform_remote_state.ec2_project.outputs.instance_arn
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-s3-access-role"
    }
  )
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "sauravbhattarai-s3-access-policy"
  description = "Policy for S3 bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = data.terraform_remote_state.ec2_project.outputs.instance_arn
          }
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# CloudWatch Log Group for S3 access logs
resource "aws_cloudwatch_log_group" "s3_logs" {
  name              = "/aws/s3/sauravbhattarai-${var.environment}"
  retention_in_days = lookup(local.log_retention_days, var.environment, 7)

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-s3-logs"
    }
  )
}

# S3 Bucket Logging Configuration
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.main.id
  target_prefix  = "logs/"
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.s3_logs.name
    events         = ["s3:ObjectCreated:*", "s3:ObjectDeleted:*"]
    prefix         = ""
  }
} 