variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "sauravbhattarai-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


variable "vpc_id" {
  description = "VPC ID for the EC2 instance"
  type        = string
  default     = "vpc-01e1f057ff0dcdd4b"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = "subnet-08fbaf55e41f532db"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
