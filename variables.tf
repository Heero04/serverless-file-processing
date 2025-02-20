variable "aws_region" {
  default = "us-east-1"
}

variable "s3_bucket_name" {
  default = "serverless-file-processing-db59f2f4"
}

variable "dynamodb_table_name" {
  default = "FileMetadata"
}

variable "lambda_function_name" {
  default = "fileProcessor"
}
