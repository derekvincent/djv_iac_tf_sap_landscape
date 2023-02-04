locals {

  subnet_ids = tolist([module.public_subnets.subnet_ids[1],
  module.private_subnets.subnet_ids[0]])

  vpc_route_table_list = tolist([module.vpc.vpc_main_route_table_id,
    module.public_subnets.route_table_id,
  module.private_subnets.route_table_id])
}
## Create VPC
module "vpc" {
  source                  = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/vpc"
  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  name                    = var.name
  customer                = var.customer
  vpc_cidr                = var.vpc_cidr
  enable_internet_gateway = var.enable_internet_gateway
  dns_domain_name         = var.dns_domain_name
}

## Create Public Subnets
module "public_subnets" {
  source             = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/subnets"
  vpc_id             = module.vpc.vpc_id
  region             = var.region
  namespace          = var.namespace
  environment        = var.environment
  name               = var.name
  customer           = var.customer
  public_subnets     = var.public_subnets
  igw_id             = module.vpc.igw_id
  enable_nat_gateway = var.enable_nat_gateway
  type               = "public"
}

## Create Private Subnets
module "private_subnets" {
  source             = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/subnets"
  vpc_id             = module.vpc.vpc_id
  region             = var.region
  namespace          = var.namespace
  environment        = var.environment
  name               = var.name
  customer           = var.customer
  private_subnets    = var.private_subnets
  type               = "private"
  enable_nat_gateway = var.enable_nat_gateway
  ngw_id             = module.public_subnets.nat_gateway_id
}

##
## Access the Shared Service Base Infrastrucutre State
##
data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    region   = var.region
    bucket   = var.shared_service_bucket_name
    key      = var.shared_service_base_state_file
    role_arn = var.shared_service_role_arn
  }
}

##
## Access the Shared Service - Assumed Roles State
##
## This is used to to fetch information about roles and policy that were
## created in the shared service assumed roles module. Most of the exposure
## will be in the output of this module for other modules in the account to use. 
## 
data "terraform_remote_state" "assumed_roles" {
  backend = "s3"
  config = {
    region   = var.region
    bucket   = var.shared_service_bucket_name
    key      = var.shared_service_assumed_role_state_file
    role_arn = var.shared_service_role_arn
  }
}


## Create VPC Enpoint for S3

module "endpoint_service_s3" {
  source             = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/vpc-endpoints"
  vpc_id             = module.vpc.vpc_id
  region             = var.region
  namespace          = var.namespace
  environment        = var.environment
  name               = var.name
  customer           = var.customer
  enable_s3_endpoint = true
  route_table_ids    = local.vpc_route_table_list
}

##
## Assign the VPC ID to the hosted zone to enable DNS resolution. 
##

##
## We need to ensure that we create an authorization in the Shared Service zone first. 
## To do this we need to used an assumed role that allows us access to create the 
## authorization in the shared services account. 
##
module "zone_vpc_association_authorization" {
  source = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-zone-association-authorization"
  #role_provider = aws.assumed_shared_service
  providers = { aws = aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.route53_zone.zone_id
  vpc_id    = module.vpc.vpc_id
}

module "route53_zone_association" {
  source  = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-zone-association"
  zone_id = data.terraform_remote_state.base.outputs.route53_zone.zone_id
  vpc_id  = module.vpc.vpc_id

  depends_on = [module.zone_vpc_association_authorization]
}

module "reverse_zone_vpc_association_authorization" {
  source    = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-zone-association-authorization"
  providers = { aws = aws.assumed_shared_service }
  zone_id   = data.terraform_remote_state.base.outputs.route53_reverse_zone.zone_id
  vpc_id    = module.vpc.vpc_id
}

module "route53_reverse_zone_association" {
  source  = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-zone-association"
  zone_id = data.terraform_remote_state.base.outputs.route53_reverse_zone.zone_id
  vpc_id  = module.vpc.vpc_id

