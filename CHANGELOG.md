# 📌 Changelog   
## [v2.3] - 2025-04-09

### Added
- **Presigned PDF Download Integration (Step 5):**
  - Added `PDFLink.js` React component that polls S3 for a converted `.pdf` file and generates a secure presigned URL once available
  - Used `AWS SDK v2` (`getSignedUrl('getObject')`) to generate 1-hour download links without exposing public access
  - Implemented polling every 10 seconds using `headObject` to check file readiness
  - Displayed UX message indicating estimated conversion time for better user feedback

- **CORS Fix for S3 Polling:**
  - Updated `aws_s3_bucket_cors_configuration` in Terraform to allow `"HEAD"` method
  - Enabled localhost development access with `allowed_origins = ["http://localhost:3000"]`

- **Filename Normalization:**
  - Matched ECS backend behavior by stripping only the final file extension from `.docx` uploads to determine converted output key (e.g., `.docx` → `.pdf`)
  - Ensured filename compatibility across React + ECS layers

- **Unicode PDF Conversion Support:**
  - Fixed `UnicodeEncodeError` in backend PDF conversion (`fpdf`) by switching to Unicode-safe font embedding
  - Added installation of `fonts-dejavu-core` in Dockerfile to support full UTF-8 characters (e.g., “–”, “✓”, smart quotes)
  - Updated `convert_docx_to_pdf()` in `processor.py` to register `DejaVuSans.ttf` with `add_font(..., uni=True)` and set it for consistent rendering across files

### Security
- Confirmed IAM policy for React uploader includes `s3:GetObject`, `s3:HeadObject`, and `s3:PutObject`
- Maintained least-privilege access via scoped bucket-level permissions


## [v2.2] - 2025-04-06

### Added
- **Fargate-Powered File Conversion (Step 3):**
  - Created ECS Task Definition using `file-converter` Docker image
  - Added environment variables `AWS_REGION` and `SNS_TOPIC_ARN` for runtime configuration
  - Integrated ECS Fargate to download source file from S3, simulate conversion, and upload result to `converted/` folder
  - Used `jsonencode()` to manage dynamic container configuration within Terraform

- **Presigned URL + SNS Notification (Step 4):**
  - Generated time-limited presigned URLs via `boto3`
  - Published SNS notification to email subscribers with download link
  - Configured SNS topic `conversion-complete-${terraform.workspace}` and verified email subscription
  - Passed `SNS_TOPIC_ARN` into container as an environment variable for dynamic publishing

- **Security Improvements:**
  - Added scoped IAM policy to Fargate task role allowing `sns:Publish` only to the correct topic
  - Ensured minimal privilege access throughout all IAM configurations

## [v2.0] - 2025-04-06

### Added
- **Fargate-Based File Processing (Step 3):**
  - Built a **Dockerized Python processor** to run inside AWS Fargate
  - Extracted `INPUT_FILE` and `OUTPUT_FORMAT` from environment variables for dynamic processing
  - Used `boto3` to download files from the `uploads/` folder in S3 and upload results to `converted/`

- **ECR + ECS Integration:**
  - Created ECR repository and pushed `file-converter` image for task use
  - Defined ECS Task Definition with workspace-aware CloudWatch Log Group: `/ecs/file-converter-${terraform.workspace}`
  - Configured logging, environment variables, and memory/CPU for task execution

- **Trigger Flow via SQS:**
  - S3 event sends messages to an SQS queue on file upload
  - Lambda function reads from SQS and triggers ECS Fargate task
  - Enabled dynamic task launching based on message contents (bucket path, file type, etc.)

- **IAM Enhancements:**
  - Extended Fargate task role with `s3:GetObject`, `s3:PutObject`, and `s3:ListBucket` permissions
  - Attached `CloudWatchLogsFullAccess` for task logging
  - Ensured roles have access to ECS, ECR, and log streams needed for execution

## [v1.0] - 2025-04-05

### Added
- **Direct S3 Upload Flow (Step 1):**
  - Created a **React-based file upload interface** using AWS SDK v2 and direct `s3.upload()` calls
  - Configured file selection, upload trigger, and basic UI feedback
  - Connected React securely to S3 via environment variables for `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_BUCKET_NAME`

- **S3 Bucket Infrastructure:**
  - Terraform-managed **workspace-aware S3 bucket**: `my-react-upload-${terraform.workspace}`
  - Applied **default server-side encryption (SSE-S3)** to all new objects
  - Enforced **private ACL** and **blocked all public access**
  - Added **lifecycle policy** to auto-delete all objects after 1 day

- **IAM Setup:**
  - Created scoped IAM user for React uploads: `react-uploader-${terraform.workspace}`
  - Attached least-privilege inline policy to allow `s3:PutObject` access to the specific S3 bucket
  - Outputted access key and secret key for use in `.env`-based frontend integration

- **React Environment Setup:**
  - Added `.env` file to securely manage AWS credentials locally
  - Modularized upload logic via `s3.js` and UI via `S3Uploader.js` or `TemplateUploader.js`
  - Enabled clean separation between infrastructure (Terraform) and frontend behavior (React)
