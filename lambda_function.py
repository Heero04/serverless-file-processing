import json
import boto3

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FileMetadata')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get file metadata
        response = s3.head_object(Bucket=bucket, Key=key)
        size = response['ContentLength']
        file_type = response['ContentType']

        # Store metadata in DynamoDB
        table.put_item(Item={
            'file_name': key,
            'bucket_name': bucket,
            'size': size,
            'file_type': file_type
        })

    return {
        'statusCode': 200,
        'body': json.dumps('File processed successfully!')
    }
