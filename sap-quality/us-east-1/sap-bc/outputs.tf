output "ip" {
  description = "IP address of the provisioned SAP system."
  value       = aws_instance.sap_bc.private_ip
}

output "instance_id" {
  description = "The Instance ID of the provisioned system."
  value       = aws_instance.sap_bc.id
}

# output "ansible_yaml" {
#     value = local.anible_vars
# }