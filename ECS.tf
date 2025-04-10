# ECS cluster to run our file converter tasks
resource "aws_ecs_cluster" "main" {
  name = "file-converter-cluster-${terraform.workspace}"
}

# ECR repository to store our file converter container images
resource "aws_ecr_repository" "file_converter" {
  name = "file-converter"
}

# Task definition that specifies how to run our file converter container
resource "aws_ecs_task_definition" "file_processor" {
  # Unique name for this task definition family
  family = "file-converter-${terraform.workspace}"
  # Use AWS VPC networking mode required for Fargate
  network_mode = "awsvpc"
  # Specify that this task runs on Fargate
  requires_compatibilities = ["FARGATE"]
  # Allocate CPU and memory resources
  cpu    = 512
  memory = 1024
  # IAM roles for task execution and runtime permissions
  execution_role_arn = aws_iam_role.fargate_task_role.arn
  task_role_arn      = aws_iam_role.fargate_task_role.arn

  # Container configuration
  container_definitions = jsonencode([{
    name = "file-converter"
    # Reference to container image in ECR
    image     = "469440861178.dkr.ecr.us-east-1.amazonaws.com/file-converter:latest"
    essential = true
    # Environment variables passed to container
    environment = [
      { name = "AWS_REGION", value = var.aws_region },
      { name = "SNS_TOPIC_ARN", value = aws_sns_topic.conversion_complete.arn }
    ],
    # CloudWatch logs configuration
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/ecs/file-converter-${terraform.workspace}",
        awslogs-region        = var.aws_region,
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

}

# CloudWatch log group to store container logs
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/file-converter-${terraform.workspace}"
  # Keep logs for 7 days
  retention_in_days = 7
}
