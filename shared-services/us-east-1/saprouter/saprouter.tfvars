## Base Settings
region  = "us-east-1"
profile = "terraformer-shared"

## Labels
namespace         = "sapm"
environment       = "prod"
name              = "shared-services"
customer          = "CustomerSAPm"
sap_application   = "SAPROUTER"
sap_instance_type = "SAPROUTER"
#
base_infra_state_bucket = "sapm-shared-services-prod-us-east-1-remote-state"
base_infra_state_key    = "shared-service/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 

hostname           = "saprout"
s3_download_bucket = "sapm-shared-service-prod-us-east-1-sap-software"
s3_download_prefix = "/saprouter"
saprout_dir        = "/opt/saprouter"

##
## EC2 Settings
##
ec2_ami               = "ami-0a782e324655d1cc0"
ec2_instance_type     = "t3.micro"
key_name              = "sapm-shared-service-prod-us-east-1"
enable_public_address = true

security_group_egress_rules = {
  http : {
    from_port : 80,
    to_port : 80,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound HTTP Acess to the Internet"
  },
  https : {
    from_port : 443,
    to_port : 443,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound HTTP Acess to the Internet."
  },
  icmp : {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP to Dev, QA, Prod private subnets and VPN."
  },
  sap_3299 : {
    from_port : 3299,
    to_port : 3299,
    protocol : "TCP",
    cidr_blocks : ["10.100.1.0/25", "10.150.4.0/25", "10.150.8.0/25", "10.150.12.0/25", "10.51.1.56/32"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Router Connection via SAP 3299 to SAP subnets."
  },
  sapserv2 : {
    from_port : 3299,
    to_port : 3299,
    protocol : "TCP",
    cidr_blocks : ["194.39.131.34/32"],
    prefix_ids : [],
    security_groups : [],
    description : "Allow outbound to SAP Router sapserv2 for SNC support."
  }
}

security_group_ingress_rules = {
  icmp : {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  ssh : {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.150.4.0/22", "10.50.0.0/12", "10.150.12.0/22", "10.25.0.0/13", ],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from QA private subnets and VPN."
  },
  sap_3299 : {
    from_port : 3299,
    to_port : 3299,
    protocol : "TCP",
    cidr_blocks : ["10.100.1.0/25", "10.150.4.0/25", "10.150.8.0/25", "10.150.12.0/25", "10.51.1.56/32"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Router Connection via SAP 3299 from SAP subnets."
  },
  sapserv2 : {
    from_port : 3299,
    to_port : 3299,
    protocol : "TCP",
    cidr_blocks : ["194.39.131.34/32"],
    prefix_ids : [],
    security_groups : [],
    description : "Allow inbound to SAP Router sapserv2 for SNC support."
  }
}
