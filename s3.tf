# S3 bucket for storing React application uploads
# Uses workspace name in bucket name for environment separation
# Configured with private access and force destroy enabled
resource "aws_s3_bucket" "react_uploads" {
  bucket        = "my-react-upload-${terraform.workspace}"
  force_destroy = true

  tags = {
    Environment = terraform.workspace
    App         = "ReactUploader"
  }
}

resource "aws_s3_bucket_cors_configuration" "react_uploads_cors" {
  bucket = aws_s3_bucket.react_uploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "HEAD"]
    allowed_origins = ["http://localhost:3000"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


# Enables default server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.react_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Configures lifecycle rule to automatically delete objects after 1 day
# Helps manage storage costs and cleanup of temporary uploads
resource "aws_s3_bucket_lifecycle_configuration" "delete_after_1_day" {
  bucket = aws_s3_bucket.react_uploads.id

  rule {
    id     = "delete-uploads-after-1-day"
    status = "Enabled"

    expiration {
      days = 1
    }

    filter {
      prefix = ""
    }
  }
}

# S3 bucket notification configuration to send events to SQS queue
resource "aws_s3_bucket_notification" "s3_to_sqs" {
  bucket = aws_s3_bucket.react_uploads.id

  queue {
    queue_arn = aws_sqs_queue.file_upload_queue.arn
    events    = ["s3:ObjectCreated:*"]

    # Optional: filter by prefix/suffix
    # filter_suffix = ".jpg"
    # filter_prefix = "uploads/"
  }

  depends_on = [aws_sqs_queue_policy.file_upload_queue_policy]
}
