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

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name_prefix = "sauravbhattarai-ec2-sg-"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-security-group"
    }
  )
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "sauravbhattarai-ec2-role"

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
  name = "sauravbhattarai-ec2-profile"
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
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = lookup(local.instance_types, var.environment, "t3.micro")
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = data.aws_subnets.default.ids[0]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
    project     = "sauravbhattarai"
  }))

  root_block_device {
    volume_size = lookup(local.volume_sizes, var.environment, 8)
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-instance"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/sauravbhattarai-${var.environment}"
  retention_in_days = lookup(local.log_retention_days, var.environment, 7)

  tags = merge(
    local.common_tags,
    {
      Name = "sauravbhattarai-ec2-logs"
    }
  )
} 