output "instance_ip_addr" {
  value = "ssh -J ubuntu@${aws_instance.playground-bastion.public_ip} ubuntu@${aws_instance.playground-private-bastion.private_ip}"

}

output "ecr_repository_urls" {
  value = [aws_instance.playground-subservents.*.private_ip]
}
