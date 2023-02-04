locals {

  subnet_ids = tolist([module.public_subnets.subnet_ids[1],
  module.private_subnets.subnet_ids[0]])

  vpc_route_table_list = tolist([module.vpc.vpc_main_route_table_id,
    module.public_subnets.route_table_id,
  module.private_subnets.route_table_id])

  target_static_route_cidrs = flatten([for key, value in var.customer_gateways :
    value.target_static_route_cidrs
  ])
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
    region = var.region
    bucket = var.shared_service_assumed_role_bucket_name
    key    = var.shared_service_assumed_role_state_file
  }
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
## Create the Base AWS DNS domain in the Shared Service Route53 Account

module "route53_base_zone" {
  source          = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53"
  vpc_id          = module.vpc.vpc_id
  region          = var.region
  namespace       = var.namespace
  environment     = var.environment
  name            = var.name
  customer        = var.customer
  dns_domain_name = var.base_dns_domain_name
}

module "route53_reverse_zone" {
  source          = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53"
  vpc_id          = module.vpc.vpc_id
  region          = var.region
  namespace       = var.namespace
  environment     = var.environment
  name            = var.name
  customer        = var.customer
  dns_domain_name = var.reverse_dns_zone
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

module "transit_gateway" {
  source              = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/transit-gateway"
  region              = var.region
  namespace           = var.namespace
  environment         = var.environment
  name                = var.name
  customer            = var.customer
  vpc_id              = module.vpc.vpc_id
  destination_cidr    = var.target_route_cidr
  subnet_ids          = local.subnet_ids
  vpc_route_table_ids = local.vpc_route_table_list
}

## Create the VPN

module "customer_gateways" {
  for_each                             = var.customer_gateways
  source                               = "github.com/derekvincent/tf_sap_landingzone/customer-gateway"
  region                               = var.region
  namespace                            = var.namespace
  environment                          = var.environment
  name                                 = var.name
  customer                             = each.key
  target                               = each.key
  ip_address                           = lookup(each.value, "customer_gateway_ip")
  transit_gateway_id                   = module.transit_gateway.id
  transit_gateway_route_table_id       = module.transit_gateway.route_table_id
  static_routes_only                   = lookup(each.value, "static_routes_only")
  target_static_route_cidrs            = lookup(each.value, "target_static_route_cidrs")
  tunnel1_ike_versions                 = lookup(each.value, "tunnel1_ike_versions")
  tunnel1_phase1_dh_group_numbers      = lookup(each.value, "tunnel1_phase1_dh_group_numbers")
  tunnel1_phase1_encryption_algorithms = lookup(each.value, "tunnel1_phase1_encryption_algorithms")
  tunnel1_phase1_integrity_algorithms  = lookup(each.value, "tunnel1_phase1_integrity_algorithms")
  tunnel1_phase2_dh_group_numbers      = lookup(each.value, "tunnel1_phase2_dh_group_numbers")
  tunnel1_phase2_encryption_algorithms = lookup(each.value, "tunnel1_phase2_encryption_algorithms")
  tunnel1_phase2_integrity_algorithms  = lookup(each.value, "tunnel1_phase2_integrity_algorithms")
  tunnel2_ike_versions                 = lookup(each.value, "tunnel2_ike_versions")
  tunnel2_phase1_dh_group_numbers      = lookup(each.value, "tunnel2_phase1_dh_group_numbers")
  tunnel2_phase1_encryption_algorithms = lookup(each.value, "tunnel2_phase1_encryption_algorithms")
  tunnel2_phase1_integrity_algorithms  = lookup(each.value, "tunnel2_phase1_integrity_algorithms")
  tunnel2_phase2_dh_group_numbers      = lookup(each.value, "tunnel2_phase2_dh_group_numbers")
  tunnel2_phase2_encryption_algorithms = lookup(each.value, "tunnel2_phase2_encryption_algorithms")
  tunnel2_phase2_integrity_algorithms  = lookup(each.value, "tunnel2_phase2_integrity_algorithms")
}

## Define the Rotues to the Gateway 

module "customer_gateway_routes" {
  source                  = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/routing"
  count                   = length(local.vpc_route_table_list)
  region                  = var.region
  namespace               = var.namespace
  environment             = var.environment
  name                    = var.name
  customer                = var.customer
  route_table_id          = local.vpc_route_table_list[count.index]
  destination_cidr_blocks = local.target_static_route_cidrs
  transit_gateway_id      = module.transit_gateway.id
}

## Setup the Route53 Resolvers 
module "route53_resolver_endpoints" {
  source            = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/route53-resolver"
  region            = var.region
  namespace         = var.namespace
  environment       = var.environment
  name              = var.name
  customer          = var.customer
  vpc_id            = module.vpc.vpc_id
  out_subnet_1_id   = module.private_subnets.subnet_ids[0]
  out_subnet_2_id   = module.private_subnets.subnet_ids[1]
  in_subnet_1_id    = module.private_subnets.subnet_ids[0]
  in_subnet_2_id    = module.private_subnets.subnet_ids[1]
  forward_rules_map = var.resolver_forward_rules_map
}


## 
## Create the Shared EFS file system for the SAP Transport Directory 
##

module "sap_transport_efs" {
  source                         = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/elastic-file-system"
  region                         = var.region
  namespace                      = var.namespace
  environment                    = var.environment
  name                           = var.name
  customer                       = var.customer
  detail_name                    = var.efs_detail_name
  description                    = var.efs_description
  vpc_id                         = module.vpc.vpc_id
  mount_subnets                  = module.private_subnets.subnet_ids
  access_points                  = var.efs_access_points
  security_group_cidrs           = var.efs_security_group_cidrs
  security_group_prefix_list_ids = var.efs_security_group_prefix_list_ids
}



##
## Create a number of base services that will be shared across all environments. 
## 

module "sap_software_bucket" {
  source      = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/s3-bucket"
  region      = var.region
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  customer    = var.customer
  bucket_name = var.sap_software_bucket
}

module "sap_migration_data_bucket" {
  source      = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/s3-bucket"
  region      = var.region
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  customer    = var.customer
  bucket_name = var.sap_migration_data_bucket
}

## Create the Base SAP security groups
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