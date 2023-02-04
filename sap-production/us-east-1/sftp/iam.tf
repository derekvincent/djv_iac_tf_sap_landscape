##
## Create EC2 Instance roles, attach standard policies and profiles. 
##

## Create a Role for the EC2 instance
resource "aws_iam_role" "sftp" {
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
    )
  )
}

# Assign the SSM policy to the role
resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.sftp.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## Assign the CloudWatch policy to the role
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.sftp.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

## Create an Instance Profile for the Role
resource "aws_iam_instance_profile" "sftp" {
  name = join("-", [local.instance_name, "role"])
  role = aws_iam_role.sftp.name
}

##
## Create an line policy and attach it to the role for the Shared Service assume roles
##

## Attach the inline policy to the role. 
resource "aws_iam_role_policy" "inline-policy-shared-roles" {
  count  = length(local.assumed_shared_roles) == 0 ? 0 : 1
  name   = join("-", [local.instance_name, "assumed-shared-roles"])
  role   = aws_iam_role.sftp.name
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

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads",
    ]

    resources = [
      for key, value in var.sftp_shares :
      format("arn:aws:s3:::%s", value.bucket)
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]

    resources = flatten([
      for key, value in var.sftp_shares :
      tolist([format("arn:aws:s3:::%s%s", value.bucket, value.bucket_prefix),
      format("arn:aws:s3:::%s%s/*", value.bucket, value.bucket_prefix)])
    ])

    effect = "Allow"
  }
}

## Attach the inline policy to the role. 
resource "aws_iam_role_policy" "inline-policy-s3" {
  name   = join("-", [local.instance_name, "s3-roles"])
  role   = aws_iam_role.sftp.name
  policy = data.aws_iam_policy_document.s3_policy_document.json
}