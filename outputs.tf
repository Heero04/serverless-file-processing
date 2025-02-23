output "s3_bucket_name" {
  value = aws_s3_bucket.file_storage.id
}

output "lambda_function_name" {
  value = aws_lambda_function.file_processor.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.file_metadata.name
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.file_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}
