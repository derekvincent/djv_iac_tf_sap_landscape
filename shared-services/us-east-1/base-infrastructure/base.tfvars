## Base Settings
region  = "us-east-1"
profile = "terraformer-shared"

## Labels
namespace   = "sapm"
environment = "prod"
name        = "shared-service"
customer    = "CustomerSAPm"

## VPC
vpc_cidr                = "10.150.12.0/22"
enable_internet_gateway = true

dns_domain_name      = "aws.domain.com"
base_dns_domain_name = "aws.domain.com"
reverse_dns_zone     = "100.10.in-addr.arpa"

## Public Subnet
public_subnets = {
  "us-east-1a" = "10.150.12.192/27"
  "us-east-1b" = "10.150.12.224/27"
}

enable_nat_gateway = true

## Private Subnets
private_subnets = {
  "us-east-1a" = "10.150.12.0/26"
  "us-east-1b" = "10.150.12.64/26"
}

target_route_cidr = "10.150.0.0/16"

## Direct Connect Setup
amazon_side_asn       = 64550
dx_gateway_id         = "353ab663-1879-1234-99b9-d9cbc0b243e3"
dx_gateway_account_id = "26372457750"

customer_gateways = {
  "RemoteOne" : {
    "customer_gateway_ip" : "116.111.23.229",
    "target_static_route_cidrs" : ["10.105.0.0/22", "10.215.1.0/24"],
    "static_routes_only" : true,
    "tunnel1_ike_versions" : ["ikev2"],
    "tunnel1_phase1_dh_group_numbers" : [14, ],
    "tunnel1_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel1_phase2_dh_group_numbers" : [14, ],
    "tunnel1_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase2_integrity_algorithms" : ["SHA2-256"],
    "tunnel2_ike_versions" : ["ikev2"],
    "tunnel2_phase1_dh_group_numbers" : [14, ],
    "tunnel2_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel2_phase2_dh_group_numbers" : [14, ],
    "tunnel2_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase2_integrity_algorithms" : ["SHA2-256"]
  },
  "RemoteTwo" : {
    "customer_gateway_ip" : "116.111.22.86",
    "target_static_route_cidrs" : ["10.106.0.0/22", "10.215.2.0/24"],
    "static_routes_only" : true,
    "tunnel1_ike_versions" : ["ikev2"],
    "tunnel1_phase1_dh_group_numbers" : [14, ],
    "tunnel1_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel1_phase2_dh_group_numbers" : [14, ],
    "tunnel1_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase2_integrity_algorithms" : ["SHA2-256"],
    "tunnel2_ike_versions" : ["ikev2"],
    "tunnel2_phase1_dh_group_numbers" : [14, ],
    "tunnel2_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel2_phase2_dh_group_numbers" : [14, ],
    "tunnel2_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase2_integrity_algorithms" : ["SHA2-256"]
  },
  "RemoteThree" : {
    "customer_gateway_ip" : "68.44.112.41",
    "target_static_route_cidrs" : ["10.150.0.0/22", "192.168.20.0/24"],
    "static_routes_only" : true,
    "tunnel1_ike_versions" : ["ikev2"],
    "tunnel1_phase1_dh_group_numbers" : [14, ],
    "tunnel1_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel1_phase2_dh_group_numbers" : [14, ],
    "tunnel1_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel1_phase2_integrity_algorithms" : ["SHA2-256"],
    "tunnel2_ike_versions" : ["ikev2"],
    "tunnel2_phase1_dh_group_numbers" : [14, ],
    "tunnel2_phase1_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase1_integrity_algorithms" : ["SHA2-256", ],
    "tunnel2_phase2_dh_group_numbers" : [14, ],
    "tunnel2_phase2_encryption_algorithms" : ["AES256", ],
    "tunnel2_phase2_integrity_algorithms" : ["SHA2-256"]
  },
}

resolver_forward_rules_map = {
  "domain.com"            = ["10.51.1.1", "10.51.1.2"]
  "RemoteTwo.com"         = ["10.51.1.1", "10.51.1.2"]
  "101.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "102.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "103.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "104.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "105.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "1.106.10.in-addr.arpa" = ["10.51.1.1", "10.51.1.2"]
  "107.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "108.10.in-addr.arpa"   = ["10.51.1.1", "10.51.1.2"]
  "0.100.10.in-addr.arpa" = ["10.51.1.1", "10.51.1.2"]
}

## EFS 
efs_detail_name = "saptrans"
efs_description = "SAP Transport - /usr/sap/trans mount point."
efs_access_points = {
  "grc" : { "root_directory" : "/sap/grc", "owner_uid" : 0, "owner_gid" : 1001, "permissions" : 775 },
  "ecc" : { "root_directory" : "/sap/ecc", "owner_uid" : 0, "owner_gid" : 1001, "permissions" : 775 },
  "po" : { "root_directory" : "/sap/po", "owner_uid" : 0, "owner_gid" : 1001, "permissions" : 775 },
}
## Allow only the Private subnets access for SAP DEV, QA, PROD and Shared Services. 
efs_security_group_cidrs = [
  "10.150.0.0/26", "10.150.0.64/26",
  "10.150.4.0/26", "10.150.4.64/26",
  "10.150.8.0/26", "10.150.8.64/26",
  "10.150.12.0/26", "10.150.12.64/26",
]

## Shared Buckets

sap_software_bucket       = "sap-software"
sap_migration_data_bucket = "sap-migration-data"

##
## Dialog Instance 00
## ===================
## Allow access to the base SAP ports from every AWS VPC and 
## every registered on-premise subnet. 
##
## Allow access to the sap control ports from the local private 
## subnet and shared services (solution manager, monitoring etc).
##
## ASCS Instance 01
## ================
## Allow access to the sap control ports from the local private 
## subnet and shared services (solution manager, monitoring etc).
##
sap_security_groups = [
  {
    sysnr : "00",
    is_scs : false,
    enable_sap_standard_http : true
    sap_base_cidr : [
      "10.150.0.0/22", "10.150.4.0/22",
      "10.150.8.0/22", "10.150.12.0/22",
      "10.50.0.0/12", "10.25.0.0/13"
    ],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  },
  {
    sysnr : "01",
    is_scs : true,
    enable_sap_standard_http : true
    sap_base_cidr : ["10.150.12.0/25"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  }
]

sap_j2ee_security_groups = [
  {
    sysnr : "02",
    is_scs : false,
    sap_base_cidr : [
      "10.150.0.0/22", "10.150.4.0/22",
      "10.150.8.0/22", "10.150.12.0/22",
    "10.50.0.0/12", "10.25.0.0/13"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  },
  {
    sysnr : "03",
    is_scs : true,
    sap_base_cidr : ["10.150.12.0/25", "10.50.0.0/12", "10.25.0.0/13"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  }
]