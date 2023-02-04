output "ip" {
  description = "IP address of the provisioned SAP system."
  value       = aws_instance.saprouter.private_ip
}

output "eip" {
  description = "Elastic Public IP address of the provisioned SAP system."
  value       = aws_eip.saprouter.public_ip
}

output "instance_id" {
  description = "The Instance ID of the provisioned system."
  value       = aws_instance.saprouter.id
}
