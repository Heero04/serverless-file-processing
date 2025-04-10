# Import required AWS SDK and standard libraries
import json
import boto3
import os
from urllib.parse import unquote_plus  # ✅ Fix for URL-decoded S3 keys

# Initialize AWS clients for ECS and SQS services
ecs = boto3.client('ecs')
sqs = boto3.client('sqs')

# Get environment variables for AWS resource configuration
cluster         = os.environ['ECS_CLUSTER']
task_definition = os.environ['TASK_DEF']
subnet_id       = os.environ['SUBNET_ID']
security_group  = os.environ['SECURITY_GROUP_ID']
queue_url       = os.environ['QUEUE_URL']

# Main Lambda handler function that processes SQS messages containing S3 events
def lambda_handler(event, context):
    # Iterate through each record in the SQS event
    for record in event['Records']:
        try:
            # Parse the message body as JSON
            body = json.loads(record['body'])

            # ✅ Defensive check for valid S3 event structure
            if 'Records' not in body or 's3' not in body['Records'][0]:
                print("⚠️ Skipping message: invalid format")
                continue

            # ✅ Extract and decode bucket/key from S3 event
            s3_info = body['Records'][0]['s3']
            bucket = s3_info['bucket']['name']
            key    = unquote_plus(s3_info['object']['key'])  # ✅ decode key
            format_type = "pdf"

            # Prepare input payload for ECS task
            input_payload = {
                "input_file": f"s3://{bucket}/{key}",
                "output_format": format_type
            }

            # ✅ Launch ECS Fargate task with network and container configurations
            response = ecs.run_task(
                cluster=cluster,
                launchType='FARGATE',
                taskDefinition=task_definition,
                networkConfiguration={
                    'awsvpcConfiguration': {
                        'subnets': [subnet_id],
                        'securityGroups': [security_group],
                        'assignPublicIp': 'ENABLED'
                    }
                },
                overrides={
                    'containerOverrides': [
                        {
                            'name': 'file-converter',
                            'environment': [
                                {'name': 'INPUT_FILE', 'value': input_payload['input_file']},
                                {'name': 'OUTPUT_FORMAT', 'value': input_payload['output_format']}
                            ]
                        }
                    ]
                }
            )

            print(f"🚀 Started Fargate task: {response['tasks'][0]['taskArn']}")

        except Exception as e:
            # Log any errors that occur during message processing
            print(f"❌ Error processing record: {str(e)}")

        # ✅ Clean up by removing processed message from SQS queue
        try:
            sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=record['receiptHandle']
            )
            print("🧹 Deleted message from SQS")
        except Exception as delete_error:
            # Log any errors that occur during message deletion
            print(f"❌ Failed to delete message: {str(delete_error)}")
