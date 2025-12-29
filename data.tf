data "aws_subnet" "selected" {
  id = var.subnet_id
}


data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

data "aws_network_interface" "mongo_node" {
  count = var.replicas
  id = aws_instance.mongo_instance[count.index].primary_network_interface_id
}


resource "random_password" "password" {
  length           = 16
  special          = true
}


data "cloudinit_config" "mongo_installation" {
  gzip          = false
  base64_encode = false
  
  part {
    filename     = "00-volume_mount.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/volume_mount.sh")
  }

  part {
    filename     = "01-cloud-config.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/cloud-config.tpl", 
      {
        mongoadmin_password = random_password.password.bcrypt_hash
      } 
    )
  }
  part {
    filename     = "02-awscli_install.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/awscli_install.sh")
  }

  part {
    filename     = "03-mongosh_install.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/mongosh_install.sh")
  }

  part {
    filename     = "04-mongo_install.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/scripts/mongo_install.sh")
  }

}