# Configure Terraform and required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.1"
    }
  }
}

# Configure the AWS Provider with default tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "serverless-file-processing"
      Environment = terraform.workspace
      Owner       = "team-engineering"
      CostCenter  = "product-uploads"
    }
  }
}

