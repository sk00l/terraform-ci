locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Creator     = "sauravbhattarai"
      Project     = "sauravbhattarai-ec2"
      Environment = var.environment
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    }
  )

  # Instance types based on environment
  instance_types = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }

  # Volume sizes based on environment
  volume_sizes = {
    dev     = 8
    staging = 16
    prod    = 32
  }

  # Log retention days based on environment
  log_retention_days = {
    dev     = 7
    staging = 14
    prod    = 30
  }

  # Security group rules based on environment
  security_group_rules = {
    dev = {
      ssh_cidr  = ["0.0.0.0/0"]
      http_cidr = ["0.0.0.0/0"]
    }
    staging = {
      ssh_cidr  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      http_cidr = ["0.0.0.0/0"]
    }
    prod = {
      ssh_cidr  = ["10.0.0.0/8"]
      http_cidr = ["0.0.0.0/0"]
    }
  }

  # Resource naming
  resource_names = {
    instance_name       = "sauravbhattarai-ec2-${var.environment}"
    security_group_name = "sauravbhattarai-ec2-sg-${var.environment}"
    iam_role_name       = "sauravbhattarai-ec2-role-${var.environment}"
    log_group_name      = "/aws/ec2/sauravbhattarai-${var.environment}"
  }

  # Environment-specific configurations
  env_config = {
    dev = {
      monitoring_enabled = false
      backup_enabled     = false
      encryption_enabled = true
    }
    staging = {
      monitoring_enabled = true
      backup_enabled     = true
      encryption_enabled = true
    }
    prod = {
      monitoring_enabled = true
      backup_enabled     = true
      encryption_enabled = true
    }
  }

  # Get current environment config
  current_env_config = lookup(local.env_config, var.environment, local.env_config.dev)
} 