output "ip" {
  description = "IP address of the provisioned SAP system."
  value       = aws_instance.sftp.private_ip
}

output "instance_id" {
  description = "The Instance ID of the provisioned system."
  value       = aws_instance.sftp.id
}

