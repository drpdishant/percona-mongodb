#!/bin/bash

set -e

# Variables (replace <your-bucket-name> and <your-region>)
S3_BUCKET="$s3_bucket_name"
S3_REGION="$s3_region"

echo "Starting PBM setup on RHEL..."

# Install dependencies
echo "Installing dependencies..."
sudo yum update -y
sudo yum install -y gnupg wget curl

# Add Percona repositories
echo "Adding Percona repository..."
sudo yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo percona-release enable pbm release

# Install PBM CLI and Agent
echo "Installing PBM CLI and agent..."
sudo yum install -y percona-backup-mongodb

# Configure PBM for S3 storage using instance role
echo "Configuring PBM..."
pbm config --set storage.type=s3
pbm config --set storage.s3.bucket="$$S3_BUCKET"
pbm config --set storage.s3.region="$$S3_REGION"

# Verify PBM configuration
echo "Verifying PBM configuration..."
pbm config

# Start and enable the PBM agent
echo "Starting and enabling PBM agent..."
sudo systemctl start pbm-agent
sudo systemctl enable pbm-agent

echo "PBM setup completed successfully!"
