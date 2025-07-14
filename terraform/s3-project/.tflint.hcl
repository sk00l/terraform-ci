plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  force       = false
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "aws_s3_bucket_invalid_bucket" {
  enabled = true
}

rule "aws_s3_bucket_invalid_region" {
  enabled = true
}

rule "aws_s3_bucket_invalid_versioning" {
  enabled = true
}

rule "aws_s3_bucket_invalid_lifecycle_rule" {
  enabled = true
}

rule "aws_s3_bucket_invalid_policy" {
  enabled = true
}
