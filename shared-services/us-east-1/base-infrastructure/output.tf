output "vpc" {
  value = module.vpc
}

output "public_subnets" {
  value = module.public_subnets
}

output "private_subnets" {
  value = module.private_subnets
}

output "public_subnet_id" {
  value = module.public_subnets.subnet_ids
}

output "private_subnet_id" {
  value = module.private_subnets.subnet_ids
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

output "route53_parent_zone" {
  value = module.route53_base_zone
}

output "route53_reverse_zone" {
  value = module.route53_reverse_zone
}
output "route53_zone" {
  value = module.route53_base_zone
}

output "transit_gateway_id" {
  value = module.transit_gateway.id
}

## Shared Service Assumed Role ARN for the above SAP Shared buckets in shared service account.
output "shared_sap_buckets_role_arn" {
  value = data.terraform_remote_state.assumed_roles.outputs.sap_buckets_role_arn
}

output "resolver_forward_rule_ids" {
  value = module.route53_resolver_endpoints.resolver_forward_rule_ids
}

output "route53_inbound_resolver_endpoint_ips" {
  value = module.route53_resolver_endpoints.inbound_resolver_ips
}

output "route53_outbound_resolver_endpoint_ips" {
  value = module.route53_resolver_endpoints.outbound_resolver_ips
}

output "private_zone_policy_arn" {
  value = module.route53_base_zone.private_zone_policy_arn
}

output "private_reverse_zone_policy_arn" {
  value = module.route53_reverse_zone.private_zone_policy_arn
}

## List of Buckets that all SAP environment will need access to. 
output "shared_sap_buckets_arns" {
  value = list(module.sap_software_bucket.bucket_arn,
  module.sap_migration_data_bucket.bucket_arn)
}

output "sap_transport_efs" {
  value = module.sap_transport_efs
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