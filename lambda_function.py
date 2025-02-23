import json
import boto3
import urllib.parse
import logging
import os

# Set up logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize boto3 clients/resources
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Use environment variable for the DynamoDB table name (with a default)
TABLE_NAME = os.environ.get('FILE_METADATA_TABLE', 'FileMetadata')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    # Initialize a response structure
    results = {
        'processed': [],
        'failed': []
    }

    for record in event.get('Records', []):
        try:
            bucket = record['s3']['bucket']['name']
            # Decode the S3 key in case it is URL-encoded
            key = urllib.parse.unquote_plus(record['s3']['object']['key'])
            
            logger.info(f"Processing file '{key}' from bucket '{bucket}'")

            # Get file metadata from S3
            response = s3.head_object(Bucket=bucket, Key=key)
            size = response.get('ContentLength', 0)
            file_type = response.get('ContentType', 'unknown')

            # Store metadata in DynamoDB
            table.put_item(Item={
                'file_name': key,
                'bucket_name': bucket,
                'size': size,
                'file_type': file_type
            })

            logger.info(f"Stored metadata for file '{key}' successfully.")
            results['processed'].append(key)
        except Exception as e:
            logger.error(f"Error processing file: {e}")
            results['failed'].append(record)
            # Optionally, you could raise an error to fail the Lambda entirely
            # or simply continue processing other records.

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'File processing completed.',
            'details': results
        })
    }

