resource "aws_kms_key" "lambda_key" {
  description             = "KMS key for Lambda file processing"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaRoleDecrypt",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.lambda_exec.name}"
        },
        Action   = "kms:Decrypt",
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
