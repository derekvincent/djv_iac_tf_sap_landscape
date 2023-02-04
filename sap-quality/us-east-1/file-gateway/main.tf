locals {

  ## Fancy and dirty... Take the buckets map and create a list of the
  ## bucketname:shareskey --> share plus the a new entry call bucket 
  file_shares_list = flatten([for k, v in var.buckets : [
    for name, share in v.shares : {
      join(":", [k, name]) = merge(share, { bucket = k })
    }
    ]
  ])

  ## Turn the above in a proper object map again that can be used with for_each
  file_shares = { for item in local.file_shares_list :
    keys(item)[0] => values(item)[0]
  }

  bucket_arns = [for item in module.file_gateway_buckets : item.bucket_arn]
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.base_infra_state_bucket
    key    = var.base_infra_state_key
  }
}

# Get the caller ID of the production account. Used to allow access to the DEV/QA buckets from
# the on-premise  file Gateway. 

data "aws_caller_identity" "cross_account" {
  provider = aws.cross_account
}

module "file_gateway_buckets" {
  source            = "github.com/derekvincent/tf_sap_landingzone/storage-gateway-bucket"
  for_each          = var.buckets
  region            = var.region
  namespace         = var.namespace
  environment       = each.value.environment
  name              = each.value.name
  customer          = each.value.customer
  bucket_name       = each.value.bucket_name
  shared_account_id = data.aws_caller_identity.cross_account.account_id
}

## These are for the buckets that the object transport will copy the files between 
## and will be exposed via the on-premise storage gateway. 
module "file_gateway_onprem_buckets" {
  source            = "github.com/derekvincent/tf_sap_landingzone/storage-gateway-bucket"
  for_each          = var.on_premise_buckets
  region            = var.region
  namespace         = var.namespace
  environment       = each.value.environment
  name              = each.value.name
  customer          = each.value.customer
  bucket_name       = each.value.bucket_name
  shared_account_id = data.aws_caller_identity.cross_account.account_id
}

module "file_gateway" {
  source         = "github.com/derekvincent/tf_sap_landingzone/file-gateway"
  region         = var.region
  namespace      = var.namespace
  environment    = var.environment
  name           = var.name
  customer       = var.customer
  sname          = var.sname
  vpc_id         = data.terraform_remote_state.base.outputs.vpc.vpc_id
  subnet_id      = data.terraform_remote_state.base.outputs.private_subnet_primary_id
  key_name       = var.key_name
  admin_cidrs    = var.admin_cidrs
  nfs_cidrs      = var.nfs_cidrs
  dns_cidrs      = var.dns_cidrs
  bucket_arns    = local.bucket_arns
  gateway_name   = var.gateway_name
  gateway_domain = data.aws_route53_zone.default.name
}

data "aws_route53_zone" "default" {
  provider     = aws.assumed_shared_service
  zone_id      = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  private_zone = true
}

module "file_gateway_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_zone_id
  name      = var.gateway_name
  type      = "A"
  records   = [module.file_gateway.instance.private_ip]
}

## Fix after moving to xyz tree
module "file_gateway_reverse_dns_name" {
  source    = "github.com/derekvincent/tf_sap_landingzone/route53-records"
  providers = { aws : aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.vpc_domain_reverse_zone_id
  name      = module.file_gateway.instance.private_ip
  type      = "REVERSE"
  records   = [module.file_gateway.fqdn]
}

resource "aws_s3_bucket_object" "prefixes" {
  for_each     = { for k, v in local.file_shares : k => v if v.prefix != "" }
  bucket       = module.file_gateway_buckets[each.value.bucket].bucket_name
  acl          = "private"
  key          = each.value.prefix
  content_type = "application/x-directory"
}

module "file_gateway_shares" {
  source                = "github.com/derekvincent/tf_sap_landingzone/file-gateway-nfs-share"
  for_each              = local.file_shares
  region                = var.region
  namespace             = var.namespace
  environment           = var.buckets[each.value.bucket].environment
  name                  = var.buckets[each.value.bucket].name
  customer              = var.buckets[each.value.bucket].customer
  sname                 = var.sname
  gateway_arn           = module.file_gateway.file_gateway_arn
  client_list           = each.value.client_list
  location_arn          = join("", [module.file_gateway_buckets[each.value.bucket].bucket_arn, each.value.prefix])
  role_arn              = module.file_gateway_buckets[each.value.bucket].bucket_role_arn
  file_share_name       = each.value.file_share_name
  default_storage_class = each.value.default_storage_class
  group_id              = each.value.group_id
  depends_on            = [aws_s3_bucket_object.prefixes]
}
