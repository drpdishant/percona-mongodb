variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "uat-mongo"
}

variable "subnet_id" {
  description = "ID of the subnet where the instance will be launched"
  default = ""
}

variable "volume_size" {
  default = 128 
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
  default = "uat-mongo"
}

variable "environment" {
  default = "uat"
}
