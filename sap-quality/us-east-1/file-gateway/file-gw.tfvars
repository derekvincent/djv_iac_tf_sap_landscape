## Base Settings
region  = "us-east-1"
profile = "terraformer-qa"

## This profile to determine the account ID that will be allowed to access
## the buckets from the on-premise file gatway. 
cross_account_profile = "terraformer-prod"

## Labels
namespace   = "sapm"
environment = "qa"
name        = "sap"
customer    = "CustomerSAPm"
sname       = "1"
#
base_infra_state_bucket = "sapm-sap-qa-us-east-1-remote-state"
base_infra_state_key    = "sap-qa/base-infrastructure/terraform.tfstate"
# Shared Service Role
shared_service_role_arn = "arn:aws:iam::482xxx989xxx:role/sapm-shared-service-prod-cross-account-assume-role"

gateway_name = "sapdta-qa"
key_name     = "sapm-sap-dev-us-east-1"
admin_cidrs = ["10.150.0.0/22", "10.150.4.0/22", "10.150.12.0/22",
"10.50.0.0/12", "10.25.0.0/13"]
nfs_cidrs = ["10.150.0.0/22", "10.150.4.0/22"]
dns_cidrs = ["10.150.4.0/22"]

buckets = {
  "int-dev-100" : {
    "environment" : "dev"
    "name" : "interfaces"
    "customer" : "CustomerSAPm"
    "bucket_name" : "010"
    "shares" : {
      "dev-100" : {
        "prefix" : ""
        "client_list" : ["10.150.0.0/22", "10.150.4.0/22"]
        "file_share_name" : "dev-100"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "int-dev-190" : {
    "environment" : "dev"
    "name" : "interfaces"
    "customer" : "Watatynikaneyap"
    "bucket_name" : "090"
    "shares" : {
      "dev-190" : {
        "prefix" : ""
        "client_list" : ["10.150.0.0/22", "10.150.4.0/22"]
        "file_share_name" : "dev-190"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "int-qa-110" : {
    "environment" : "qa"
    "name" : "interfaces"
    "customer" : "CustomerSAPm"
    "bucket_name" : "010"
    "shares" : {
      "qa-110" : {
        "prefix" : ""
        "client_list" : ["10.150.4.0/22", "10.150.4.0/22"]
        "file_share_name" : "qa-110"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "int-qa-999" : {
    "environment" : "qa"
    "name" : "interfaces"
    "customer" : "Watatynikaneyap"
    "bucket_name" : "090"
    "shares" : {
      "qa-999" : {
        "prefix" : ""
        "client_list" : ["10.150.4.0/22"]
        "file_share_name" : "qa-999"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "usr-share-dev" : {
    "environment" : "dev"
    "name" : "sap"
    "customer" : "CustomerSAPm"
    "bucket_name" : "user-share"
    "shares" : {
      "user-share-dev" : {
        "prefix" : ""
        "client_list" : ["10.150.0.0/22"]
        "file_share_name" : "user-share-dev"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  },
  "usr-share-qa" : {
    "environment" : "qa"
    "name" : "sap"
    "customer" : "CustomerSAPm"
    "bucket_name" : "user-share"
    "shares" : {
      "user-share-qa" : {
        "prefix" : ""
        "client_list" : ["10.150.4.0/22"]
        "file_share_name" : "user-share-qa"
        "default_storage_class" : "S3_ONEZONE_IA"
        "group_id" : "1001"
      }
    }
  }
}
