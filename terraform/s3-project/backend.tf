terraform {
  backend "s3" {
    bucket         = "sauravbhattarai-terraform-state"
    key            = "s3-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sauravbhattarai-terraform-locks"
  }
} 