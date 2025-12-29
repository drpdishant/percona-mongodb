output "interface_ip" {
  description = "IP of the EC2 instance"
  value = { for idx, ni in aws_network_interface.mongodb_node :
    "mongo_node_${idx}" => ni.private_ip
  }
  # value       = for aws_network_interface.mongodb_node.*.private_ip[0]
}

output "data_volume_id" {
  description = "ID of the MongoDB data volume"
  value       = aws_ebs_volume.mongo_data_volume.*.id
}
output "logs_volume_id" {
  description = "ID of the MongoDB data volume"
  value       = aws_ebs_volume.mongo_logs_volume.*.id
}

output "security_group_id" {
  description = "ID of the Security Group for MongoDB"
  value       = aws_security_group.mongo_sg.id
}
