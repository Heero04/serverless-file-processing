# 🚀 Serverless File Processing System
# Fully Serverless | Event-Driven | Scalable
This project automatically processes files uploaded to AWS S3, extracts metadata, stores it in DynamoDB, and provides an API Gateway to retrieve metadata.

✅ Fully Serverless – No servers to manage

✅ Event-Driven Processing – Automatic metadata extraction

✅ Fast & Scalable – Built with AWS-native services

✅ Infrastructure as Code – Managed via Terraform

📌 How It Works

| Step  | What Happens? | AWS Services Used |
| ------------- | ------------- | ------------- |
| 1️⃣ Upload File to S3  | A user uploads a file to an S3 bucket  | Amazon S3  |
| 2️⃣ S3 Triggers Lambda | An S3 event triggers the Lambda function to process the file | AWS Lambda + S3 Event Notifications |
| 3️⃣ Lambda Extracts Metadata | Lambda retrieves file details (size, type, name, etc.)  | AWS Lambda + Boto3  |
| 4️⃣ Metadata is Stored in DynamoDB  | Lambda writes file metadata into a DynamoDB table | Amazon DynamoDB  |
| 5️⃣ API Gateway Fetches Metadata | A user makes an API call to retrieve file details  | API Gateway → getMetadata Lambda  |

✅ Files are processed automatically—no manual intervention needed!

# 📌 How to Use This System

# 1️⃣ Upload a File (Via AWS CLI)

📌 Upload via AWS CLI:
    
    aws s3 cp sample.txt s3://serverless-file-processing-db59f2f4/

✅ Once uploaded, Lambda will automatically process the file!

# 2️⃣ Retrieve File Metadata (No API Key Required)
Once a file is processed, retrieve metadata via API Gateway.
    
    curl -X GET "https://c2u8nkbdsj.execute-api.us-east-1.amazonaws.com/prod/metadata?file=sample.txt"

✅ Expected Output (If File Exists in Database)

    {
  "file_name": "sample.txt",
  "bucket_name": "serverless-file-processing-db59f2f4",
  "size": 27,
  "file_type": "text/plain"
    }

📌 If the file is not found:

Make sure Lambda processed the upload (check logs)
Try uploading a new file and testing again


## 🌟 Features
✔ Event-Driven Processing: S3 triggers Lambda automatically when a file is uploaded.

✔ Serverless & Scalable: No need to manage servers; pay only for what you use.

✔ DynamoDB for Fast Lookup: Quick metadata retrieval via API.

✔ Secure AWS Infrastructure: IAM, encryption, and API protection applied.

✔ Automated Deployment: Infrastructure as Code (IaC) with Terraform.

## 🔒 Security Best Practices
🔹 S3 Bucket Security: Public access blocked, encryption enabled.
🔹 IAM Least Privilege: Lambda and API Gateway have minimal required permissions.
🔹 DynamoDB Encryption: Data encrypted at rest with AWS KMS.
🔹 API Gateway Security: Protected via AWS IAM authentication & WAF.
🔹 Terraform State Security: .gitignore prevents exposing sensitive Terraform state files.

## 📋 Prerequisites
Before deploying, make sure you have:
🔹 AWS CLI Installed & Configured (aws configure)

🔹 Terraform Installed (terraform -v to check)

🔹 Git Installed (git --version to check)

🔹 SSH Key Configured for GitHub

📂 Project Structure

📂 serverless-file-processing

├── lambda_function.py             # AWS Lambda Function Code

├── main.tf                        # Terraform Configuration

├── s3.tf                          # S3 Bucket Configuration

├── lambda.tf                      # Lambda Function & IAM Role

├── dynamodb.tf                     # DynamoDB Table

├── api_gateway.tf                  # API Gateway Configuration

├── iam.tf                          # IAM Policies & Roles

├── variables.tf                    # Terraform Variables

├── outputs.tf                      # Terraform Outputs

├── terraform.tfvars                 # Variable Values

├── .gitignore                      # Ignore Terraform state & secrets

└── README.md                       # Project Documentation

✅ This setup allows fully automated infrastructure deployment via Terraform!

## ⚡ Deployment Steps
### 1️⃣ Clone the Repository

    git clone git@github.com:Heero04/serverless-file-processing.git
    cd serverless-file-processing

### 2️⃣ Initialize Terraform

    terraform init

### 3️⃣ Set Up Your AWS Region & S3 Bucket Name
Edit the terraform.tfvars file:

    aws_region = "us-east-1"
    s3_bucket_name = "serverless-file-processing-db59f2f4"  # Replace with your fixed bucket name

### 4️⃣ Deploy Infrastructure
Run:

    terraform apply -auto-approve

🚀 This will create:
✅ An S3 bucket with security settings

✅ An AWS Lambda function triggered by S3

✅ A DynamoDB table for metadata storage

✅ An API Gateway for retrieving metadata


## 🛠 Verifying the Deployment

### 1️⃣ Upload a File to S3
Upload a test file to the S3 bucket:

    aws s3 cp sample.txt s3://serverless-file-processing-db59f2f4/

✅ This should trigger the Lambda function, which processes the file and stores metadata in DynamoDB.

### 2️⃣ Check Logs in AWS
View Lambda logs to confirm execution:
    
    aws logs tail /aws/lambda/fileProcessor --follow

### 3️⃣ Retrieve File Metadata via API Gateway
Run:
    curl -X GET "https://your-api-gateway-url.com/metadata?file=sample.txt"

✅ Expected API Response:

    {
    "file_name": "sample.txt",
    "bucket_name": "serverless-file-processing-db59f2f4",
    "size": 12345,
    "file_type": "text/plain"
    }

## ❓ Troubleshooting
File Not Processing?
Check if the Lambda function ran:

    aws logs tail /aws/lambda/fileProcessor --follow
    If there are errors, restart the function from AWS Console.

Metadata Not Showing in API Gateway?
Confirm DynamoDB has data:

    aws dynamodb scan --table-name FileMetadata
    If empty, check the Lambda execution logs.

## 🌐 API Gateway Security & IAM Authentication
By default, API Gateway is protected via AWS IAM authentication. If you want to make the API publicly accessible, update api_gateway.tf:

    resource "aws_api_gateway_method" "get_metadata" {
    authorization = "NONE"  # Removes IAM authentication (Use with caution!)
    }
## 🛑 Destroying Infrastructure
To remove all AWS resources created by Terraform:

    terraform destroy -auto-approve
    🚨 Warning: This will delete your S3 bucket, Lambda function, and DynamoDB table!

## 🤝 Contributing
Have ideas for improvements?
Fork this repo and submit a Pull Request! 🚀

## 📜 Future Enhancements
🔹 Web UI for File Uploads – Remove AWS Console/CLI dependency

🔹 Pre-Signed URLs for Secure Uploads – Users can upload files directly

🔹 API Key Authentication – Restrict API access to authorized users

🔹 Move AWS SES to Production Mode – Enable email notifications for file processing

🔹 Auto-Delete Processed Files – Use S3 lifecycle rules to clean old files
