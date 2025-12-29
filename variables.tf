variable "aws_region" {
  default = "ap-south-2"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "k811-devops-uat-dr"
}

variable "subnet_id" {
  description = "ID of the subnet where the instance will be launched"
  default = "subnet-00910459ee773610f"
}

variable "volume_size" {
  default = 1024  # 1TB volume size
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-0be405aa2a30e60db"  # Replace with a valid RHEL AMI ID in your region
}

variable "replicas" {
  description = "Replicas"
  default = "3"
}

variable "bucket_name" {
  default = "acqui-dr-mongo-backup"
}

variable "environment" {
  default = "uat-dr"
}
