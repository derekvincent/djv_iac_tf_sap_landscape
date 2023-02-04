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

variable "cross_account_profile" {
  description = "AWS Profile that will be used to allows cross acount to the buckets."
  type        = string
}

variable "shared_service_role_arn" {
  description = "An IAM role arn to access the shared service s3 bucket from the current landscape."
  type        = string
}

variable "base_infra_state_bucket" {
  description = "SAP Development Base Infrastrucutre state bucket name"
  type        = string
}

variable "base_infra_state_key" {
  description = "SAP Development Base Infrastrucutre state file path"
  type        = string
}

variable "sname" {
  description = "Specific name used in the nameing/tagging to distiguish multiple object of the same type."
  type        = string
  default     = null
}

variable "ec2_instance_type" {
  description = "The Instance type to deploy the File Gateway on."
  type        = string
  default     = "m5.xlarge"
}

variable "key_name" {
  description = "The name of the SSH key to be used to access the system."
  type        = string
}

variable "cache_volume_size" {
  description = "The cache volume size."
  type        = string
  default     = "150"
}

variable "cache_volume_encrypted" {
  description = "The cache volume encryption."
  type        = bool
  default     = true
}

variable "gateway_name" {
  description = "The gateway hostname."
  type        = string
}

variable "admin_cidrs" {
  description = "CIDRs avalaible for admin access"
  type        = list(any)
}

variable "nfs_cidrs" {
  description = "CIDRs avaliable for NFS client access"
  type        = list(any)
}

variable "dns_cidrs" {
  description = "CIDRS for access to DNS servers."
  type        = list(any)
}

variable "bucket_arns" {
  description = "A list of S3 Bucket arns that the File Gateway has access to."
  type        = list(any)
  default     = []
}

variable "buckets" {
  description = "Complex object with buckets and mount points defined"
  type        = map(any)
}

variable "on_premise_buckets" {
  description = "Map of additional buckets that will be added to a on-premise file gateway and use a lambda function for replication."
  type        = map(any)
}