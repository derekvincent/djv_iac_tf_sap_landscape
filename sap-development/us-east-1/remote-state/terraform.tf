terraform {
  required_version = ">= 0.13"
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sapm-sap-dev-us-east-1-remote-state"
    key            = "global/s3state/terraform.tfstate"
    dynamodb_table = "sapm-sap-dev-remote-state-lock"
    encrypt        = "true"
  }
}