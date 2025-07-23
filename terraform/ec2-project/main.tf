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
        Project     = "sauravbhattarai-ec2"
        Environment = var.environment
        ManagedBy   = "terraform"
      }
    )
  }
}

# Use specific AMI ID and security group
locals {
  ami_id            = "ami-0150ccaf51ab55a51" # Your specific AMI ID
  security_group_id = "sg-0f32672f66ec5ea03"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "sauravbhattarai-gitops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-role"
    }
  )
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "sauravbhattarai-ec2-profile-11"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-profile"
    }
  )
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [local.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = var.subnet_id

  associate_public_ip_address = true

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-instance"
    }
  )
}


