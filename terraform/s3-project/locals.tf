locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Creator     = "sauravbhattarai"
      Project     = "sauravbhattarai-s3"
      Environment = var.environment
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  )

  # Generate unique bucket name
  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.bucket_prefix}-${var.environment}-${random_string.bucket_suffix.result}"

  # Versioning configuration based on environment
  versioning_config = {
    dev     = "Enabled"
    staging = "Enabled"
    prod    = "Enabled"
  }

  # Lifecycle transition days based on environment
  transition_days = {
    dev     = 30
    staging = 60
    prod    = 90
  }

  # Lifecycle expiration days based on environment
  expiration_days = {
    dev     = 365
    staging = 730
    prod    = 1095
  }

  # Log retention days based on environment
  log_retention_days = {
    dev     = 7
    staging = 14
    prod    = 30
  }

  # Resource naming
  resource_names = {
    bucket_name     = local.bucket_name
    role_name       = "sauravbhattarai-s3-role-${var.environment}"
    policy_name     = "sauravbhattarai-s3-policy-${var.environment}"
    log_group_name  = "/aws/s3/sauravbhattarai-${var.environment}"
  }

  # Environment-specific configurations
  env_config = {
    dev = {
      encryption_enabled = true
      versioning_enabled = true
      lifecycle_enabled  = true
      logging_enabled    = true
      public_access_block = true
    }
    staging = {
      encryption_enabled = true
      versioning_enabled = true
      lifecycle_enabled  = true
      logging_enabled    = true
      public_access_block = true
    }
    prod = {
      encryption_enabled = true
      versioning_enabled = true
      lifecycle_enabled  = true
      logging_enabled    = true
      public_access_block = true
    }
  }

  # Get current environment config
  current_env_config = lookup(local.env_config, var.environment, local.env_config.dev)

  # S3 bucket policy conditions based on environment
  policy_conditions = {
    dev = {
      require_mfa = false
      ip_restriction = false
    }
    staging = {
      require_mfa = true
      ip_restriction = true
    }
    prod = {
      require_mfa = true
      ip_restriction = true
    }
  }

  # Get current policy conditions
  current_policy_conditions = lookup(local.policy_conditions, var.environment, local.policy_conditions.dev)
}

# Random string for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
} 