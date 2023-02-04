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

variable "region" {
  description = "Region executing the terraform in."
  type        = string
}

##
##
##

variable "shared_services_remote_state_bucket" {
  description = "The S3 bucket the stores the Shared Services state files"
  type        = string
}

variable "shared_services_bootstrap_key" {
  description = "The key remote state file for the shared services - bootstrap."
  type        = string
}

variable "shared_services_base_infrastructure_key" {
  description = "The key remote state file for the shared services - base infrastructure."
  type        = string
}

variable "account_ids" {
  description = "A list of account id's that need Shared Services assume roles created."
  type        = list(any)
}
