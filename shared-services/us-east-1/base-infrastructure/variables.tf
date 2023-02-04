
## AWS Setup and Provider Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "shared_credentials_file" {
  description = "AWS Creditentials Location"
  type        = string
  default     = "~/.aws/credentials"
}

variable "profile" {
  description = "AWS Profile"
  type        = string
}

## Module Variables
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

variable "shared_service_assumed_role_bucket_name" {
  description = "Specify the bucket of the assumed role state file."
  type        = string
  default     = "sapm-shared-services-prod-us-east-1-remote-state"
}

variable "shared_service_assumed_role_state_file" {
  description = "Specify the path to the shared service assumed role state file."
  type        = string
  default     = "global/assume_roles/terraform.tfstate"
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

variable "reverse_dns_zone" {
  description = "Reverse default DNS Domain Name for the VPC - Sets in the DHCP OPtion Set"
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
  description = "Target route CIDR for transit gateway"
  type        = string
}

variable "customer_gateways" {
  description = "A map of customer gateways and IPSEC VPN configurations."
  type = map(
    object({
      customer_gateway_ip                  = string
      target_static_route_cidrs            = list(string)
      static_routes_only                   = bool
      tunnel1_ike_versions                 = list(string)
      tunnel1_phase1_dh_group_numbers      = list(number)
      tunnel1_phase1_encryption_algorithms = list(string)
      tunnel1_phase1_integrity_algorithms  = list(string)
      tunnel1_phase2_dh_group_numbers      = list(number)
      tunnel1_phase2_encryption_algorithms = list(string)
      tunnel1_phase2_integrity_algorithms  = list(string)
      tunnel2_ike_versions                 = list(string)
      tunnel2_phase1_dh_group_numbers      = list(number)
      tunnel2_phase1_encryption_algorithms = list(string)
      tunnel2_phase1_integrity_algorithms  = list(string)
      tunnel2_phase2_dh_group_numbers      = list(number)
      tunnel2_phase2_encryption_algorithms = list(string)
      tunnel2_phase2_integrity_algorithms  = list(string)
    })
  )
}

variable "resolver_forward_rules_map" {
  description = "A map of the forward route53 resolver rules with the key being the dns domain name and value a list of the dns servers the serivce the domain name."
  type        = map(any)
}

## EFS Mounts
variable "efs_detail_name" {
  description = "EFS additional Name"
  type        = string
  default     = ""
}

variable "efs_description" {
  description = "EFS description"
  type        = string
  default     = ""
}

variable "efs_access_points" {
  description = "EFS access points"
  type        = map(any)
  default     = {}
}

variable "efs_security_group_cidrs" {
  description = "A list of CIDRS that are allowed access to the EFS file system."
  type        = list(string)
  default     = []
}

variable "efs_security_group_prefix_list_ids" {
  description = "A list of Prefix Lists that are allowed access to the EFS file system."
  type        = list(string)
  default     = []
}

## Shared Buckets

variable "sap_software_bucket" {
  description = "The bucket name for the SAP Software bucket."
  type        = string
}

variable "sap_migration_data_bucket" {
  description = "The bucket name for the SAP data migation."
  type        = string
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

variable "sap_security_groups" {
  description = "List of a complex map of security rules"
  type        = list(any)
}

variable "sap_j2ee_security_groups" {
  description = "List of a complex map of security rules"
  type        = list(any)
}

