output "instance_id" {
  description = "ID of EC2"
  value = aws_instance.app_server.id
}
output "instance_public_ip" {
  description = "Ip address"
  value = aws_instance.app_server.public_ip
}
