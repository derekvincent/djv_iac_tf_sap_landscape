
locals {


  #instances        = toset(formatlist("%d", range(var.instance_count)))
  instances = { for instance in range(var.instance_count) :
    format("%s%d", var.hostname, instance + 1) => instance
  }

  instance_name    = lower(join("-", [var.namespace, var.name, var.environment, var.instance_name]))
  instance_sg_name = lower(join("-", [local.instance_name, "sg"]))

  ## TAGS
  tag_name_env         = join(":", [var.namespace, "environment"])
  tag_name_customer    = join(":", [var.namespace, "customer"])
  tag_name_application = join(":", [var.namespace, "application"])

  common_tags = map(
    local.tag_name_env, var.environment,
    local.tag_name_customer, var.customer,
    local.tag_name_application, var.name,
  )

  security_groups = concat(list(aws_security_group.default.id), var.additional_security_groups)

  ##
  ## Allow communication between system in the grid based on security group 
  ##
  egress_rules = [
    {
      from_port : 8400,
      to_port : 8403,
      protocol : "tcp",
      #  cidr_blocks     : [],
      #  prefix_ids      : [],
      security_group : aws_security_group.default.id,
      description : "Commvault Media Server Grid Communications"
    }
  ]

  ingress_rules = [
    {
      from_port : 8400,
      to_port : 8403,
      protocol : "tcp",
      #  cidr_blocks     : [],
      #  prefix_ids      : [],
      security_group : aws_security_group.default.id,
      description : "Commvault Media Server Grid Communications"
    },
  ]

  security_group_egress_rules  = concat(var.security_group_egress_rules, local.egress_rules)
  security_group_ingress_rules = concat(var.security_group_ingress_rules, local.ingress_rules)

  ami = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.commvault_media_agent.id
}

data "aws_ami" "commvault_media_agent" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["Commvault Linux Cloud Data Manager*c3fdde77-53ca-46ca-9ae7-20256d9e9899*"]
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

##
## Security Group 
##

resource "aws_security_group" "default" {
  name        = local.instance_sg_name
  description = "Commvault Media Agent Grid"
  vpc_id      = data.terraform_remote_state.base.outputs.vpc.vpc_id

  tags = merge(
    local.common_tags,
    map(
      "Name", local.instance_sg_name
    )
  )
}

##
## Egress/Ingress Security Group rules 
##
## The inbound rules should be formatted as follows:
##    [{ 
##         from_port       :  3200,
##         to_port         : 3200,
##         protocol        :  "tcp",
##         cidr_blocks     : ["192.168.111.0/24", "192.168.99.0/24"],
##         prefix_ids      : ["pl-086fbfc43e011e47c"],
##         security_group  : "",
##         description     : "SAP RFC from AWS and VPN subnets."
##     }]
##
## Cidrs, Prefix Lists, and [Security groups: issue] can be mixed and matched. 
## If not using one then an empty list needs to be passed in. 
##

resource "aws_security_group_rule" "egress" {
  count                    = length(local.security_group_egress_rules)
  type                     = "egress"
  from_port                = lookup(local.security_group_egress_rules[count.index], "from_port")
  to_port                  = lookup(local.security_group_egress_rules[count.index], "to_port")
  protocol                 = lookup(local.security_group_egress_rules[count.index], "protocol")
  cidr_blocks              = lookup(local.security_group_egress_rules[count.index], "cidr_blocks", null)
  prefix_list_ids          = lookup(local.security_group_egress_rules[count.index], "prefix_ids", null)
  source_security_group_id = lookup(local.security_group_egress_rules[count.index], "security_group", null)
  description              = lookup(local.security_group_egress_rules[count.index], "description", "")
  security_group_id        = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress" {
  count                    = length(local.security_group_ingress_rules)
  type                     = "ingress"
  from_port                = lookup(local.security_group_ingress_rules[count.index], "from_port")
  to_port                  = lookup(local.security_group_ingress_rules[count.index], "to_port")
  protocol                 = lookup(local.security_group_ingress_rules[count.index], "protocol")
  cidr_blocks              = lookup(local.security_group_ingress_rules[count.index], "cidr_blocks", null)
  prefix_list_ids          = lookup(local.security_group_ingress_rules[count.index], "prefix_ids", null)
  source_security_group_id = lookup(local.security_group_ingress_rules[count.index], "security_group", null)
  description              = lookup(local.security_group_ingress_rules[count.index], "description", "")
  security_group_id        = aws_security_group.default.id
}



## 
## EC2 Instance
##

module "commvault_media_agents" {
  source               = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/commvault-media-agent"
  for_each             = local.instances
  instance_name        = join("-", [var.instance_name, each.value])
  region               = var.region
  namespace            = var.namespace
  environment          = var.environment
  name                 = var.name
  customer             = var.customer
  hostname             = each.key
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.default.name
  security_groups      = local.security_groups
  ec2_ami              = local.ami
  ec2_instance_type    = var.ec2_instance_type
  subnet_id            = element(data.terraform_remote_state.base.outputs.private_subnet_id, each.value)
  ebs_optimized        = var.ebs_optimized
  root_volume_size     = var.root_volume_size
  swap_volume_size     = var.swap_volume_size
  ebs_disk_layouts     = var.ebs_disk_layouts

}

##
## Create EC2 Instance roles, attach standard policies and profiles. 
##

## Create a Role for the EC2 instance
resource "aws_iam_role" "default" {
  name = join("-", [local.instance_name, "role"])

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })

  tags = merge(
    local.common_tags,
    map(
      "Name", join("-", [local.instance_name, "role"])
    )
  )
}

# Assign the SSM policy to the role
resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## Assign the CloudWatch policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

## Assign the CloudWatch policy to the role
resource "aws_iam_role_policy_attachment" "s3-library" {
  count      = local.enabled_buckets
  role       = aws_iam_role.default.name
  policy_arn = join("", aws_iam_policy.s3-bucket-policy.*.arn)
}

## Create an Instance Profile for the Role
resource "aws_iam_instance_profile" "default" {
  name = join("-", [local.instance_name, "role"])
  role = aws_iam_role.default.name
}


## 
## Register the Servers in DNS
##

module "commvault_media_agent_dns_name" {
  source   = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  for_each = module.commvault_media_agents
  zone_id  = data.terraform_remote_state.base.outputs.route53_zone.zone_id
  name     = each.key
  type     = "A"
  records  = [each.value.instance.private_ip]
}

module "commvault_media_agent_reverse_dns_name" {
  source   = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-records"
  for_each = module.commvault_media_agents
  zone_id  = data.terraform_remote_state.base.outputs.route53_reverse_zone.zone_id
  name     = each.value.instance.private_ip
  type     = "REVERSE"
  records  = [lookup(module.commvault_media_agent_dns_name[each.key], "fqdn")]
}
