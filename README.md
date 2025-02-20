# 📂 Serverless File Processing System - Deployment Guide

## 📌 Overview
This project is a serverless file processing system built using AWS Lambda, S3, DynamoDB, and API Gateway, deployed via Terraform. The system automatically processes uploaded files, extracts metadata, and stores it for retrieval via an API.

## 🔹 How It Works:
1️⃣ A file is uploaded to an AWS S3 bucket, triggering an AWS Lambda function.
2️⃣ Lambda extracts file metadata (file name, type, size, timestamp).
3️⃣ The extracted metadata is stored in a DynamoDB table.
4️⃣ Users can retrieve metadata via an API Gateway endpoint.

✅ Fully serverless
✅ Automated metadata extraction
✅ Scalable & cost-effective solution

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
├── .github/workflows/deploy.yml   # GitHub Actions CI/CD Workflow

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
🔹 1️⃣ Add SNS Notifications: Send an email when a file is processed.

🔹 2️⃣ Implement a Frontend: Build a UI to upload files & view metadata.

🔹 3️⃣ Add CI/CD with GitHub Actions: Automate deployments further.

🔹 4️⃣ Enable Object Expiration: Automatically delete files after X days.

🔹 5️⃣ Improve API Security: Use JWT authentication with Cognito.

## 🔥 Next Steps
    ✔ Push this README.md to GitHub

    ✔ Make your GitHub repository Public (so recruiters can see it)

    ✔ Set up GitHub Actions for automated deployments (if not done)

