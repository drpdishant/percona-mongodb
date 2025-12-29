provider "aws" {
  region = var.aws_region
}
                                              
resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "root_ca_cert" {
  private_key_pem = tls_private_key.root_ca.private_key_pem

  subject {
    common_name  = "MongoDB DR Root CA"
    organization = "Kotak Mahindra Bank Pvt. LTD"
  }
  validity_period_hours = 87600  # 10 years
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}


# Create MongoData Volume (1TB)
resource "aws_ebs_volume" "mongo_data_volume" {
  count = var.replicas
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 1024  # 1TB
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "MongoData-Volume-${count.index}"
  }
}

# Create MongoLogs Volume (500GB)
resource "aws_ebs_volume" "mongo_logs_volume" {
  count = var.replicas
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 500  # 500GB
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "MongoLogs-Volume-${count.index}"
  }
}

# Attach MongoData Volume
resource "aws_volume_attachment" "mongo_data_attachment" {
  count = var.replicas
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mongo_data_volume[count.index].id
  instance_id = aws_instance.mongo_instance[count.index].id
}

# Attach MongoLogs Volume
resource "aws_volume_attachment" "mongo_logs_attachment" {
  count = var.replicas
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.mongo_logs_volume[count.index].id
  instance_id = aws_instance.mongo_instance[count.index].id
}


resource "aws_security_group" "mongo_sg" {
  name        = "mongo-security-group"
  description = "Allow MongoDB access within VPC"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description      = "Allow MongoDB traffic within VPC"
    from_port        = 27072
    to_port          = 27072
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.selected.cidr_block]
  }

  ingress {
    from_port   = 137
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.50.3.219/32"]
    description = "RITM0122497 - Arcos DR gateway"
  }

  ingress {
    from_port   = 137
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.50.4.180/32"]
    description = "RITM0122497 - Arcos DR gateway"
  }

  ingress {
    from_port   = 137
    to_port     = 139
    protocol    = "tcp"
    cidr_blocks = ["10.240.86.48/28"]
    description = "REQ000008209334"
  }

  ingress {
    from_port   = 5667
    to_port     = 5667
    protocol    = "tcp"
    cidr_blocks = ["10.51.87.0/24"]
    description = "REQ000009746652"
  }

  ingress {
    from_port   = 5667
    to_port     = 5667
    protocol    = "tcp"
    cidr_blocks = ["10.51.88.0/24"]
    description = "REQ000009746652"
  }

  ingress {
    from_port   = 1521
    to_port     = 1540
    protocol    = "tcp"
    cidr_blocks = ["10.10.20.71/32"]
    description = "REQ000008209334"
  }

  ingress {
    from_port   = 1521
    to_port     = 1540
    protocol    = "tcp"
    cidr_blocks = ["10.10.20.72/32"]
    description = "REQ000008209334"
  }

  ingress {
    from_port   = 1521
    to_port     = 1540
    protocol    = "tcp"
    cidr_blocks = ["10.50.3.220/32"]
    description = "RITM0122497 -Arcos DR gateway"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.47.230/32"]
    description = "REQ000010676752"
  }

  ingress {
    from_port   = 45045
    to_port     = 45045
    protocol    = "tcp"
    cidr_blocks = ["10.10.20.71/32"]
    description = "REQ000008209334"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.10.20.71/32"]
    description = "REQ000008209334"
  }

  # Allow all outbound traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MongoDB-Security-Group"
  }
}


resource "aws_ssm_parameter" "mongo_node_ip" {
  count = var.replicas
  name  = "/acqui/mongodb/node/${count.index}/ip"
  type  = "String"
  value =  aws_network_interface.mongodb_node[count.index].private_ip
}
resource "aws_ssm_parameter" "mongo_node_dns" {
  count = var.replicas
  name  = "/acqui/mongodb/node/${count.index}/dns"
  type  = "String"
  value =  aws_network_interface.mongodb_node[count.index].private_dns_name
}



resource "aws_instance" "mongo_instance" {
  count = var.replicas
  ami           = var.ami_id 
  instance_type = var.instance_type

  key_name  = var.key_name  
  # iam_instance_profile   = "AWS-EC2-Role"
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  subnet_id = var.subnet_id

  root_block_device {
    volume_size = 20 
  }
  security_groups = [aws_security_group.mongo_sg.id]

  user_data = data.cloudinit_config.mongo_installation.rendered
  
  tags = {
    Name = "MongoDB-Instance-${count.index}"
  }
  lifecycle {    
    create_before_destroy = true
    ignore_changes = [security_groups]
  }
}
