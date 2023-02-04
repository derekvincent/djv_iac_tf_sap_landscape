# Remote State

This module is used to create inital remote state bucket and lock based on AWS S3/DynamoDB. It should be used as the base for every module in the account/application/region. Other module directories will use the same bucket and lock table with a different set of state files. 

## Instructions

1. Adapt the remote-state.tfvars file 
1. Run `terraform init` to initialize and download the providers and moules 
1. Run `terraform plan -var-file=remote-state.tfvars` to plan the deployment 
1. Run `terraform apply -var-file=remote-state.tfvars` to create the required state resources. This will also create a file called `terraform.tf` that will be used as the default remote state file. **Verify everything is correct**.
1. Run `terraform init` again to detect that the remote state has been setup.
1. Type `yes` to copy the existing local state file to the S3 bucket
1. Use the `terraform.tf` a the template for the rest of the deployment folders changing the key name for each. 

**NOTE:** If you copy the `terrraform.tf` file and do not change the key to another module directory you run the corrupting and destroying this setup. 