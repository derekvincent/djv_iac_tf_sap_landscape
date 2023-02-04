terraform {
  required_version = ">= 0.13"
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sapm-sap-qa-us-east-1-remote-state"
    key            = "sap-qa/application/sftp/terraform.tfstate"
    dynamodb_table = "sapm-sap-qa-remote-state-lock"
    encrypt        = "true"
  }
}