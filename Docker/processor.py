# Import required libraries
import os
import json
import boto3
import subprocess
from docx import Document
from fpdf import FPDF

# Initialize AWS service clients
s3 = boto3.client("s3")
sns = boto3.client("sns")

# Download file from S3 bucket
def download_file(s3_path, local_path):
    bucket, key = s3_path.replace("s3://", "").split("/", 1)
    s3.download_file(bucket, key, local_path)
    return bucket, key

# Upload file to S3 bucket 
def upload_file(bucket, key, local_path):
    s3.upload_file(local_path, bucket, key)

# Scan a file using ClamAV
# def scan_file_for_viruses(file_path):
#    print(f"Scanning {file_path} for viruses...")
#    result = subprocess.run(["clamscan", file_path], capture_output=True, text=True)

#    print(result.stdout)  # Log scan result

#    if "Infected files: 0" not in result.stdout:
#        raise Exception(f"Virus detected in file: {file_path}\n{result.stdout}")

# Convert Word document to PDF
def convert_docx_to_pdf(input_path, output_path):
    document = Document(input_path)
    pdf = FPDF()
    pdf.add_page()

    # Use a Unicode-compatible TTF font
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    pdf.add_font("DejaVu", "", font_path, uni=True)
    pdf.set_font("DejaVu", "", 12)

    # Convert each paragraph to PDF
    for para in document.paragraphs:
        pdf.multi_cell(0, 10, para.text)

    pdf.output(output_path)

# Main function to orchestrate the file conversion process
def main():
    print("Starting file processor...")

    # Get environment variables
    input_file = os.environ.get("INPUT_FILE")
    output_format = os.environ.get("OUTPUT_FORMAT")
    sns_topic_arn = os.environ.get("SNS_TOPIC_ARN")

    # Validate required environment variables
    if not input_file or not output_format:
        raise Exception("Missing INPUT_FILE or OUTPUT_FORMAT env vars.")

    # Setup input and output file paths
    print(f"Downloading from: {input_file}")
    filename = input_file.split("/")[-1]
    local_input = f"/tmp/{filename}"
    base_name = filename.rsplit(".", 1)[0]
    local_output = f"/tmp/{base_name}.{output_format}"
    output_key = f"converted/{base_name}.{output_format}"

    # Download input file from S3
    bucket, _ = download_file(input_file, local_input)

    # Virus scan before processing
    #scan_file_for_viruses(local_input)

    # Convert document to PDF
    print("Converting to PDF...")
    convert_docx_to_pdf(local_input, local_output)

    # Upload converted file back to S3
    print(f"Uploading to: s3://{bucket}/{output_key}")
    upload_file(bucket, output_key, local_output)

    # Send notification about completed conversion
    print("Sending SNS notification...")
    sns.publish(
        TopicArn=sns_topic_arn,
        Subject="File Conversion Complete",
        Message=json.dumps({
            "input_file": input_file,
            "output_file": f"s3://{bucket}/{output_key}"
        })
    )

    print("DONE.")

# Execute main function if script is run directly
if __name__ == "__main__":
    main()

