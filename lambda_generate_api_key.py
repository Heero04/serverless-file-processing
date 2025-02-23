import json
import boto3
import os
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
apigateway = boto3.client('apigateway')
ses = boto3.client('ses')

# Define API Gateway & SES settings from environment variables
USAGE_PLAN_ID = os.environ.get("USAGE_PLAN_ID")  # Set in Terraform
SES_SENDER_EMAIL = os.environ.get("SES_SENDER_EMAIL")  # Set in Terraform

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        user_email = body.get("email")

        if not user_email:
            logger.error("Email not provided in the request body.")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Email is required"})
            }

        logger.info(f"Creating API key for {user_email}...")

        # Step 1: Generate API Key
        response = apigateway.create_api_key(
            name=f"UserKey-{user_email}",
            enabled=True
            # Optionally add: generateDistinctId=True or includeValue parameter if needed
        )
        api_key_id = response['id']
        api_key_value = response.get('value')
        logger.info(f"API key created with ID: {api_key_id}")

        # Step 2: Attach API Key to Usage Plan
        apigateway.create_usage_plan_key(
            usagePlanId=USAGE_PLAN_ID,
            keyId=api_key_id,
            keyType="API_KEY"
        )
        logger.info("API key attached to usage plan.")

        # Step 3: Send Email with API Key
        email_body = f"""
        Hello,

        Your API key for accessing the service is: {api_key_value}

        Please use this key in your requests by including:
        `x-api-key: {api_key_value}` in the headers.

        Regards,
        Serverless File Processing Team
        """
        ses.send_email(
            Source=SES_SENDER_EMAIL,
            Destination={"ToAddresses": [user_email]},
            Message={
                "Subject": {"Data": "Your API Key"},
                "Body": {"Text": {"Data": email_body}}
            }
        )
        logger.info("Email sent with API key.")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "API Key sent to email"})
        }
    except Exception as e:
        logger.exception("Error processing request:")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
