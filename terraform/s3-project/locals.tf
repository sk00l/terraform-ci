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

}


resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
