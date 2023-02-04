##
## Create EC2 Instance roles, attach standard policies and profiles. 
##

## Create a Role for the EC2 instance
resource "aws_iam_role" "saprouter" {
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
    tomap({
      "Name"                   = join("-", [local.instance_name, "role"]),
      (local.tag_name_sap_app) = var.sap_application,
    })
  )
}

# Assign the SSM policy to the role
resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.saprouter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## Assign the CloudWatch policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.saprouter.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

## Create an Instance Profile for the Role
resource "aws_iam_instance_profile" "saprouter" {
  name = join("-", [local.instance_name, "role"])
  role = aws_iam_role.saprouter.name
}

##
## Create an line policy and attach it to the role for the Shared Service assume roles
##

## Attach the inline policy to the role. 
resource "aws_iam_role_policy" "inline-policy-shared-roles" {
  count  = length(local.assumed_shared_roles) == 0 ? 0 : 1
  name   = join("-", [local.instance_name, "assumed-shared-roles"])
  role   = aws_iam_role.saprouter.name
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

## Attach the s3 software bucket inline policy to the role. 
resource "aws_iam_role_policy" "inline-policy-software-bucket" {
  name   = join("-", [local.instance_name, "software-bucket"])
  role   = aws_iam_role.saprouter.name
  policy = data.aws_iam_policy_document.inline-policy-document-software-bucket.json
}

## Create the Inline policy 
data "aws_iam_policy_document" "inline-policy-document-software-bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",

    ]
    resources = [
      join("", ["arn:aws:s3:::", var.s3_download_bucket])
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      join("", ["arn:aws:s3:::", var.s3_download_bucket]),
      join("", ["arn:aws:s3:::", var.s3_download_bucket, "/*"])
    ]
  }
} 