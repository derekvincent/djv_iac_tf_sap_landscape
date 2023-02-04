resource "aws_security_group" "default" {
  name        = local.instance_sg_name
  description = join(" - ", ["SAP BC system", var.hostname])
  vpc_id      = data.terraform_remote_state.base.outputs.vpc.vpc_id

  tags = merge(
    local.common_tags,
    map(
      "Name", local.instance_sg_name
    )
  )
}

resource "aws_security_group_rule" "egress" {
  for_each          = var.security_group_egress_rules
  type              = "egress"
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  description       = lookup(each.value, "description", "")
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress" {
  for_each          = var.security_group_ingress_rules
  type              = "ingress"
  from_port         = lookup(each.value, "from_port")
  to_port           = lookup(each.value, "to_port")
  protocol          = lookup(each.value, "protocol")
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  prefix_list_ids   = lookup(each.value, "prefix_ids", null)
  description       = lookup(each.value, "description", "")
  security_group_id = aws_security_group.default.id
}