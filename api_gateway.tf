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
  authorization = "AWS_IAM"
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

