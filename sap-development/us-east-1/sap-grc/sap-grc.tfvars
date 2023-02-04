## Base Settings
region  = "us-east-1"
profile = "terraformer-dev"

## Labels
namespace               = "sapm"
environment             = "dev"
name                    = "sap"
customer                = "CustomerSAPm"
sap_application         = "GRC"
sap_application_version = "12.00, SP10"
sap_netweaver_version   = "7.52, SP08"
sap_instance_type       = "ASCS, DIALOG, DB"
#
base_infra_state_bucket = "sapm-sap-dev-us-east-1-remote-state"
base_infra_state_key    = "sap-dev/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

hostname       = "grcdev"
sap_sid        = "DRC"
sap_sysnr      = "00"
sap_ascs_sysnr = "01"

##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0" # us-east-1 
ec2_instance_type = "m5.xlarge"
swap_volume_size  = 32
key_name          = "sapm-sap-dev-us-east-1"

ebs_disk_layouts = { "sdf" : { "type" : "gp2", "size" : 120, "encrypted" : true, "description" : "sap volume" },
  "sdh" : { "type" : "gp2", "size" : 150, "encrypted" : true, "description" : "db volume" },
  "sdo" : { "type" : "gp2", "size" : 300, "encrypted" : true, "description" : "workspace" },
  "sdm" : { "type" : "gp2", "size" : 150, "encrypted" : true, "description" : "Backup" }
}

##
## EFS Details 
##

efs_name = "grc"

##
## Security Group Rules
##
security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.0.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound access to SAP DEV Private Subnets, Shared Service Private Subnets subnets."
  },
  {
    from_port : 25,
    to_port : 25,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.120/32"],
    prefix_ids : [],
    security_groups : [],
    description : "SMTP to internal mail server."
  },
  {
    from_port : 80,
    to_port : 80,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound HTTP Acess to the Internet"
  },
  {
    from_port : 443,
    to_port : 443,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound HTTP Acess to the Internet."
  },
  {
    from_port : 389,
    to_port : 389,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.1/32", "10.51.1.2/32", "10.51.1.3/32"],
    prefix_ids : [],
    security_groups : [],
    description : "LDAP/AD GC"
  },
  {
    from_port : 3268,
    to_port : 3268,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.1/32", "10.51.1.2/32", "10.51.1.3/32"],
    prefix_ids : [],
    security_groups : [],
    description : "LDAP/AD GC"
  },
  {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP to Dev, QA, Prod private subnets and VPN."
  }
]

security_group_ingress_rules = [
  {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12",
    "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev private subnets and VPN."
  },
  {
    from_port : 1128,
    to_port : 1129,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP SUM from VPN."
  },
  {
    from_port : 4237,
    to_port : 4239,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP SWPM from VPN."
  },
  {
    from_port : 8200,
    to_port : 8200,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP HTTPS port from VPN."
  },
  {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.48/32"],
    prefix_ids : [],
    security_groups : [],
    description : "Commvault CommCell on-premise inbound."
  },
  {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.150.12.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "Commvault Media Agent Shared Service inbound ."
  },
]