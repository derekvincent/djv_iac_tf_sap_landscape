locals {

  instance_name    = lower(join("-", [var.namespace, var.name, var.environment, var.sap_application, "sapbc"]))
  instance_sg_name = lower(join("-", [var.namespace, var.name, var.environment, var.sap_application, "sapbc", "sg"]))

  ## 

  ## TAGS
  tag_name_env         = join(":", [var.namespace, "environment"])
  tag_name_customer    = join(":", [var.namespace, "customer"])
  tag_name_application = join(":", [var.namespace, "application"])
  tag_name_hostname    = join(":", [var.namespace, "hostname"])
  ## SAP Specifics
  # tag_name_sap_type          = join(":", [var.namespace, "sap", "type"])
  tag_name_sap_app           = join(":", [var.namespace, "sap", "application"])
  tag_name_sap_version       = join(":", [var.namespace, "sap", "application", "version"])
  tag_name_sap_instance_type = join(":", [var.namespace, "sap", "instance_type"])

  common_tags = map(
    local.tag_name_env, var.environment,
    local.tag_name_customer, var.customer,
    local.tag_name_application, var.name,
  )
  sap_tags = map(
    # local.tag_name_sap_type, var.sap_type,
    local.tag_name_sap_app, var.sap_application,
    local.tag_name_sap_version, var.sap_application_version,
    local.tag_name_sap_instance_type, var.sap_instance_type,
  )
  ansible_inventory_name = join("_", [var.environment, "aws_ec2.yml"])
  fqdn                   = join(".", [var.hostname, data.aws_route53_zone.default.name])
  assumed_shared_roles   = list(data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn)
  security_groups        = concat(list(aws_security_group.default.id), var.additional_security_group_arns)

  ansible_vars = jsonencode({
    "sap_software_bucket" : "sapm-shared-service-prod-us-east-1-sap-software",
    "sap_software_bucket_path" : "sapbc48/",
    "hostname" : var.hostname,
    "domainname" : data.aws_route53_zone.default.name,
    "region" : var.region,
    "shared_s3_role_arn" : data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn
    "reboot_after_patch" : var.reboot_after_patch
    "sapbc_license" : var.sapbc_license
    "mounts" : var.mounts
  })
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.base_infra_state_bucket
    key    = var.base_infra_state_key
  }
}

resource "aws_instance" "sap_bc" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.sap_bc.name
  key_name                    = var.key_name
  subnet_id                   = data.terraform_remote_state.base.outputs.private_subnet_primary_id
  vpc_security_group_ids      = local.security_groups
  monitoring                  = var.enable_enhanced_monitoring
  associate_public_ip_address = var.enable_public_address
  private_ip                  = var.ec2_private_ip
  disable_api_termination     = var.termination_protection
  ebs_optimized               = var.ebs_optimized

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted
  }

  tags = merge(
    local.common_tags,
    local.sap_tags,
    map(
      "Name", local.instance_name,
      local.tag_name_hostname, local.fqdn,
    )
  )
}

data "aws_route53_zone" "default" {
  provider     = aws.assumed_shared_service
  zone_id      = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  private_zone = true
}

module "sap_bc_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  name      = var.hostname
  type      = "A"
  records   = [aws_instance.sap_bc.private_ip]
}

module "sap_bc_reverse_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_reverse_zone_id
  name      = aws_instance.sap_bc.private_ip
  type      = "REVERSE"
  records   = [module.sap_bc_dns_name.fqdn]
}

resource "null_resource" "sap-ansible" {
  provisioner "local-exec" {
    working_dir = var.ansible_playbook
    command     = "./ansible-play-ssm-key.sh '${var.ssh_key_parameter}' -i ./inventory/'${local.ansible_inventory_name}' --limit '${local.fqdn}'  --extra-vars '${local.ansible_vars}' sap-bc-playbook.yml"
  }
  depends_on = [
    aws_instance.sap_bc,
    module.sap_bc_dns_name
  ]
}