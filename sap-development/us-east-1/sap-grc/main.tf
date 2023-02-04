locals {
  ## Added more roles as needed in the future.
  assumed_shared_roles = list(data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn)

  sap_transport_efs = length(data.terraform_remote_state.base.outputs.shared_sap_trans_efs.mount_targets_ips_as_cidr) > 0 ? [
    {
      from_port : 2049,
      to_port : 2049,
      protocol : "tcp",
      cidr_blocks : data.terraform_remote_state.base.outputs.shared_sap_trans_efs.mount_targets_ips_as_cidr
      prefix_ids : [],
      security_groups : [],
      description : "NFS to SAP transport EFS"
    }
  ] : []

  engress_security_rules = concat(var.security_group_egress_rules, local.sap_transport_efs)

  ## Assign the Access Point EFS 
  efs_access_point = map(var.efs_name, lookup(data.terraform_remote_state.base.outputs.shared_sap_trans_efs.access_points, var.efs_name, null))

  ## Add the Instance security groups as well and any further ones. 
  ## Keep in only 5 are generally allowed and be default we will have 3 assigned. 
  instance_security_group    = lookup(data.terraform_remote_state.base.outputs.sap_security_groups_id_list, var.sap_sysnr)
  ascs_security_group        = lookup(data.terraform_remote_state.base.outputs.sap_security_groups_id_list, join("-", [var.sap_ascs_sysnr, "scs"]))
  additional_security_groups = concat(list(local.instance_security_group, local.ascs_security_group), var.additional_security_group_arns)
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.base_infra_state_bucket
    key    = var.base_infra_state_key
  }
}

module "sap_grc_abap_dev" {
  source                       = "github.com/derekvincent/tf_sap_modules?ref=v0.0.1/sap-abap"
  region                       = var.region
  namespace                    = var.namespace
  environment                  = var.environment
  name                         = var.name
  customer                     = var.customer
  sap_application              = var.sap_application
  sap_application_version      = var.sap_application_version
  sap_netweaver_version        = var.sap_netweaver_version
  sap_instance_type            = var.sap_instance_type
  vpc_id                       = data.terraform_remote_state.base.outputs.vpc.vpc_id
  key_name                     = var.key_name
  security_group_egress_rules  = local.engress_security_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  additional_security_groups   = local.additional_security_groups
  hostname                     = var.hostname
  sap_sid                      = var.sap_sid
  sap_sysnr                    = var.sap_sysnr
  ec2_ami                      = var.ec2_ami
  ec2_instance_type            = var.ec2_instance_type
  subnet_id                    = data.terraform_remote_state.base.outputs.private_subnet_primary_id
  ebs_optimized                = var.ebs_optimized
  swap_volume_size             = var.swap_volume_size
  ebs_disk_layouts             = var.ebs_disk_layouts
  assumed_shared_roles         = local.assumed_shared_roles
  efs_access_point             = local.efs_access_point
}

module "sap_grc_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  name      = var.hostname
  type      = "A"
  records   = [module.sap_grc_abap_dev.instance.private_ip]
}

module "sap_grc_reverse_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_reverse_zone_id
  name      = module.sap_grc_abap_dev.instance.private_ip
  type      = "REVERSE"
  records   = [module.sap_grc_dns_name.fqdn]
}
