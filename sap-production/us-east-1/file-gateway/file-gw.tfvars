## Base Settings
region  = "us-east-1"
profile = "terraformer-prod"

## This profile to determine the account ID that will be allowed to access
## the buckets from the on-premise file gatway. 
cross_account_profile = "terraformer-prod"

## Labels
namespace   = "sapm"
environment = "prod"
name        = "sap"
customer    = "CustomerSAPm"
sname       = "1"
#
base_infra_state_bucket = "sapm-sap-prod-us-east-1-remote-state"
base_infra_state_key    = "sap-prod/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

gateway_name = "sapdta-prod"
key_name     = "sapm-sap-prod-us-east-1"
admin_cidrs = ["10.150.8.0/22", "10.150.12.0/22",
"10.50.0.0/12", "10.25.0.0/13"]
nfs_cidrs = ["10.150.8.0/22"]
dns_cidrs = ["10.150.8.0/22"]

buckets = {
  "int-prod-100" : {
    "environment" : "prod"
    "name" : "interfaces"
    "customer" : "CustomerSAPm"
    "bucket_name" : "100"
    "shares" : {
      "prod-100" : {
        "prefix" : ""
        "client_list" : ["10.150.8.0/22"]
        "file_share_name" : "prod-100"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "int-prod-999" : {
    "environment" : "prod"
    "name" : "interfaces"
    "customer" : "CustomerSAPm"
    "bucket_name" : "999"
    "shares" : {
      "prod-999" : {
        "prefix" : ""
        "client_list" : ["10.150.8.0/22"]
        "file_share_name" : "prod-999"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "usr-share-prod" : {
    "environment" : "prod"
    "name" : "sap"
    "customer" : "CustomerSAPm"
    "bucket_name" : "user-share"
    "shares" : {
      "user-share-prod" : {
        "prefix" : ""
        "client_list" : ["10.150.8.0/22"]
        "file_share_name" : "user-share-prod"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
}

## Since we are not using any currently we will pass an empty map
on_premise_buckets = {}