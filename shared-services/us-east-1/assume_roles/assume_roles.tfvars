

## Labels
namespace   = "sapm"
environment = "prod"
name        = "shared-service"
customer    = "CustomerSAPm"
region      = "us-east-1"
##
##
##
shared_services_remote_state_bucket     = "sapm-shared-services-prod-us-east-1-remote-state"
shared_services_bootstrap_key           = "global/s3state/terraform.tfstate"
shared_services_base_infrastructure_key = "shared-service/base-infrastructure/terraform.tfstate"

##
##
##
account_ids = ["377xxx808xxx", "823xxx685xxx", "482xxx989xxx"]