  depends_on = [module.reverse_zone_vpc_association_authorization]
}

## Create a Virtual Gateway and associate it the a Direct Connect Gateway. 
module "direct_connect_vpg" {
  source                = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/virtual-private-gateway-dx"
  region                = var.region
  namespace             = var.namespace
  environment           = var.environment
  name                  = var.name
  customer              = var.customer
  vpc_id                = module.vpc.vpc_id
  amazon_side_asn       = var.amazon_side_asn
  route_table_ids       = local.vpc_route_table_list
  dx_gateway_id         = var.dx_gateway_id
  dx_gateway_account_id = var.dx_gateway_account_id

}

##
## Create a Transit Gateway attachment to the transit gateway in the shared service account.
##
## In order for this to work we need a RAM resource for the transit gateway shared in from 
## the Shared Service account. This should be done by the shared service base-infrastructure 
## terraforms but if you get an error about not being able to find the transit gateway then
## verify it is setup correctly. 
##
module "transit_gateway_attachment" {
  source             = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/transit-gateway-attachment"
  region             = var.region
  namespace          = var.namespace
  environment        = var.environment
  name               = var.name
  customer           = var.customer
  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = data.terraform_remote_state.base.outputs.transit_gateway_id
  subnet_ids         = local.subnet_ids
  destination_cidr   = var.target_route_cidr
  route_table_ids    = local.vpc_route_table_list
}

##
## Include Static VPN routes in the local subnet routing tables. 
##
module "customer_gateway_routes" {
  source                  = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/routing"
  count                   = length(local.vpc_route_table_list)
  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  name                    = var.name
  customer                = var.customer
  route_table_id          = local.vpc_route_table_list[count.index]
  destination_cidr_blocks = var.target_static_route_cidrs
  transit_gateway_id      = data.terraform_remote_state.base.outputs.transit_gateway_id

  depends_on = [module.transit_gateway_attachment]
}

## Associate the current VPC with all of the created resolver rules for the Shared Service zone
module "route53_resolver_rule_association" {
  source            = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-resolver-association"
  vpc_id            = module.vpc.vpc_id
  resolver_rule_ids = data.terraform_remote_state.base.outputs.resolver_forward_rule_ids
}

##
## Create the Generic SAP security groups 
##

module "sap_abap_security_groups" {
  source                   = "github.com/derekvincent/tf_sap_modules/sap-security-group"
  count                    = length(var.sap_security_groups)
  region                   = var.region
  namespace                = var.namespace
  environment              = var.environment
  name                     = var.name
  customer                 = var.customer
  vpc_id                   = module.vpc.vpc_id
  sysnr                    = lookup(var.sap_security_groups[count.index], "sysnr")
  is_scs                   = lookup(var.sap_security_groups[count.index], "is_scs")
  enable_sap_standard_http = lookup(var.sap_security_groups[count.index], "enable_sap_standard_http")
  sap_base_cidr            = lookup(var.sap_security_groups[count.index], "sap_base_cidr", null)
  sap_base_prefix          = lookup(var.sap_security_groups[count.index], "sap_base_prefix", null)
  sap_control_cidr         = lookup(var.sap_security_groups[count.index], "sap_control_cidr", null)
  sap_control_prefix       = lookup(var.sap_security_groups[count.index], "sap_control_prefix", null)
  sap_router_sysnr         = lookup(var.sap_security_groups[count.index], "sap_router_sysnr", null)
  sap_router_cidr          = lookup(var.sap_security_groups[count.index], "sap_router_cidr", null)
  sap_router_prefix        = lookup(var.sap_security_groups[count.index], "sap_router_prefix", null)
  additional_ingress_rules = lookup(var.sap_security_groups[count.index], "additional_ingress_rules", null)
  additional_egress_rules  = lookup(var.sap_security_groups[count.index], "additional_egress_rules", null)
}

module "sap_java_security_groups" {
  source                   = "github.com/derekvincent/tf_sap_modules/sap-j2ee-security-group"
  count                    = length(var.sap_security_groups)
  region                   = var.region
  namespace                = var.namespace
  environment              = var.environment
  name                     = var.name
  customer                 = var.customer
  vpc_id                   = module.vpc.vpc_id
  sysnr                    = lookup(var.sap_j2ee_security_groups[count.index], "sysnr")
  is_scs                   = lookup(var.sap_j2ee_security_groups[count.index], "is_scs")
  sap_base_cidr            = lookup(var.sap_j2ee_security_groups[count.index], "sap_base_cidr", null)
  sap_base_prefix          = lookup(var.sap_j2ee_security_groups[count.index], "sap_base_prefix", null)
  sap_control_cidr         = lookup(var.sap_j2ee_security_groups[count.index], "sap_control_cidr", null)
  sap_control_prefix       = lookup(var.sap_j2ee_security_groups[count.index], "sap_control_prefix", null)
  sap_router_sysnr         = lookup(var.sap_j2ee_security_groups[count.index], "sap_router_sysnr", null)
  sap_router_cidr          = lookup(var.sap_j2ee_security_groups[count.index], "sap_router_cidr", null)
  sap_router_prefix        = lookup(var.sap_j2ee_security_groups[count.index], "sap_router_prefix", null)
  additional_ingress_rules = lookup(var.sap_j2ee_security_groups[count.index], "additional_ingress_rules", null)
  additional_egress_rules  = lookup(var.sap_j2ee_security_groups[count.index], "additional_egress_rules", null)
}