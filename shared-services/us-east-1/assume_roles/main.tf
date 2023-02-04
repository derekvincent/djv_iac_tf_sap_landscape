
locals {

  ## More to come as needed
  policy_arns = list(
    data.terraform_remote_state.base_infrastructure.outputs.private_zone_policy_arn,
    data.terraform_remote_state.base_infrastructure.outputs.private_reverse_zone_policy_arn,
    data.terraform_remote_state.bootstrap.outputs.state_policy_arn
  )

  shared_sap_buckets = data.terraform_remote_state.base_infrastructure.outputs.shared_sap_buckets_arns

  shared_sap_all_buckets = [for value in local.shared_sap_buckets :
    join("/", [value, "*"])
  ]

  ca_role_name = join("-", [var.namespace, var.name, var.environment, "cross-account-assume-role"])

  sap_bucket_role_name   = join("-", [var.namespace, var.name, var.environment, "ca-sap-bucket-role"])
  sap_bucket_policy_name = join("-", [var.namespace, var.name, var.environment, "ca-sap-bucket-policy"])

  tag_name_env         = join(":", [var.namespace, "environment"])
  tag_name_customer    = join(":", [var.namespace, "customer"])
  tag_name_application = join(":", [var.namespace, "application"])
  common_tags = map(
    local.tag_name_env, var.environment,
    local.tag_name_customer, var.customer,
    local.tag_name_application, var.name
  )
}

data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.shared_services_remote_state_bucket
    key    = var.shared_services_base_infrastructure_key
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.shared_services_remote_state_bucket
    key    = var.shared_services_bootstrap_key
  }
}

##
## Shared Account Deployment Roles
##
data "aws_iam_policy_document" "cross_account_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.account_ids
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cross_account_assume_role" {
  name               = local.ca_role_name
  description        = "Assumed Role that other account deploying resource can use to access and deploy to."
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy.json

  tags = merge(
    local.common_tags,
    map(
      "Name", local.ca_role_name
    )
  )
}

resource "aws_iam_role_policy_attachment" "cross_account_assume_role" {
  count = length(local.policy_arns)

  role       = aws_iam_role.cross_account_assume_role.name
  policy_arn = element(local.policy_arns, count.index)
}


##
## Shared SAP Buckets role/policy for use with instance profiles
##
## 1. Generate an Assume IAM Policy document template
## 2. Create the IAM Policy for the SAP S3 buckets
## 3. Create the IAM Role 
## 4. Assing the IAM S3 Bucket Polict to the Role
##
data "aws_iam_policy_document" "cross_account_sap_buckets" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.account_ids
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "cross_account_sap_buckets" {

  name = local.sap_bucket_policy_name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:ListBucket",
        "Resource" : "${local.shared_sap_buckets}"
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:GetObject", "s3:PutObject"],
        "Resource" : "${local.shared_sap_all_buckets}"
      }
    ]
  })
}

resource "aws_iam_role" "cross_account_sap_buckets" {
  name               = local.sap_bucket_role_name
  description        = "Assumed Role for standard SAP buckets that are shared withouther account."
  assume_role_policy = data.aws_iam_policy_document.cross_account_assume_role_policy.json

  tags = merge(
    local.common_tags,
    map(
      "Name", local.sap_bucket_role_name
    )
  )
}

resource "aws_iam_role_policy_attachment" "cross_account_sap_role" {
  role       = aws_iam_role.cross_account_sap_buckets.name
  policy_arn = aws_iam_policy.cross_account_sap_buckets.arn
}