## Creates the Admin Authorization for the Commcell User .
locals {
  admin_policy_name = lower(join("-", [var.namespace, var.name, var.environment, "commvault-admin-policy"]))
  admin_role_name   = lower(join("-", [var.namespace, var.name, var.environment, "commvault-admin-role"]))
}


data "aws_iam_policy_document" "commvault_admin_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "commvault_admin_role" {
  count              = var.enable_commvault_admin == false ? 0 : 1
  name               = local.admin_role_name
  assume_role_policy = data.aws_iam_policy_document.commvault_admin_role_policy.json
}

resource "aws_iam_role_policy_attachment" "commvault-admin-attach" {
  role       = join("", aws_iam_role.commvault_admin_role.*.name)
  policy_arn = join("", aws_iam_policy.commvault-admin-policy.*.arn)
}

## Create the Commvault Admin Policy and assign the document to it
resource "aws_iam_policy" "commvault-admin-policy" {
  count  = var.enable_commvault_admin == false ? 0 : 1
  name   = local.admin_policy_name
  policy = data.aws_iam_policy_document.commvault_admin_policy_document.json
}

## Create the Commvault Admin policy document
data "aws_iam_policy_document" "commvault_admin_policy_document" {

  statement {
    effect = "Allow"
    actions = [
      "ssm:CancelCommand",
      "ssm:SendCommand",
      "ssm:ListDocuments",
      "ssm:ListCommands",
      "ssm:DescribeDocument",
      "ssm:DescribeInstanceInformation",
      "ec2:CopySnapshot",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DescribeInstances",
      "ec2:ModifyVolumeAttribute",
      "ec2:CreateKeyPair",
      "ec2:DescribeVolumesModifications",
      "ec2:CreateImage",
      "ec2:DescribeSnapshots",
      "ec2:DeleteVolume",
      "ec2:ModifySnapshotAttribute",
      "ec2:ModifyImageAttribute",
      "ec2:StartInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeAccountAttributes",
      "ec2:ImportImage",
      "ec2:DescribeKeyPairs",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:CreateTags",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:DeleteNetworkInterface",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:DescribeVolumeAttribute",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateNetworkInterface",
      "ec2:DisassociateIamInstanceProfile",
      "ec2:DescribeSubnets",
      "ec2:AttachVolume",
      "ec2:DeregisterImage",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeRegions",
      "ec2:GetConsoleOutput",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeNetworkInterfaceAttribute",
      "ec2:CreateSecurityGroup",
      "ec2:ModifyInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:TerminateInstances",
      "ec2:DetachNetworkInterface",
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeTags",
      "ec2:DescribeImportImageTasks",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeImages",
      "ec2:DescribeVpcs",
      "ec2:AttachNetworkInterface",
      "ec2:AssociateIamInstanceProfile",
      "ebs:ListChangedBlocks",
      "ebs:ListSnapshotBlocks",
      "s3:PutBucketAcl",
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:DeleteObject",
      "iam:PassRole",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:GetUser",
      "iam:ListInstanceProfiles",
      "iam:GetAccountAuthorizationDetails",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey*",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ListResourceTags",
      "kms:CreateKey",
      "kms:CreateAlias",
      "kms:ListGrants",
      "kms:TagResource"
    ]

    resources = [
      "*"
    ]
  }
}