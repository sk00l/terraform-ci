output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.main.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = local.security_group_id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}



output "instance_tags" {
  description = "Tags applied to the EC2 instance"
  value       = aws_instance.main.tags
}


output "subnet_id" {
  description = "Subnet ID where the EC2 instance is deployed"
  value       = aws_instance.main.subnet_id
}

output "vpc_id" {
  description = "VPC ID where the EC2 instance is deployed"
  value       = var.vpc_id
}

output "ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = local.ami_id
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = aws_instance.main.instance_type
}


