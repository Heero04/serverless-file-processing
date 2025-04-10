# Name of the S3 bucket created for React uploads
output "bucket_name" {
  value = aws_s3_bucket.react_uploads.bucket
}

# IAM access key ID for React application
output "aws_access_key_id" {
  value = aws_iam_access_key.react_key.id
}

# IAM secret access key for React application (sensitive value)
output "aws_secret_access_key" {
  value     = aws_iam_access_key.react_key.secret
  sensitive = true
}

# ARN of SNS topic for conversion complete notifications
output "sns_topic_arn" {
  value = aws_sns_topic.conversion_complete.arn
}

# ID of the public subnet
output "subnet_id" {
  value = aws_subnet.public_1.id
}

# ID of security group allowing outbound traffic
output "security_group_id" {
  value = aws_security_group.allow_outbound.id
}
