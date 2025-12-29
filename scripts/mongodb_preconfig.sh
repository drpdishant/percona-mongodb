#!/bin/bash
sudo yum update -y
sudo yum install -y jq curl wget tar openssl-devel curl-devel libpcap

MONGO_NODE_1=$(aws ssm get-parameter --name "/acqui/mongodb/node/0/ip" --region "ap-south-2" --query "Parameter.Value" --output text)
MONGO_NODE_2=$(aws ssm get-parameter --name "/acqui/mongodb/node/1/ip" --region "ap-south-2" --query "Parameter.Value" --output text)
MONGO_NODE_3=$(aws ssm get-parameter --name "/acqui/mongodb/node/2/ip" --region "ap-south-2" --query "Parameter.Value" --output text)

echo "export MONGO_NODE_1=${MONGO_NODE_1}" | sudo tee -a /etc/environment
echo "export MONGO_NODE_2=${MONGO_NODE_2}" | sudo tee -a /etc/environment
echo "export MONGO_NODE_3=${MONGO_NODE_3}" | sudo tee -a /etc/environment

echo "$MONGO_NODE_1 mongo-node-1 mongodb-dr-01.kotak811.int" >> /etc/hosts
echo "$MONGO_NODE_2 mongo-node-2 mongodb-dr-02.kotak811.int" >> /etc/hosts
echo "$MONGO_NODE_3 mongo-node-3 mongodb-dr-03.kotak811.int" >> /etc/hosts


