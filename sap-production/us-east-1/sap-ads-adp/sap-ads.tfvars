## Base Settings
region  = "us-east-1"
profile = "terraformer-prod"

## Labels
namespace               = "sapm"
environment             = "prod"
name                    = "sap"
customer                = "CustomerSAPm"
sap_application         = "ADS"
sap_application_version = "ADS - 7.50"
sap_netweaver_version   = "7.50, SP13"
sap_instance_type       = "ASCS, J2EE, DB"
#
base_infra_state_bucket = "sapm-sap-prod-us-east-1-remote-state"
base_infra_state_key    = "sap-prod/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/sap-prod/keypairs/sapm-sap-prod-us-east-1"

hostname       = "adsprod"
sap_sid        = "ADP"
sap_sysnr      = "00"
sap_ascs_sysnr = "01"

##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0"
ec2_instance_type = "m5.xlarge"
swap_volume_size  = 32
key_name          = "sapm-sap-prod-us-east-1"
ebs_disk_layouts = {
  "sdf" : { "type" : "gp3", "size" : 50, "encrypted" : true, "description" : "sap volume" },
  "sdh" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "db volume" },
  "sdo" : { "type" : "gp3", "size" : 100, "encrypted" : true, "description" : "workspace" },
}

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
    devices : ["/dev/sdh"],
    logical_volumes : [
      { name : "ase", size : "100%FREE", mount : "/sybase/[SID]/", fstype : "xfs" }
    ]
  }
]

block_devices = [
  {
    name : "Software",
    device : "/dev/sdo",
    size : "100%FREE",
    mount : "/sapmnt/sltools",
    fstype : "xfs"

  }
]

security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
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
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22", "10.50.0.0/12", "10.150.12.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from QA private subnets and VPN."
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