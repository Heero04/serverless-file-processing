# Variable to specify the AWS region for resource deployment
# This can be overridden when applying the Terraform configuration
variable "aws_region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}
