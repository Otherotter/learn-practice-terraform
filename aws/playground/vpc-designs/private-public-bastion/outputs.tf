output "ssh_private_bastion" {
  description = "The command used to ssh into the private bastion."
  value       = "ssh -J ubuntu@${aws_instance.playground-bastion.public_ip} ubuntu@${aws_instance.playground-private-bastion.private_ip}"

}


output "ssh_private_subservents" {
  description = "The commands used to ssh into the private subservent machine from private bastion"
  value       = [aws_instance.playground-subservents.*.private_ip]
}


# output "ssh_private_subservents" {
#description = "The commands used to ssh into the private subservent machine from private bastion"
#value       = ["ssh -i private_bastion_rsa ubuntu@${aws_instance.playground-subservents.*.private_ip}"]
# }
