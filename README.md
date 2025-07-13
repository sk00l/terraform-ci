# Multi-Environment Terraform Setup with GitHub Actions

This project demonstrates a multi-environment Terraform setup with separate projects for EC2 and S3 resources, using remote state to share data between projects.

## Project Structure

```
├── terraform/
│   ├── ec2-project/          # EC2 instance project
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   └── backend.tf
│   ├── s3-project/           # S3 bucket project
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   └── backend.tf
│   └── shared/               # Shared modules and configurations
│       ├── modules/
│       └── data.tf
├── .github/
│   └── workflows/
│       ├── ci-cd.yml         # Main CI/CD workflow
│       └── deploy.yml        # Deployment workflow
├── scripts/
│   └── version.sh           # Version calculation script
└── README.md
```

## Features

- **Multi-Environment Setup**: Separate Terraform projects for EC2 and S3 resources
- **Remote State Integration**: S3 project reads EC2 instance ARN from EC2 project's remote state
- **GitHub Actions CI/CD**: Automated workflows for linting, security scanning, planning, and deployment
- **Protected Main Branch**: Requires 2 reviews and passing CI checks
- **Version Management**: Automated versioning and release management
- **Security**: tfsec integration for security scanning

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- GitHub repository with branch protection rules
- AWS S3 bucket for Terraform state storage

## Usage

1. **Setup Branch Protection**:
   - Protect the main branch
   - Require 2 reviews for pull requests
   - Require status checks to pass before merging

2. **Configure AWS Credentials**:
   - Set up AWS credentials in GitHub Secrets
   - Configure different credentials for dev/prod environments

3. **Deploy Infrastructure**:
   - Create pull request to trigger CI/CD pipeline
   - Review and approve changes
   - Merge to deploy to production

## Workflow Process

1. **Pull Request Creation**:
   - Lint, validate, and security scan
   - Generate terraform plan
   - Create build artifact for testing

2. **Pull Request Merge**:
   - Generate release artifact
   - Deploy to production environment

## Security Features

- tfsec security scanning
- Terraform validation and formatting
- Branch protection with required reviews
- Automated artifact generation and deployment 