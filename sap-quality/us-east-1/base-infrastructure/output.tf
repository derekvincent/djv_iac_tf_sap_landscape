output "vpc" {
  value = module.vpc
}

output "public_subnets" {
  value = module.public_subnets
}

output "private_subnets" {
  value = module.private_subnets
}

output "private_subnet_primary_id" {
  value = module.private_subnets.subnet_ids[0]
}

output "private_subnet_secondary_id" {
  value = module.private_subnets.subnet_ids[1]
}

output "public_subnet_primary_id" {
  value = module.public_subnets.subnet_ids[0]
}

output "public_subnet_secondary_id" {
  value = module.public_subnets.subnet_ids[1]
}

# output "route53_zone" {
#     value = module.route53_zone
# }
output "vpc_domain_zone_id" {
  value = data.terraform_remote_state.base.outputs.route53_zone.zone_id
}

output "vpc_domain_reverse_zone_id" {
  value = data.terraform_remote_state.base.outputs.route53_reverse_zone.zone_id
}
## List of Buckets that all SAP environment will need access to. 
output "shared_sap_buckets_arns" {
  value = data.terraform_remote_state.base.outputs.shared_sap_buckets_arns
}

## Shared Service Assumed Role ARN for the above SAP Shared buckets in shared service account.
output "shared_sap_buckets_role_arn" {
  value = data.terraform_remote_state.assumed_roles.outputs.sap_buckets_role_arn
}

output "shared_sap_trans_efs" {
  description = "The SAP transport elastic files systems in the shared services account."
  value       = data.terraform_remote_state.base.outputs.sap_transport_efs
}

output "sap_security_groups_arn_list" {
  description = "A list of maps that contain the key as the system number or system number-scs and value is the role ARN."
  value = { for value in module.sap_abap_security_groups :
    value.sysnr_security_group_map.sysnr => value.sysnr_security_group_map.arn
  }
}

output "sap_security_groups_id_list" {
  description = "A list of maps that contain the key as the system number or system number-scs and value is the role ID."
  value = { for value in module.sap_abap_security_groups :
    value.sysnr_security_group_map.sysnr => value.sysnr_security_group_map.id
  }
}

output "sap_j2ee_security_groups_arn_list" {
  description = "A list of maps that contain the key as the system number or system number-scs and value is the role ARN."
  value = { for value in module.sap_java_security_groups :
    value.sysnr_security_group_map.sysnr => value.sysnr_security_group_map.arn
  }
}

output "sap_j2ee_security_groups_id_list" {
  description = "A list of maps that contain the key as the system number or system number-scs and value is the role ID."
  value = { for value in module.sap_java_security_groups :
    value.sysnr_security_group_map.sysnr => value.sysnr_security_group_map.id
  }
}