## Base Settings
region  = "us-east-1"
profile = "terraformer-prod"

## Labels
namespace               = "sapm"
environment             = "prod"
name                    = "sap"
customer                = "CustomerSAPm"
sap_application         = "ECC"
sap_application_version = "ECC6 EHP7"
sap_netweaver_version   = "7.52, SP08"
sap_instance_type       = "ASCS, DIALOG, DB"
sap_type                = "ABAP"
#
base_infra_state_bucket = "sapm-sap-prod-us-east-1-remote-state"
base_infra_state_key    = "sap-prod/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/sap-prod/keypairs/sapm-sap-prod-us-east-1"

hostname       = "eccprod"
sap_sid        = "PRD"
sap_sysnr      = "00"
sap_ascs_sysnr = "01"

##
## Support Huge Pages
## 
#hugepages_size = 26624
hugepages_size = 1

##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0"
ec2_instance_type = "m5.4xlarge"
swap_volume_size  = 64
key_name          = "sapm-sap-prod-us-east-1"
ebs_disk_layouts = {
  "sdf" : { "type" : "gp3", "size" : 50, "encrypted" : true, "description" : "sap volume" },
  "sdh" : { "type" : "gp3", "size" : 35, "encrypted" : true, "description" : "ASE bins volume" },
  "sdi" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE DB Data volume" },
  "sdj" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE DB Data volume" },
  "sdk" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE DB Data volume" },
  "sdl" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE DB Data volume" },
  "sdm" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE DB Data volume" },
  "sdn" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "ASE DB Log volume" },
  "sdo" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "ASE DB Log volume" },
  "sdp" : { "type" : "gp3", "size" : 500, "encrypted" : true, "description" : "SL Tools" },
  "sdq" : { "type" : "gp3", "size" : 800, "encrypted" : true, "description" : "SL Tools - temp " },
  "sdr" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE temp migrations logs" },
  "sds" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE temp migrations logs" },
  "sdt" : { "type" : "gp3", "size" : 200, "encrypted" : true, "description" : "ASE temp migrations logs" },
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
    name : "ase_bin",
    devices : ["/dev/sdh"],
    logical_volumes : [
      { name : "ase", size : "100%FREE", mount : "/sybase/[SID]/", fstype : "xfs" }
    ]
  },
  {
    name : "ase_logs",
    devices : ["/dev/sdn", "/dev/sdo"],
    logical_volumes : [
      { name : "logs", size : "100%FREE", mount : "/sybase/[SID]/saplog_1", fstype : "xfs" }
    ]
  },
  {
    name : "ase_logs_mig",
    devices : ["/dev/sdr", "/dev/sds", "/dev/sdt"],
    logical_volumes : [
      { name : "logs_mig", size : "100%FREE", mount : "/sybase/[SID]/saplog_2", fstype : "xfs" }
    ]
  },
  {
    name : "ase_data",
    devices : ["/dev/sdi", "/dev/sdj", "/dev/sdk", "/dev/sdl", "/dev/sdm"],
    logical_volumes : [
      { name : "data", size : "100%FREE", mount : "/sybase/[SID]/sapdata_1", fstype : "xfs" }
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
  },
  {
    name : "Temp DB Log",
    device : "/dev/sdq",
    size : "100%FREE",
    mount : "/sapmnt/sltools/sybtemp",
    fstype : "xfs"
  },
]
##
## EFS Details 
##

efs_name = "ecc"
##
## Security Group Rules
##
security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
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
    from_port : 2049,
    to_port : 2049,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "NFS to File Gateway."
  }
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
    cidr_blocks : ["10.150.8.0/22", "10.50.0.0/12", "10.150.12.0/22", "10.25.0.0/13"],
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
    cidr_blocks : ["10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP SWPM from VPN."
  },
  {
    from_port : 8200,
    to_port : 8200,
    protocol : "TCP",
    cidr_blocks : ["10.50.0.0/12", "10.25.0.0/13"],
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
  {
    from_port : 3202,
    to_port : 3202,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22", "10.50.0.0/12", "10.150.12.0/22", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "Shadow instance access - removed after migration."
  },
]