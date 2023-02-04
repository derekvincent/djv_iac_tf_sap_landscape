## Creates the S3 Buckets to be used as the libaries and a policy to access them

locals {
  s3_policy_name  = lower(join("-", [var.namespace, var.name, var.environment, "s3-library-policy"]))
  enabled_buckets = length(var.commvault_s3_bucket) == 0 ? 0 : 1
}

##
## Create S3 Buckets
##

module "commvault_s3_buckets" {
  source             = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/s3-bucket"
  for_each           = var.commvault_s3_bucket
  namespace          = var.namespace
  environment        = var.environment
  customer           = var.customer
  name               = var.name
  region             = var.region
  bucket_name        = each.key
  enable_versioning  = each.value.enable_versioning
  custom_bucket_name = each.value.custom_bucket_name
}

## Attach the inline policy to the role. 
resource "aws_iam_policy" "s3-bucket-policy" {
  count  = local.enabled_buckets
  name   = local.s3_policy_name
  policy = data.aws_iam_policy_document.s3_bucket_policy_document.json
}

## Create the Inline policy 
data "aws_iam_policy_document" "s3_bucket_policy_document" {

  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:DeleteObject"
    ]

    resources = flatten([for v in module.commvault_s3_buckets :
      [format("%s", v.bucket_arn), format("%s/*", v.bucket_arn)]
    ])
  }
}