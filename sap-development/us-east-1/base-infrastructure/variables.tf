
## AWS Setup and Provider Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}


variable "profile" {
  description = "AWS Profile"
  type        = string
}

##
## Shared Service Bucket 
##
variable "shared_service_bucket_name" {
  description = "The Shared Service remote state s3 bucket."
  type        = string
  default     = ""
}

variable "shared_service_base_state_file" {
  description = "Specify the path to the shared service base infrastrucutre state file."
  type        = string
  default     = "shared-service/base-infrastructure/terraform.tfstate"
}

variable "shared_service_assumed_role_state_file" {
  description = "Specify the path to the shared service assumed role state file."
  type        = string
  default     = "global/assume_roles/terraform.tfstate"
}

variable "shared_service_role_arn" {
  description = "An IAM role arn to access the shared service s3 bucket from the current landscape."
  type        = string
}
##
## Module Variables
##
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
  description = "Customer/Client/Project Name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIRD for the VPC"
  type        = string
}

variable "enable_dns_hostname" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_internet_gateway" {
  description = "Enable th creation of an internet gateway for the VPC"
  type        = bool
  default     = true

}

variable "dns_domain_name" {
  description = "Default DNS Domain Name for the VPC - Sets in the DHCP OPtion Set"
  type        = string
}

variable "public_subnets" {
  description = "A list of subnet CIDRs"
  type        = map(any)
}

variable "enable_nat_gateway" {
  description = "Enable th creation of an nat gateway for the first public subnet"
  type        = bool
  default     = true

}

variable "private_subnets" {
  description = "A list of subnet CIDRs"
  type        = map(any)
}

variable "vpc_peering_enabled" {
  description = "Enable VPC perring"
  type        = bool
  default     = false
}

variable "vpc_peering_targets_tags" {
  description = "List of Name tags for the VPC peering targets"
  type        = set(string)
  default     = []
}

variable "base_dns_domain_name" {
  description = "Base Dns domain name for the AWS environment. "
  type        = string
}

variable "target_route_cidr" {
  description = "Target CIDR for routing to transit gateway"
  type        = string
}

variable "target_static_route_cidrs" {
  description = "Target remote Customer Gateway cidrs to route to"
  type        = list(string)
}

variable "sap_security_groups" {
  description = "List of a complex map of security rules"
  type        = list(any)
}

variable "sap_j2ee_security_groups" {
  description = "List of a complex map of security rules"
  type        = list(any)
}

variable "amazon_side_asn" {
  description = "The BGP ASN to assign to the Virtual Private Gateway."
  type        = string
  default     = "64512"
}

variable "dx_gateway_id" {
  description = "The Direct Connect Gateway ID to attach to."
  type        = string
}

variable "dx_gateway_account_id" {
  description = "The Account ID of the Direct Connect Gateway to attach to."
  type        = string
}