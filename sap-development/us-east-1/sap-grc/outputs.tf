
output "efs_mount_ip" {
  value = data.terraform_remote_state.base.outputs.shared_sap_trans_efs.mount_targets_ips_as_cidr
}