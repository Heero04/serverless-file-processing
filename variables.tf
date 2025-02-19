variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  default = "serverless-file-processing-bucket"
}

variable "dynamodb_table_name" {
  default = "FileMetadata"
}

variable "lambda_function_name" {
  default = "fileProcessor"
}
