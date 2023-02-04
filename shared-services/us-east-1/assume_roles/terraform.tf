terraform {
  required_version = ">= 0.13"
  backend "s3" {
    region         = "us-east-1"
    bucket         = "sapm-shared-services-prod-us-east-1-remote-state"
    key            = "global/assume_roles/terraform.tfstate"
    dynamodb_table = "sapm-shared-services-prod-remote-state-lock"
    encrypt        = "true"
  }
}