# 🟢 S3 ACCESS POLICY (Lambda can read/write + list bucket)
resource "aws_iam_policy" "s3_access" {
  name = "S3SecureAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "${aws_s3_bucket.file_storage.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"], # ✅ Allow Lambda to list S3 files
        Resource = aws_s3_bucket.file_storage.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# 🟢 ALLOW S3 TO TRIGGER LAMBDA
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_storage.arn
}

# 🟢 DYNAMODB ACCESS POLICY (Lambda can read/write DynamoDB)
resource "aws_iam_policy" "lambda_dynamodb_access" {
  name        = "LambdaDynamoDBAccess"
  description = "Allow Lambda to write and read from DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query" # ✅ Added Query for better lookups
        ],
        Resource = "arn:aws:dynamodb:us-east-1:469440861178:table/FileMetadata"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access.arn
}

# 🟢 KMS ACCESS POLICY (Allow Lambda to Decrypt using KMS)
resource "aws_iam_policy" "lambda_kms_access" {
  name        = "LambdaKMSAccess"
  description = "Allow Lambda to decrypt using KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "arn:aws:kms:us-east-1:469440861178:key/265714b6-e105-4d31-8e74-e5c15642fda2"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_kms_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_kms_access.arn
}

# 🟢 IAM Role for API Gateway to Push Logs to CloudWatch
resource "aws_iam_role" "apigateway_cloudwatch" {
  name = "APIGatewayCloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_cloudwatch_attach" {
  role       = aws_iam_role.apigateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "apigateway_logging" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch.arn
}

# 🟢 Lambda Permissions to Manage API Keys & Send Emails
resource "aws_iam_policy" "lambda_api_key_access" {
  name = "LambdaApiKeyAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # ✅ API Gateway Permissions (Allow Lambda to Create & Manage API Keys)
      {
        Effect = "Allow",
        Action = [
          "apigateway:POST",
          "apigateway:CreateApiKey",
          "apigateway:CreateUsagePlanKey",
          "apigateway:GetApiKey",
          "apigateway:GetUsagePlanKeys",
          "apigateway:UpdateApiKey",
          "apigateway:DeleteApiKey"
        ],
        Resource = "arn:aws:apigateway:us-east-1::/apikeys/*"
      },

      # ✅ 🔹 NEW: Allow Lambda to Manage API Gateway Resources
      {
        Effect = "Allow",
        Action = [
          "apigateway:POST",
          "apigateway:PATCH",
          "apigateway:GET",
          "apigateway:DELETE"
        ],
        Resource = "arn:aws:apigateway:us-east-1::*"
      },

      # ✅ AWS SES Permissions (Allow Lambda to Send Emails)
      {
        Effect   = "Allow",
        Action   = "ses:SendEmail",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_api_key_access_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_api_key_access.arn
}


# 🟢 CloudWatch Logging Access for Lambda
resource "aws_iam_policy" "lambda_cloudwatch_access" {
  name = "LambdaCloudWatchAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:469440861178:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_access.arn
}
