output "ip" {
  description = "IP address of the provisioned SAP system."
  value       = aws_instance.sftp.private_ip
}

output "instance_id" {
  description = "The Instance ID of the provisioned system."
  value       = aws_instance.sftp.id
}

#output "user_data_template" {
#  value = local.template
#}
# output "ansible_yaml" {
#     value = local.anible_vars
# }