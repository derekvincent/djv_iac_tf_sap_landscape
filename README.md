# SAP Landing Zone Deployment 

Each environment is structured in a similar fashion, they contain a remote state TF that bootstraps the account and created the S3 Bucket and DynamoDB lock tables. For a net new environment these need to be run first. If the environment is pre-existing: `sap-develoment`, `sap-quality`, `sap-production`, `share-services` are now in the appropriate accounts and region us-east-1. 

After the remote state is established then the base-infrastructure is used to create/maintain the networking and shared services within a VPC/account.  Things like Transit Gateway connection, routing, base security groups, DNS setup, etc. 

After the remote state and base infrastructure have been established then applications workloads can be deployed. 

## General 
### Users Accounts

The following IAM api based users have been created and should be used for deployments: 
- `terraformer-shared` - Shared Services Account
- `terraformer-dev` - Development Account
- `terraformer-qa` - Quality Account
- `terraformer-prod` - Production Account

The user are referenced in the command line options with `--profile` or set in the environment variable `AWS_PROFILE`. 

### Terraform Module structure 
The Terraform modules stored in a directory that follows the following:
- `account/environment` - sap-development
  - `region` - us-east-1
    - `deployment module` - base-infrastructure or sap-ecc-dev

The general structure of the terraform modules are as follows: 
- `terraform.tf` - Contains the information about where to store the remote state file in AWS. This needs to be adjusted for each module to ensure it does not overwrite the state from another module. 
- `provider.tf` - Defines the Terraform providers used such AWS or secondary AWS account for cross account access. 
- `variables.tf` - is a list of all potential input variables that are used in `tfvars` file
- `output.tf` - contains a list of variables that are outputted from the Terraform run and stored state file
- `main.tf` - Contains the bulk of the actual terraform provisions definition
- `*.tf` - any additional Terraform code that is used to breakup the `main.tf` file to make it more readable. 
- `*.tfvars` - a variable file that contains a list of variables and the value to be used in the Terraform

### Remote State
Provides the bootstrap for creating the state file and locking table based on AWS/DynamoDB. In a brand new environment this need to be done first and should be done once. 

### Base Infrastructure
Deploys the base network setup such as VPC's, Subnet, internet and NAT gateways, routing tables, DNS setup, Storage Gateway and VPN. 

## Account/Environments

### Shared Services
The shared services account is used to provide services that are used across the rest of the landscape. Things like Elastic File system used for saptrans, Transit Gateway and VPN,  or Route 53 DNS. Specific information can be [found here](./shared-services/README.md)

### SAP Development
The SAP Development environment used to host the development systems related to the SAP landscape. Specific information can be [found here](./sap-development/README.md)


### SAP Quality
The SAP Quality environment used to host the quality systems related to the SAP landscape. Specific information can be [found here](./sap-quality/README.md)

### SAP Production
The SAP Production environment used to host the production systems related to the SAP landscape. Specific information can be [found here](./sap-production/README.md)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->