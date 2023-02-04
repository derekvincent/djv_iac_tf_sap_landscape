locals {
  ## Added more roles as needed in the future.
  assumed_shared_roles = list(data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn)

  ansible_inventory_name = join("_", [var.environment, "aws_ec2.yml"])
  fqdn                   = join(".", [var.hostname, data.aws_route53_zone.default.name])

  engress_security_rules = var.security_group_egress_rules

  ## Add the Instance security groups as well and any further ones. 
  ## Keep in only 5 are generally allowed and be default we will have 3 assigned. 
  instance_security_group    = lookup(data.terraform_remote_state.base.outputs.sap_j2ee_security_groups_id_list, var.sap_sysnr)
  ascs_security_group        = lookup(data.terraform_remote_state.base.outputs.sap_j2ee_security_groups_id_list, join("-", [var.sap_ascs_sysnr, "scs"]))
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

module "sap_abap_dev" {
  source                       = "github.com/derekvincent/tf_sap_modules/sap-abap"
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
  swap_volume_size             = var.swap_volume_size
  ebs_disk_layouts             = var.ebs_disk_layouts
  assumed_shared_roles         = local.assumed_shared_roles
  # efs_access_point             = local.efs_access_point
  fqdn = local.fqdn
}

data "aws_route53_zone" "default" {
  provider     = aws.assumed_shared_service
  zone_id      = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  private_zone = true
}

module "sap_abap_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  name      = var.hostname
  type      = "A"
  records   = [module.sap_abap_dev.instance.private_ip]
}

module "sap_abap_reverse_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_reverse_zone_id
  name      = module.sap_abap_dev.instance.private_ip
  type      = "REVERSE"
  records   = [module.sap_abap_dns_name.fqdn]
}

module "sap_ansible_input" {
  source             = "github.com/derekvincent/tf_sap_modules/sap-ansible-abap"
  json_format        = true
  hostname           = var.hostname
  sid                = var.sap_sid
  reboot_after_patch = var.reboot_after_patch
  domainname         = data.aws_route53_zone.default.name
  ip_address         = module.sap_abap_dev.instance.private_ip
  swap_device        = module.sap_abap_dev.swap_device
  volume_groups      = var.volume_groups
  block_devices      = var.block_devices
  saptrans_efs       = null
  region             = var.region
  shared_s3_role_arn = data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn
}

resource "null_resource" "sap-ansible" {
  provisioner "local-exec" {
    working_dir = var.ansible_playbook
    command     = "./ansible-play-ssm-key.sh '${var.ssh_key_parameter}' -i ./inventory/'${local.ansible_inventory_name}' --limit '${local.fqdn}'  --extra-vars '${module.sap_ansible_input.template}' sap-abap-build.yml"
  }
  depends_on = [
    module.sap_abap_dev,
    module.sap_abap_dns_name
  ]
}