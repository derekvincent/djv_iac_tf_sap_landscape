## Base Settings
region  = "us-east-1"
profile = "terraformer-prod"

## Labels
namespace               = "sapm"
environment             = "prod"
name                    = "sap"
customer                = "CustomerSAPm"
sap_application         = "BC"
sap_application_version = "4.8HF14"
sap_instance_type       = "OTHER"
#
base_infra_state_bucket = "sapm-sap-prod-us-east-1-remote-state"
base_infra_state_key    = "sap-prod/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/sap-prod/keypairs/sapm-sap-prod-us-east-1"

hostname = "bcprod"

mounts = [
  {
    mount_point : "/interfaces/prod-100",
    source : "sapdta-prod.aws.domain.com:/prod-100"
    options : "_netdev,nofail,nolock,hard"
  },
  {
    mount_point : "/interfaces/prod-999",
    source : "sapdta-prod.aws.domain.com:/prod-999"
    options : "_netdev,nofail,nolock,hard"
  }
]
##
## EC2 Settings
##
ec2_ami           = "ami-0a782e324655d1cc0"
ec2_instance_type = "t3.micro"
key_name          = "sapm-sap-prod-us-east-1"
sapbc_license     = "TR3ATP2 EBY9CPU EDFCVMJ DFRBAAH"
security_group_egress_rules = {
  all_outbound : {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound access to SAP Prod Private Subnets, Shared Service Private Subnets subnets."
  },
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
  nfs : {
    from_port : 2049,
    to_port : 2049,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "NFS to File Gateway."
  },
  sap_gw00 : {
    from_port : 3300,
    to_port : 3300,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "SAP GW 3300 to Prod."
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
  bc_admin : {
    from_port : 5555,
    to_port : 5555,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_groups : [],
    description : "ICMP from Prod private subnets and VPN."
  },
  comcell : {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.48/32"],
    prefix_ids : [],
    security_groups : [],
    description : "Commvault CommCell on-premise inbound."
  },
  commagent : {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.150.12.0/22"],
    prefix_ids : [],
    security_groups : [],
    description : "Commvault Media Agent Shared Service inbound ."
  },
}
