## Base Settings
region  = "us-east-1"
profile = "terraformer-shared"

## Labels
namespace               = "sapm"
environment             = "prod"
name                    = "shared-service"
customer                = "CustomerSAPm"
sap_application         = "solman"
sap_application_version = "SolMan 7.2"
sap_netweaver_version   = "7.52"
sap_instance_type       = "ASCS, DIALOG, J2EE, DB"
sap_type                = "ABAP"
#
base_infra_state_bucket = "sapm-shared-services-prod-us-east-1-remote-state"
base_infra_state_key    = "shared-service/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/shared-service-prod/keypairs/sapm-sap-shared-service-us-east-1"

hostname            = "solman"
sap_sid             = "SLM"
sap_sysnr           = "00"
sap_ascs_sysnr      = "01"
sap_j2ee_sysnr      = "02"
sap_j2ee_ascs_sysnr = "03"

##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0"
ec2_instance_type = "m5.2xlarge"
swap_volume_size  = 64
key_name          = "sapm-shared-service-prod-us-east-1"
ebs_disk_layouts = {
  "sdf" : { "type" : "gp3", "size" : 50, "encrypted" : true, "description" : "sap volume" },
  "sdh" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "ASE volume" },
  "sdi" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "ASE volume" },
  "sdj" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "ASE volume" },
  "sdp" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "SL Tools" },
}

ebs_optimized = true

volume_groups = [
  {
    name : "sap",
    devices : ["/dev/sdf"],
    logical_volumes : [
      { name : "usr_sap", size : "30G", mount : "/usr/sap", fstype : "xfs" },
      { name : "sapmnt", size : "100%FREE", mount : "/sapmnt", fstype : "xfs" }
    ]
  },
  {
    name : "ase",
    devices : ["/dev/sdh", "/dev/sdi", "/dev/sdj"],
    logical_volumes : [
      { name : "data", size : "100%FREE", mount : "/sybase", fstype : "xfs" }
    ]
  }

]

block_devices = [
  {
    name : "Software",
    device : "/dev/sdp",
    size : "100%FREE",
    mount : "/sapmnt/sltools",
    fstype : "xfs"

  }
]

##
## Security Group Rules
##
security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound access to SAP QA Private Subnets, Shared Service Private Subnets subnets."
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
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22",
    "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP to Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 4901,
    to_port : 4901,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/25", "10.150.4.0/25", "10.150.8.0/25"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Solman DBA administration of all SAP ASE systems."
  },
  {
    from_port : 50000,
    to_port : 50000,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/25", "10.150.4.0/25", "10.150.8.0/25"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Solman DBA administration of all SAP ASE systems."
  },
  {
    from_port : 50100,
    to_port : 50100,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/25", "10.150.4.0/25", "10.150.8.0/25"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Solman DBA administration of all SAP ASE systems."
  },
]

security_group_ingress_rules = [
  {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22",
    "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12", "10.150.12.0/22", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "SSH office subnets and VPN."
  },
  {
    from_port : 1128,
    to_port : 1129,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP SUM from VPN."
  },
  {
    from_port : 4237,
    to_port : 4239,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP SWPM from VPN."
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
  {
    from_port : 8103,
    to_port : 8103,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/25", "10.150.4.0/25", "10.150.8.0/25"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Solman connection for Diagnostic agents from Dev, QA, Prod subnets."
  },
  {
    from_port : 3303,
    to_port : 3303,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/25", "10.150.4.0/25", "10.150.8.0/25"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP Solman connection for Diagnostic agents from Dev, QA, Prod subnets."
  },
]