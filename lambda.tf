resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "file_processor" {
  function_name = var.lambda_function_name
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda.zip"

  environment {
    variables = {
      DB_TABLE = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "generate_api_key" {
  function_name = "generateApiKey"
  runtime       = "python3.9"
  handler       = "lambda_generate_api_key.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_generate_api_key.zip"  # Make sure it's zipped

  environment {
    variables = {
      USAGE_PLAN_ID    = aws_api_gateway_usage_plan.file_api_usage_plan.id
      SES_SENDER_EMAIL = "lawrencedavis0101@gmail.com"  # Must be verified in AWS SES
    }
  }
}

resource "aws_lambda_function" "get_metadata" {
  function_name = "getMetadata"
  runtime       = "python3.9"
  handler       = "lambda_get_metadata.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda_get_metadata.zip"

  environment {
    variables = {
      FILE_METADATA_TABLE = aws_dynamodb_table.file_metadata.name
    }
  }
}

