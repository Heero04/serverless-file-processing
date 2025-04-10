# SQS queue for processing S3 file uploads
resource "aws_sqs_queue" "file_upload_queue" {
  name                       = "file-upload-queue-${terraform.workspace}"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 0

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.file_upload_dlq.arn
    maxReceiveCount     = 5
  })
}


resource "aws_sqs_queue_policy" "file_upload_queue_policy" {
  queue_url = aws_sqs_queue.file_upload_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowS3SendMessage",
        Effect    = "Allow",
        Principal = { Service = "s3.amazonaws.com" },
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.file_upload_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.react_uploads.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue" "file_upload_dlq" {
  name = "file-upload-dlq-${terraform.workspace}"
}




