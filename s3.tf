resource "aws_s3_bucket" "file_storage" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_public_access_block" "secure_s3" {
  bucket = aws_s3_bucket.file_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.file_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
