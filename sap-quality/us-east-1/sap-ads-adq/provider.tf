provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "aws" {
  alias   = "assumed_shared_service"
  region  = var.region
  profile = var.profile

  assume_role {
    role_arn = var.shared_service_role_arn
  }
}