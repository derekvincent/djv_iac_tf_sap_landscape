terraform {
  required_version = ">= 0.13"
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sapm-sap-prod-us-east-1-remote-state"
    key            = "global/s3state/terraform.tfstate"
    dynamodb_table = "sapm-sap-prod-remote-state-lock"
    encrypt        = "true"
  }
}