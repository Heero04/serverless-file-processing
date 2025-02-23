resource "aws_api_gateway_rest_api" "file_api" {
  name        = "FileAPI"
  description = "API for file metadata retrieval"
}

# Define the API Gateway Resource (the URL path)
resource "aws_api_gateway_resource" "get_metadata" {
  rest_api_id = aws_api_gateway_rest_api.file_api.id
  parent_id   = aws_api_gateway_rest_api.file_api.root_resource_id
  path_part   = "metadata" # The URL path (e.g., /metadata)
}

# Reference the API Gateway Resource correctly
resource "aws_api_gateway_method" "get_metadata" {
  rest_api_id   = aws_api_gateway_rest_api.file_api.id
  resource_id   = aws_api_gateway_resource.get_metadata.id # 
  http_method   = "GET"
  authorization = "NONE"  # Change from "AWS_IAM" to "NONE"
  # api_key_required = true
}

# Attach API Gateway to Lambda
resource "aws_api_gateway_integration" "lambda_get_metadata" {
  rest_api_id = aws_api_gateway_rest_api.file_api.id
  resource_id = aws_api_gateway_resource.get_metadata.id
  http_method = aws_api_gateway_method.get_metadata.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_metadata.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw_get_metadata" {
  statement_id  = "AllowExecutionFromAPIGatewayGetMetadata"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_metadata.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.file_api.execution_arn}/*/*"
}

resource "aws_api_gateway_api_key" "file_api_key" {
  name    = "FileAPIKey"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "file_api_usage_plan" {
  name = "FileAPIUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.file_api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }

  throttle_settings {
    rate_limit  = 10 # Max 10 requests per second
    burst_limit = 20 # Allow up to 20 requests in a burst
  }
}

resource "aws_api_gateway_usage_plan_key" "file_api_key_usage" {
  key_id        = aws_api_gateway_api_key.file_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.file_api_usage_plan.id
}

# WAF Protection for API Gateway
resource "aws_wafv2_web_acl" "api_waf" {
  name  = "api-security-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "waf-rate-limit"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "api-waf"
  }
}
# deploy api gateway
resource "aws_api_gateway_deployment" "file_api" {
  rest_api_id = aws_api_gateway_rest_api.file_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.file_api))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.file_api.id
  deployment_id = aws_api_gateway_deployment.file_api.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format          = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      resourcePath    = "$context.resourcePath"
      status          = "$context.status"
      responseLength  = "$context.responseLength"
    })
  }

  xray_tracing_enabled = true

  # Ensure CloudWatch Logging Role is Set Before Updating Stage
  depends_on = [aws_api_gateway_account.apigateway_logging]
}


resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.file_api.name}"
  retention_in_days = 7
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.file_api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "request_api_key" {
  rest_api_id = aws_api_gateway_rest_api.file_api.id
  parent_id   = aws_api_gateway_rest_api.file_api.root_resource_id
  path_part   = "request-key"
}

resource "aws_api_gateway_method" "request_api_key" {
  rest_api_id   = aws_api_gateway_rest_api.file_api.id
  resource_id   = aws_api_gateway_resource.request_api_key.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "request_api_key_lambda" {
  rest_api_id = aws_api_gateway_rest_api.file_api.id
  resource_id = aws_api_gateway_resource.request_api_key.id
  http_method = aws_api_gateway_method.request_api_key.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.generate_api_key.invoke_arn
}



