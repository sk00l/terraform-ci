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
  value       = aws_security_group.ec2_sg.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ec2_logs.name
}

output "instance_tags" {
  description = "Tags applied to the EC2 instance"
  value       = aws_instance.main.tags
}

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.main.availability_zone
}

output "subnet_id" {
  description = "Subnet ID where the EC2 instance is deployed"
  value       = aws_instance.main.subnet_id
}

output "vpc_id" {
  description = "VPC ID where the EC2 instance is deployed"
  value       = data.aws_vpc.default.id
}

output "ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = aws_instance.main.ami
}

output "instance_type" {
  description = "Instance type of the EC2 instance"
  value       = aws_instance.main.instance_type
}

output "root_block_device" {
  description = "Root block device configuration"
  value = {
    volume_size = aws_instance.main.root_block_device[0].volume_size
    volume_type = aws_instance.main.root_block_device[0].volume_type
    encrypted   = aws_instance.main.root_block_device[0].encrypted
  }
} 