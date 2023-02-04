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
  description = "Customer"
  type        = string
}

## Bucket Inputs 
variable "state_bucket_name" {
  description = "Use this to override the default bucket name <namespace>-<name>-<environment>-terraform-state"
  default     = null
}

variable "lifecycle_prefix" {
  description = "Use this to set the prefix used by the lifecycle policy, if not used then entire bucket is set. Ensure all states are in that prefix."
  default     = null
}

variable "standard_ia_days" {
  description = "Number of days before non current versions are moved to Standard IA. Default: 30"
  default     = 30
}

variable "glacier_days" {
  description = "Number of days before non current versions are moved to Glacier. Default: 90"
  default     = 90
}

variable "state_table_name" {
  default     = null
  description = "Use this to override the default table name <namespace>-<name>-<environment>-remote-state"
}

variable "state_policy_name" {
  default     = null
  description = "Use this to override the default policy name <namespace>-<name>-<environment>-remote-state-policy"
}

variable "terraform_version" {
  type        = string
  default     = "0.13"
  description = "The minimum required terraform version"
}

variable "terraform_state_file" {
  type        = string
  default     = "global/s3state/terraform.tfstate"
  description = "The path to the state file inside the bucket"
}