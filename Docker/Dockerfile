# Use Python 3.10 slim base image
FROM python:3.10-slim

# Install DejaVu fonts
RUN apt-get update && \
    apt-get install -y \
        fonts-dejavu-core \
        && rm -rf /var/lib/apt/lists/*

# Install required Python packages
RUN pip install --no-cache-dir boto3 fpdf python-docx

# Set working directory
WORKDIR /app

# Copy processor script
COPY processor.py .

# Default command
CMD ["python", "processor.py"]
