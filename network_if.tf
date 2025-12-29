resource "aws_network_interface" "mongodb_node" {
  count = var.replicas
  security_groups = [aws_security_group.mongo_sg.id]
  subnet_id = var.subnet_id
}

resource "aws_network_interface_attachment" "mongodb_node" {
  count = var.replicas
  instance_id          = aws_instance.mongo_instance[count.index].id
  network_interface_id = aws_network_interface.mongodb_node[count.index].id
  device_index         = 1
}