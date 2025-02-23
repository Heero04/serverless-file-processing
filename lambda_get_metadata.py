import json
import boto3
import os
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')

# Use environment variable for the DynamoDB table name
TABLE_NAME = os.environ.get('FILE_METADATA_TABLE', 'FileMetadata')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    logger.info("Lambda function invoked for fetching metadata.")

    # Extract file name from query string parameters
    file_name = event.get('queryStringParameters', {}).get('file')

    if not file_name:
        logger.error("No file name provided.")
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": "File name is required"})
        }

    logger.info(f"Fetching metadata for file: {file_name}")

    try:
        # Query DynamoDB for the file metadata
        response = table.get_item(Key={'file_name': file_name})

        if 'Item' not in response:
            logger.error(f"File '{file_name}' not found in database.")
            return {
                "statusCode": 404,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"error": "File not found"})
            }

        logger.info(f"Metadata found: {response['Item']}")
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(response['Item'])
        }

    except Exception as e:
        logger.exception("Error querying DynamoDB:")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": f"Internal server error: {str(e)}"})
        }
