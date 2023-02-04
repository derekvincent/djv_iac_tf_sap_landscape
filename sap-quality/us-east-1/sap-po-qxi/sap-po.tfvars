## Base Settings
region  = "us-east-1"
profile = "terraformer-qa"

## Labels
namespace               = "sapm"
environment             = "qa"
name                    = "sap"
customer                = "CustomerSAPm"
sap_application         = "PO"
sap_application_version = "PO - 7.50"
sap_netweaver_version   = "7.50, SP13"
sap_instance_type       = "ASCS, J2EE, DB"
#
base_infra_state_bucket = "sapm-sap-qa-us-east-1-remote-state"
base_infra_state_key    = "sap-qa/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/sap-qa/keypairs/sapm-sap-qa-us-east-1"

hostname       = "poqa"
sap_sid        = "QXI"
sap_sysnr      = "00"
sap_ascs_sysnr = "01"

##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0"
ec2_instance_type = "m5.large"
swap_volume_size  = 16
key_name          = "sapm-sap-qa-us-east-1"
ebs_disk_layouts = {
  "sdf" : { "type" : "gp2", "size" : 50, "encrypted" : true, "description" : "sap volume" },
  "sdh" : { "type" : "gp2", "size" : 50, "encrypted" : true, "description" : "db volume" },
  "sdo" : { "type" : "gp2", "size" : 100, "encrypted" : true, "description" : "workspace" },
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

efs_name = "po"

security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.4.0/22", "10.150.12.0/22", "10.50.0.0/12"],
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
  },
  {
    from_port : 2049,
    to_port : 2049,
    protocol : "TCP",
    cidr_blocks : ["10.150.4.0/22"],
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
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.150.4.0/22", "10.50.0.0/12", "10.150.12.0/22"],
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

## PO ALB 
lb_name = "lbxiqas"
lb_ingress_map = {
  https_443 : { from_port : "443", to_port : "443", protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS 443" },
}

lb_egress_map = {}

lb_healthcheck_path      = "/ATAT/"
access_logs_bucket       = "sapm-sap-dev-qa-security-logs"
access_logs_prefix       = "alb/qxi"
access_logs_enabled      = true
target_port              = "50000"
target_protocol          = "HTTP"
lb_forward_rules         = ["/ATAT/", "/ATAT/MSDN", "/ATAT/msdn"]
lb_enable_http           = false
lb_enable_https          = true
listener_certificate_arn = "arn:aws:iam::377xxx808xxx:server-certificate/ORG76046_CERT_20190709_03"