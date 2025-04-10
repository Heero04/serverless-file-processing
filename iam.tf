# --- IAM ROLE FOR React FARGATE ---
# IAM user for React application to upload files to S3
resource "aws_iam_user" "react_uploader" {
  name = "react-uploader-${terraform.workspace}"
}

# Access key credentials for the React uploader user
resource "aws_iam_access_key" "react_key" {
  user = aws_iam_user.react_uploader.name
}

# IAM policy allowing the React uploader user to put objects in S3
resource "aws_iam_user_policy" "react_upload_policy" {
  name = "s3-upload-policy-${terraform.workspace}"
  user = aws_iam_user.react_uploader.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject", # upload
          "s3:GetObject", # required to generate presigned URL
          "s3:HeadObject" # required to check if the file exists
        ],
        Resource = "${aws_s3_bucket.react_uploads.arn}/*"
      }
    ]
  })
}

# --- IAM ROLE FOR FARGATE and ECS ---

# IAM role for Fargate tasks with trust policy for ECS
resource "aws_iam_role" "fargate_task_role" {
  name = "fargate_task_role_${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy allowing Fargate tasks to read and write to S3
resource "aws_iam_role_policy" "fargate_s3_access" {
  name = "fargate-s3-access"
  role = aws_iam_role.fargate_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.react_uploads.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.react_uploads.bucket}/*"
        ]
      }
    ]
  })
}


# Attach ECR read-only policy to Fargate task role to allow pulling container images
resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.fargate_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach CloudWatch Logs full access policy to Fargate task role to allow container logging
resource "aws_iam_role_policy_attachment" "fargate_logs" {
  role       = aws_iam_role.fargate_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# IAM policy allowing Fargate tasks to publish messages to the conversion complete SNS topic
resource "aws_iam_role_policy" "fargate_sns_access" {
  name = "fargate-sns-publish-${terraform.workspace}"
  role = aws_iam_role.fargate_task_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = aws_sns_topic.conversion_complete.arn
      }
    ]
  })
}

# --- IAM ROLE FOR React LAMBDA ---
# IAM role for Lambda execution with basic Lambda service assume role policy
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM policy attached to Lambda role granting permissions for ECS, IAM, SQS and CloudWatch Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-fargate-starter"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ecs:RunTask"],
        Resource = aws_ecs_task_definition.file_processor.arn
      },
      {
        Effect   = "Allow",
        Action   = ["iam:PassRole"],
        Resource = aws_iam_role.fargate_task_role.arn
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.file_upload_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

# --- IAM ROLE FOR EVENTBRIDGE PIPE TO START FARGATE ---
resource "aws_iam_role" "eventbridge_pipe_role" {
  name = "eventbridge-pipe-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "pipes.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_pipe_policy" {
  name = "pipe-ecs-invoke-policy-${terraform.workspace}"
  role = aws_iam_role.eventbridge_pipe_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.file_upload_queue.arn
      }
    ]
  })
}