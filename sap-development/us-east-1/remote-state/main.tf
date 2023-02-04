
module "remote_state" {
  ## Change to Git source when happy
  source               = "github.com/derekvincent/tf_sap_landingzone?ref=v0.0.1/bootstrap"
  namespace            = var.namespace
  environment          = var.environment
  name                 = var.name
  customer             = var.customer
  region               = var.region
  state_bucket_name    = var.state_bucket_name
  lifecycle_prefix     = var.lifecycle_prefix
  standard_ia_days     = var.standard_ia_days
  glacier_days         = var.glacier_days
  state_table_name     = var.state_table_name
  state_policy_name    = var.state_policy_name
  terraform_state_file = var.terraform_state_file
  terraform_version    = var.terraform_version

}