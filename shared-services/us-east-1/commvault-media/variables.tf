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

variable "base_infra_state_bucket" {
  description = "Base Infrastrucutre state bucket name"
  type        = string
}

variable "base_infra_state_key" {
  description = "Base Infrastrucutre state file path"
  type        = string
}

variable "key_name" {
  description = "EC2 instance keypair to use."
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

variable "additional_security_groups" {
  description = "List of any addtional security group to apply to the instance."
  type        = list(any)
  default     = []
}

variable "commvault_s3_bucket" {
  description = "Map of buckets to be created to be used as Commvault libraries."
  type        = map(any)
  default     = {}
  ##
  ## Example
  ##
  ## {"<bucket_name>" : {<bucket_option>: <value>, }}
  ## {"commvault_prod_library" : {"enable_versioning": false, }}
}

variable "enable_commvault_admin" {
  description = "Enable the creation of the CommVault Admin Profile; default: true"
  type        = bool
  default     = true
}

variable "hostname" {
  description = "Hostname for the instnace, omit the domain name as it will be applied as per the VPC."
  type        = string
}

variable "instance_count" {
  description = "Number of Commvault Media Agent instance to run in the grid. All balance across avlaible AZ."
  type        = number
  default     = 1
}

variable "instance_name" {
  description = "Desriptive Name for the instance. Used in names, descriptions and tags."
  type        = string
}

variable "ec2_ami" {
  description = "AMI for the Instance being created."
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "EC2 Instance Type."
  type        = string
}

variable "enable_enhanced_monitoring" {
  description = "Enable Enhanced Cloudwatch Monitoring; default: true."
  type        = bool
  default     = true
}

variable "ec2_private_ip" {
  description = "Sets the instances IP address. If not set then a random subnet IP address will be used."
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "Enable the EBS Optimized feature on the instance if supported; default: false"
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Root Volume type - standard, gp2, io1 or io2; default: gp2)."
  type        = string
  default     = "gp2"
}

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

variable "swap_volume_size" {
  description = "Swap Volume size."
  type        = string
}

variable "ebs_disk_layouts" {
  description = "Map of the additional ebs values to be added."
  type        = map(any)
  default     = {}
}
