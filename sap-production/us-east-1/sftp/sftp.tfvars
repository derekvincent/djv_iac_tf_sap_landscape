## Base Settings
region  = "us-east-1"
profile = "terraformer-prod"

## Labels
namespace   = "sapm"
environment = "prod"
name        = "sap"
customer    = "CustomerSAPm"
#
base_infra_state_bucket = "sapm-sap-prod-us-east-1-remote-state"
base_infra_state_key    = "sap-prod/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

## SSM Parameter for ssh key 
ssh_key_parameter = "/sapm/sap-prod/keypairs/sapm-sap-prod-us-east-1"

hostname              = "sftpp"
enable_public_address = true

##
## EC2 Settings
##
ec2_ami = "ami-0742b4e673072066f"

ec2_instance_type = "t3.micro"
key_name          = "sapm-sap-prod-us-east-1"
security_group_egress_rules = {
  all_outbound : {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_groups : [],
    description : "Outbound access to SAP QA Private Subnets, Shared Service Private Subnets subnets."
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
    cidr_blocks : ["0.0.0.0/0", "10.150.8.0/22", "10.50.0.0/12", "10.150.12.0/22", "10.25.0.0/13", ],
    prefix_ids : [],
    security_groups : [],
    description : "SSH from Prod private subnets and VPN."
  },
}

sftp_shares = {
  bankOne : {
    username : "bankOne",
    bucket : "sapm-int-prod-bankOne",
    bucket_prefix : "/bankOne",
    mount : "bankOne"
  },
  ONCall : {
    username : "oncall",
    bucket : "sapm-int-prod-oncall",
    bucket_prefix : "/Inbound"
    mount : "inbound"
  }
}
