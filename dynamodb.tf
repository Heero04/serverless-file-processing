resource "aws_dynamodb_table" "file_metadata" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"

  attribute {
    name = "file_name"
    type = "S"
  }

  point_in_time_recovery { enabled = true }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo_kms.arn
  }
}

resource "aws_kms_key" "dynamo_kms" {
  description             = "KMS Key for encrypting DynamoDB table"
  deletion_window_in_days = 10
}
