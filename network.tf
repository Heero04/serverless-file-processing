# ----------------------
# network.tf
# Workspace-aware VPC, Subnet, and SG for ECS Fargate
# This file defines the networking infrastructure for the SwiftSend application
# including VPC, subnet, internet gateway, route table and security group
# The resources are workspace-aware to support multiple environments
# ----------------------

# Create VPC with DNS support enabled
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "swiftsend-vpc-${terraform.workspace}"
  }
}

# Create public subnet in us-east-1a
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Adjust as needed

  tags = {
    Name = "swiftsend-subnet-public-${terraform.workspace}"
  }
}

# Create internet gateway for public subnet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "swiftsend-igw-${terraform.workspace}"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "swiftsend-rt-${terraform.workspace}"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Create security group for ECS tasks
resource "aws_security_group" "allow_outbound" {
  name        = "swiftsend-ecs-sg-${terraform.workspace}"
  description = "Allow all outbound traffic (safe for Fargate)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic (only for dev/test)"
  }

  tags = {
    Name = "swiftsend-ecs-sg-${terraform.workspace}"
  }
}
