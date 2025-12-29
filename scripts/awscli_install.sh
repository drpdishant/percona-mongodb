#!/bin/bash
yum update -y

yum install -y unzip curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -o /tmp/awscliv2.zip -d /tmp
sudo  /tmp/aws/install 
export PATH="/usr/local/aws-cli/v2/current/bin:$PATH" 
echo "export PATH=/usr/local/aws-cli/v2/current/bin:$PATH" | sudo tee -a /etc/environment
echo "AWS setup successful"
