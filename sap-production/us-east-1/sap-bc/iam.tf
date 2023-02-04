##
## Create EC2 Instance roles, attach standard policies and profiles. 
##

## Create a Role for the EC2 instance
resource "aws_iam_role" "sap_bc" {
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
      "Name", join("-", [local.instance_name, "role"]),
      local.tag_name_sap_app, var.sap_application,
    )
  )
}

# Assign the SSM policy to the role
resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.sap_bc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## Assign the CloudWatch policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.sap_bc.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

## Create an Instance Profile for the Role
resource "aws_iam_instance_profile" "sap_bc" {
  name = join("-", [local.instance_name, "role"])
  role = aws_iam_role.sap_bc.name
}

##
## Create an line policy and attach it to the role for the Shared Service assume roles
##

## Attach the inline policy to the role. 
resource "aws_iam_role_policy" "inline-policy-shared-roles" {
  count  = length(local.assumed_shared_roles) == 0 ? 0 : 1
  name   = join("-", [local.instance_name, "assumed-shared-roles"])
  role   = aws_iam_role.sap_bc.name
  policy = data.aws_iam_policy_document.inline-policy-document-shared-roles[count.index].json
}

## Create the Inline policy 
data "aws_iam_policy_document" "inline-policy-document-shared-roles" {

  count = length(local.assumed_shared_roles) == 0 ? 0 : 1
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    resources = local.assumed_shared_roles
  }
}