variable "profile" {
  description = "AWS Profiles to be used for artifact creation."
  type        = string
}

variable "namespace" {
  description = "Namespace - 'clk' or 'clklab' "
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment - eg. 'sbx', 'dev','qa','prod'"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name"
  type        = string
}

variable "customer" {
  description = "Customer Name - billing tag"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "shared_service_role_arn" {
  description = "An IAM role arn to access the shared service s3 bucket from the current landscape."
  type        = string
}

variable "sap_application" {
  description = "SAP Application being deployed - ie. ECC, S/4, BW, BW/4, CRM, GRC, EP, NW-ABAP."
  type        = string
}

variable "sap_application_version" {
  description = "SAP Application version"
  type        = string
}

variable "sap_netweaver_version" {
  description = "Technical version of the underlying Netweaver stack."
  type        = string
}

variable "key_name" {
  description = "EC2 instance keypair to use."
  type        = string
}

variable "sap_instance_type" {
  description = "Type of SAP instance modes deployed on the host - ASCS, DIALOG"
}
##
##
##

variable "base_infra_state_bucket" {
  description = "SAP Development Base Infrastrucutre state bucket name"
  type        = string
}

variable "base_infra_state_key" {
  description = "SAP Development Base Infrastrucutre state file path"
  type        = string
}

variable "security_group_egress_rules" {
  description = "List of Map rules - Default: Allow everything"
  type        = list(any)
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow everythig to everywhere."
    }
  ]
}

variable "security_group_ingress_rules" {
  description = "List of Map rules - Default: Allow ICMP and SSH"
  type        = list(any)
  default = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow ICMP from everywhere"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow Ping from everywhere"
    }
  ]
}

## Host and SAP Setup 
variable "hostname" {
  description = "Hostname for the instnace, omit the domain name as it will be applied as per the VPC."
  type        = string
}

# SAP 
variable "sap_sid" {
  description = "SAP 3 letter Sysem ID [SID]"
  type        = string
}

variable "sap_sysnr" {
  description = "SAP System Number"
  type        = string
}

variable "sap_ascs_sysnr" {
  description = "SAP ASCS System Number"
  type        = string
}

variable "ec2_ami" {
  description = "AMI for the Instance being created."
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type."
  type        = string
}

# variable "subnet_id" {
#     description = "VPC Subnet ID to deploy the instnace in."
#     type        = string
# }

# variable "enable_enhanced_monitoring" {
#     description = "Enable Enhanced Cloudwatch Monitoring; default: true."
#     type        = bool
#     default     = true
# }

variable "ec2_private_ip" {
  description = "Sets the instances IP address. If not set then a random subnet IP address will be used."
  type        = string
  default     = null
}

# variable "root_volume_type" {
#     description = "Root Volume type - standard, gp2, io1 or io2; default: gp2)."
#     type        = string
#     default     = "gp2"
# }

variable "root_volume_size" {
  description = "Root Volume size; default: 20g."
  type        = string
  default     = "20G"
}

variable "root_volume_encrypted" {
  description = "Enable Root Volume Encryption; default: true."
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "Enable the EBS optimization on the instance if support; default: false"
  type        = bool
  default     = false
}

variable "swap_volume_size" {
  description = "Swap Volume size."
  type        = string
}

variable "ebs_disk_layouts" {
  description = "Map of the additional ebs values to be added."
  type        = map(any)
  default     = { "sdf" : { "type" : "gp2", "size" : 100, "encrypted" : true, "description" : "sap volume" } }
}

variable "efs_name" {
  description = "The name provided to the access point in the shared services account."
  type        = string
  default     = ""
}

variable "additional_security_group_arns" {
  description = "ARNS of any addtional security groups to add to the instance."
  type        = list(any)
  default     = []
}