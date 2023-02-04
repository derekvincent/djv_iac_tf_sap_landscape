locals {
  ## Added more roles as needed in the future.
  assumed_shared_roles = list(data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn)

  ansible_inventory_name = join("_", [var.environment, "aws_ec2.yml"])
  fqdn                   = join(".", [var.hostname, data.aws_route53_zone.default.name])
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

  ## EFS Mount Targets by AZ 
  mount_targets = { for target in data.terraform_remote_state.base.outputs.shared_sap_trans_efs.mount_targets :
    target.availability_zone_id => {
      filesystem_id : target.file_system_id,
      filesystem_host : target.dns_name,
      filesystem_ip : target.ip_address,
      tls : true,
      iam : true,
      access_point : lookup(data.terraform_remote_state.base.outputs.shared_sap_trans_efs.access_points, var.efs_name, null).id
    }
  }

  ## Add the Instance security groups as well and any further ones. 
  ## Keep in only 5 are generally allowed and be default we will have 3 assigned. 
  instance_security_group    = lookup(data.terraform_remote_state.base.outputs.sap_j2ee_security_groups_id_list, var.sap_sysnr)
  ascs_security_group        = lookup(data.terraform_remote_state.base.outputs.sap_j2ee_security_groups_id_list, join("-", [var.sap_ascs_sysnr, "scs"]))
  additional_security_groups = concat(list(local.instance_security_group, local.ascs_security_group), var.additional_security_group_arns)

  instance_lb_egress_map = {
    lower(join("_", [var.target_protocol, var.target_port])) : {
      from_port : var.target_port,
      to_port : var.target_port,
      protocol : "tcp",
      cidr_blocks : tolist([join("/", [module.sap_abap_dev.instance.private_ip, "32"])], ),
      description : join("_", [var.target_protocol, var.target_port])
    },
  }

  lb_egress_map = merge(local.instance_lb_egress_map, var.lb_egress_map)
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
  efs_access_point             = local.efs_access_point
  fqdn                         = local.fqdn
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
  saptrans_efs       = local.mount_targets
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

## Create the Application Load Balancer 
module "po_alb" {
  #source = "github.com/derekvincent/tf_sap_modules?ref=v0.0.1/sap-abap"
  source                   = "../../../../modules/networking/sap-po-alb"
  description              = "PO Application load balancer"
  region                   = var.region
  namespace                = var.namespace
  environment              = var.environment
  name                     = var.name
  customer                 = var.customer
  vpc_id                   = data.terraform_remote_state.base.outputs.vpc.vpc_id
  subnet_ids               = data.terraform_remote_state.base.outputs.public_subnets.subnet_ids
  lb_name                  = var.lb_name
  healthcheck_path         = var.lb_healthcheck_path
  lb_ingress_map           = var.lb_ingress_map
  lb_egress_map            = local.lb_egress_map
  access_logs_bucket       = var.access_logs_bucket
  access_logs_prefix       = var.access_logs_prefix
  access_logs_enabled      = var.access_logs_enabled
  target_port              = var.target_port
  target_protocol          = var.target_protocol
  target_instance          = module.sap_abap_dev.instance.id
  forward_rules            = var.lb_forward_rules
  enable_http              = var.lb_enable_http
  enable_https             = var.lb_enable_https
  listener_certificate_arn = var.listener_certificate_arn
}