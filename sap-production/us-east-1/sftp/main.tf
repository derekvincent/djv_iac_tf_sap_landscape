locals {

  instance_name    = lower(join("-", [var.namespace, var.name, var.environment, "sftp"]))
  instance_sg_name = lower(join("-", [var.namespace, var.name, var.environment, "sftp", "sg"]))

  ## 

  ## TAGS
  tag_name_env         = join(":", [var.namespace, "environment"])
  tag_name_customer    = join(":", [var.namespace, "customer"])
  tag_name_application = join(":", [var.namespace, "application"])
  tag_name_hostname    = join(":", [var.namespace, "hostname"])
  ## SAP Specifics

  common_tags = map(
    local.tag_name_env, var.environment,
    local.tag_name_customer, var.customer,
    local.tag_name_application, var.name,
  )

  fqdn                 = join(".", [var.hostname, data.aws_route53_zone.default.name])
  assumed_shared_roles = list(data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn)
  security_groups      = concat(list(aws_security_group.default.id), var.additional_security_group_arns)

  user_data_info = {
    instance_profile = aws_iam_instance_profile.sftp.name,
    sftp_shares      = var.sftp_shares
  }

  template = templatefile("${path.module}/templates/sftp_setup.tpl", local.user_data_info)
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.base_infra_state_bucket
    key    = var.base_infra_state_key
  }
}


resource "aws_instance" "sftp" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.sftp.name
  key_name                    = var.key_name
  subnet_id                   = data.terraform_remote_state.base.outputs.public_subnet_primary_id
  vpc_security_group_ids      = local.security_groups
  monitoring                  = var.enable_enhanced_monitoring
  associate_public_ip_address = var.enable_public_address
  private_ip                  = var.ec2_private_ip
  disable_api_termination     = var.termination_protection
  ebs_optimized               = var.ebs_optimized
  user_data                   = templatefile("${path.module}/templates/sftp_setup.tpl", local.user_data_info)

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", local.instance_name,
      local.tag_name_hostname, local.fqdn,
    )
  )
}

resource "aws_eip" "sftp" {
  instance = aws_instance.sftp.id
  vpc      = true
}

data "aws_route53_zone" "default" {
  provider     = aws.assumed_shared_service
  zone_id      = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  private_zone = true
}

module "sftp_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  name      = var.hostname
  type      = "A"
  records   = [aws_instance.sftp.private_ip]
}

module "sftp_reverse_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_reverse_zone_id
  name      = aws_instance.sftp.private_ip
  type      = "REVERSE"
  records   = [module.sftp_dns_name.fqdn]
}

#resource "null_resource" "sap-ansible" {
#  provisioner "local-exec" {
#    working_dir = var.ansible_playbook
#    command     = "./ansible-play-ssm-key.sh '${var.ssh_key_parameter}' -i ./inventory/'${local.ansible_inventory_name}' --limit '${local.fqdn}'  --extra-vars '${local.ansible_vars}' sap-bc-playbook.yml"
#  }
#  depends_on = [
#    aws_instance.sap_bc,
#    module.sap_bc_dns_name
#  ]
#}