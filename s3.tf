resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Used to create a unique name, then replaced with the generated one.
# (Originally used: "serverless-file-processing-${random_id.bucket_suffix.hex}")
resource "aws_s3_bucket" "file_storage" {
  bucket = "serverless-file-processing-db59f2f4" # 🔹 Replace if needed
}

resource "aws_s3_bucket_public_access_block" "secure_s3" {
  bucket                  = aws_s3_bucket.file_storage.id
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
