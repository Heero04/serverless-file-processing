# Lambda function that triggers Fargate tasks in response to SQS messages
resource "aws_lambda_function" "fargate_trigger" {
  filename         = "lambda_trigger_fargate_v2.zip"
  function_name    = "trigger_fargate_from_sqs_${terraform.workspace}"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_trigger_fargate.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = filebase64sha256("lambda_trigger_fargate_v2.zip") # Updated filename match

  timeout = 10

  environment {
    variables = {
      ECS_CLUSTER       = aws_ecs_cluster.main.name
      TASK_DEF          = aws_ecs_task_definition.file_processor.arn
      SUBNET_ID         = aws_subnet.public_1.id
      SECURITY_GROUP_ID = aws_security_group.allow_outbound.id
      QUEUE_URL         = aws_sqs_queue.file_upload_queue.id
    }
  }
}

# Event source mapping to connect SQS queue to Lambda function
resource "aws_lambda_event_source_mapping" "link_lambda_to_sqs" {
  event_source_arn = aws_sqs_queue.file_upload_queue.arn
  function_name    = aws_lambda_function.fargate_trigger.arn
  batch_size       = 1
  enabled          = true
}