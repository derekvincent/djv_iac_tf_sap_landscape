## Base Settings
region  = "us-east-1"
profile = "terraformer-shared"

## Labels
namespace   = "sapm"
environment = "prod"
name        = "shared-service"
customer    = "CustomerSAPm"
hostname    = "cvmedia0"


base_infra_state_bucket = "sapm-shared-services-prod-us-east-1-remote-state"
base_infra_state_key    = "shared-service/base-infrastructure/terraform.tfstate"


enable_commvault_admin = true
commvault_s3_bucket = { "sapm-aws01" : { "enable_versioning" : false, "custom_bucket_name" : true },
  "sapm-aws02" : { "enable_versioning" : false, "custom_bucket_name" : true }
}

##
## EC2 Settings
##
instance_count    = 1
instance_name     = "cv-media-agent"
ec2_instance_type = "r5a.large"
swap_volume_size  = 0
key_name          = "sapm-shared-service-prod-us-east-1"
root_volume_size  = 200

#ebs_disk_layouts = { "sdf" : {"type": "gp2", "size": 100, "encrypted": true, "description": "sap volume"},
#                     "sdh" : {"type": "gp2", "size": 220, "encrypted": true, "description": "db volume"},
#                     "sdo" : {"type": "gp2", "size": 300, "encrypted": true, "description": "workspace"},
#                     "sdm" : {"type": "gp2", "size": 200, "encrypted": true, "description": "Backup"}      
#                   }

##
## Security Group Rules
##
security_group_egress_rules = [
  {
    from_port : 0,
    to_port : 0,
    protocol : "-1",
    cidr_blocks : ["10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_group : null,
    description : "Outbound access to SAP Prod Private Subnets, Shared Service Private Subnets subnets."
  },
  {
    from_port : 80,
    to_port : 80,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_group : null,
    description : "Outbound HTTP Acess to the Internet"
  },
  {
    from_port : 443,
    to_port : 443,
    protocol : "TCP",
    cidr_blocks : ["0.0.0.0/0"],
    prefix_ids : [],
    security_group : null,
    description : "Outbound HTTP Acess to the Internet."
  },
  {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12"],
    prefix_ids : [],
    security_group : null,
    description : "ICMP to Dev, QA, Prod private subnets and VPN."
    }, {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.48/32", "10.52.1.49/32", "10.53.1.49/32", "10.6.1.10/32"],
    prefix_ids : [],
    security_group : null,
    description : "Commvault CommCell on-premise inbound."
  },
]

security_group_ingress_rules = [
  {
    from_port : -1,
    to_port : -1,
    protocol : "ICMP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_group : null,
    description : "ICMP from Dev, QA, Prod private subnets and VPN."
  },
  {
    from_port : 22,
    to_port : 22,
    protocol : "TCP",
    cidr_blocks : ["10.150.8.0/22", "10.50.0.0/12", "10.25.0.0/13"],
    prefix_ids : [],
    security_group : null,
    description : "SSH from Prod private subnets and VPN."
  },
  {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.51.1.48/32", "10.52.1.49/32", "10.53.1.49/32", "10.6.1.10/32"],
    prefix_ids : [],
    security_group : null,
    description : "Commvault CommCell on-premise inbound."
  },
  {
    from_port : 8400,
    to_port : 8403,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22"],
    prefix_ids : [],
    security_group : null,
    description : "Commvault client DEV/QA/Prod/Shared VPC inbound."
  },
  {
    from_port : 8500,
    to_port : 8600,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22"],
    prefix_ids : [],
    security_group : null,
    description : "Commvault client DEV/QA/Prod/Shared VPC inbound."
  },
  {
    from_port : 32768,
    to_port : 65535,
    protocol : "TCP",
    cidr_blocks : ["10.150.0.0/22", "10.150.4.0/22", "10.150.8.0/22", "10.150.12.0/22"],
    prefix_ids : [],
    security_group : null,
    description : "Commvault client DEV/QA/Prod/Shared Dynamic Ports VPC inbound."
  }
]