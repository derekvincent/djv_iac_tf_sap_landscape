
# output "efs_mount_ip" {
#     value = data.terraform_remote_state.base.outputs.shared_sap_trans_efs.mount_targets_ips_as_cidr
# }

output "hostname" {
  description = "Hostname of the provisioned SAP system."
  value       = local.fqdn
}

output "ip" {
  description = "IP address of the provisioned SAP system."
  value       = module.sap_abap_dev.instance.private_ip
}

output "instance_id" {
  description = "The Instance ID of the provisioned system."
  value       = module.sap_abap_dev.instance.id
}
