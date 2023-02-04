## Base Settings
region = "us-east-1"
#shared_credentials_file = "~/.aws/credentials"
profile = "terraformer-prod"

## Shared Service Remote Bucket
shared_service_bucket_name = "sapm-shared-services-prod-us-east-1-remote-state"
shared_service_role_arn    = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## Labels
namespace   = "sapm"
environment = "prod"
name        = "sap"
customer    = "CustomerSAPm"

## VPC
vpc_cidr                = "10.150.8.0/22"
enable_internet_gateway = true
base_dns_domain_name    = "aws.domain.com"
dns_domain_name         = "aws.domain.com"

## Public Subnet
public_subnets = {
  "us-east-1a" = "10.150.8.192/27"
  "us-east-1b" = "10.150.8.224/27"
}

enable_nat_gateway = true

## Private Subnets
private_subnets = {
  "us-east-1a" = "10.150.8.0/26"
  "us-east-1b" = "10.150.8.64/26"
}

target_route_cidr = "10.150.0.0/16"

target_static_route_cidrs = [
  "10.105.0.0/22", "10.215.1.0/24",
  "10.106.0.0/22", "10.215.2.0/24",
  "10.150.0.0/22", "192.168.20.0/24"
]

## Direct Connect Setup
amazon_side_asn       = 64550
dx_gateway_id         = "353ab663-1879-1234-99b9-d9cbc0b243e3"
dx_gateway_account_id = "26372457750"

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
    sap_control_cidr : ["10.150.8.0/25", "10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32", "10.150.12.198/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  },
  {
    sysnr : "01",
    is_scs : true,
    enable_sap_standard_http : true
    sap_base_cidr : ["10.150.8.0/25", "10.150.12.0/25"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.8.0/25", "10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32", "10.150.12.198/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [
      {
        from_port : 4901,
        to_port : 4901,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "Connection from SAP Solman for DBA Cockpit."
      }
    ],
    additional_egress_rules : [
      {
        from_port : 50200,
        to_port : 50200,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - SLD"
        }, {
        from_port : 6001,
        to_port : 6001,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - Wily "
        }, {
        from_port : 8103,
        to_port : 8103,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - Message Server Port "
        }, {
        from_port : 3303,
        to_port : 3303,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - Gateway"
        }, {
        from_port : 4803,
        to_port : 4803,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - Secure Gateway"
      },
    ]
  }
]

sap_j2ee_security_groups = [
  {
    sysnr : "00",
    is_scs : false,
    sap_base_cidr : [
      "10.150.0.0/22", "10.150.4.0/22",
      "10.150.8.0/22", "10.150.12.0/22",
    "10.50.0.0/12", "10.25.0.0/13"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.4.0/25", "10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32", "10.150.12.198/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [],
    additional_egress_rules : []
  },
  {
    sysnr : "01",
    is_scs : true,
    sap_base_cidr : ["10.150.8.0/25", "10.150.12.0/25",
    "10.50.0.0/12", "10.25.0.0/13"],
    sap_base_prefix : [],
    sap_control_cidr : ["10.150.8.0/25", "10.150.12.0/25"],
    sap_control_prefix : [],
    sap_router_sysnr : "3299"
    sap_router_cidr : ["10.51.1.44/32", "10.150.12.198/32"],
    sap_router_prefix : [],
    additional_ingress_rules : [
      {
        from_port : 4901,
        to_port : 4901,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32", ],
        prefix_ids : [],
        security_group : "",
        description : "Connection from SAP Solman for DBA Cockpit."
      }
    ],
    additional_egress_rules : [
      {
        from_port : 50200,
        to_port : 50200,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - SLD"
        }, {
        from_port : 6001,
        to_port : 6001,
        protocol : "TCP",
        cidr_blocks : ["10.150.12.31/32"],
        prefix_ids : [],
        security_group : "",
        description : "SAP SolMan - Wily "
      },
    ]
  }
]