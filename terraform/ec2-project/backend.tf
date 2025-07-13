terraform {
  backend "s3" {
    bucket         = "sauravbhattarai-terraform-state"
    key            = "ec2-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sauravbhattarai-terraform-locks"
    encrypt        = true
  }
} 