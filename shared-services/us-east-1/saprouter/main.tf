locals {

  instance_name    = lower(join("-", [var.namespace, var.name, var.environment, var.sap_application]))
  instance_eip     = lower(join("-", [local.instance_name, "eip"]))
  instance_sg_name = lower(join("-", [local.instance_name, "sg"]))

  ## 

  ## TAGS
  tag_name_env         = join(":", [var.namespace, "environment"])
  tag_name_customer    = join(":", [var.namespace, "customer"])
  tag_name_application = join(":", [var.namespace, "application"])
  tag_name_hostname    = join(":", [var.namespace, "hostname"])
  ## SAP Specifics
  tag_name_sap_app           = join(":", [var.namespace, "sap", "application"])
  tag_name_sap_instance_type = join(":", [var.namespace, "sap", "instance_type"])

  common_tags = tomap({
    (local.tag_name_env)         = var.environment,
    (local.tag_name_customer)    = var.customer,
    (local.tag_name_application) = var.name,
  })

  sap_tags = tomap({
    (local.tag_name_sap_app)           = var.sap_application,
    (local.tag_name_sap_instance_type) = var.sap_instance_type,
  })

  fqdn                 = join(".", [var.hostname, data.aws_route53_zone.default.name])
  assumed_shared_roles = tolist([data.terraform_remote_state.base.outputs.shared_sap_buckets_role_arn])
  security_groups      = concat(tolist([aws_security_group.default.id]), var.additional_security_group_arns)

  user_data_info = {
    saprout_dir     = var.saprout_dir,
    download_bucket = var.s3_download_bucket
    download_prefix = var.s3_download_prefix
    script          = file("${path.module}/templates/saprouter_setup.sh")
  }
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.base_infra_state_bucket
    key    = var.base_infra_state_key
  }
}

resource "aws_instance" "saprouter" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.saprouter.name
  key_name                    = var.key_name
  subnet_id                   = data.terraform_remote_state.base.outputs.public_subnet_primary_id
  vpc_security_group_ids      = local.security_groups
  monitoring                  = var.enable_enhanced_monitoring
  associate_public_ip_address = var.enable_public_address
  private_ip                  = var.ec2_private_ip
  disable_api_termination     = var.termination_protection
  ebs_optimized               = var.ebs_optimized
  hibernation                 = false
  user_data                   = templatefile("${path.module}/templates/saprouter_setup.tpl", local.user_data_info)

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_volume_encrypted

    tags = merge(
      local.common_tags,
      local.sap_tags,
      tomap({
        "Name"                    = local.instance_name,
        (local.tag_name_hostname) = local.fqdn,
      })
    )
  }

  tags = merge(
    local.common_tags,
    local.sap_tags,
    tomap({
      "Name"                    = local.instance_name,
      (local.tag_name_hostname) = local.fqdn,
    })
  )

  lifecycle {
    ignore_changes = [
      ## Changed the user data after the inital deploy and it will now trigger a replacement. So ignoring. 
      user_data
    ]

  }
}

resource "aws_eip" "saprouter" {
  instance = aws_instance.saprouter.id
  vpc      = true
  tags = merge(
    local.common_tags,
    local.sap_tags,
    tomap({
      "Name"                    = local.instance_eip,
      (local.tag_name_hostname) = local.fqdn,
    })
  )
}

data "aws_route53_zone" "default" {
  # provider     = aws.assumed_shared_service
  zone_id      = data.terraform_remote_state.base.outputs.route53_zone.zone_id
  private_zone = true
}

module "saprouter_dns_name" {
  source = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  # providers = { aws : aws.assumed_shared_service }
  zone_id = data.terraform_remote_state.base.outputs.route53_zone.zone_id
  name    = var.hostname
  type    = "A"
  records = [aws_instance.saprouter.private_ip]
}

module "saprouter_reverse_dns_name" {
  source = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  # providers = { aws : aws.assumed_shared_service }
  zone_id = data.terraform_remote_state.base.outputs.route53_reverse_zone.zone_id
  name    = aws_instance.saprouter.private_ip
  type    = "REVERSE"
  records = [module.saprouter_dns_name.fqdn]
}
