# Shared Service Zone

## Remote State
Bootstrap terraforms to setup the remote state in AWS with an S3 bucket and DynamoDB table for locking. The bucket name is built using the namespace, environment, name, etc. 

## Assumed Roles
A number of resource need cross account access such as S3 buckets for software and migration data. This module will create the roles and policies and allow access to the provided account numbers. 

It will also provide these roles as an output that can then be leveraged in other modules. Generally every base infrastructure module to minimize cross account Terraform remote state access.
## Base Infrastructure 
The base infrastructure module will deploy/manage the following: 

- VPC, public subnets (2), private (2) with the provided CIDRs
- Internet and NAT gateways
- S3 Endpoint - allows VPC traffic to access S3 buckets over a private link network. 
- Create the Route53 DNS zone, both forward and reverse zones. 
- Virtual Gateway and Direct Connect association
- Transit Gateway with associated route tables 
- Customer Gateways and route/associations to the Transit Gateway, provides IPSec VPN tunnels to clients
- Route53 Resolvers Endpoints to provide in and outbound DNS requests
- Elastic File System setup for SAP Transport Path
- SAP software and migration data S3 buckets
- Base SAP security groups Both and ABAP and JAVA systems

## Commvault 

Deploys the standard AWS AMI as provided by CommVault and provides:
- security group
- IAM role
- S3 buckets used for the backup locations with access policy
- Registers the deployed instances IP and hostname with DNS

## SAP Solution Manager 
Deploys an empty instance ready for the Solution Manager installation which is done manually. This module will not destroy any installed software on the system so it can be used to maintain instance settings such as security groups etc. 

The Module provides: 
- IAM roles and security groups
- AWS EC2 instance 
- Provisions EBS disk  
- Registers hostname/IP with DNS 
- Runs ansible that does:
  - Updates and install additional OS software
  - OS configuration (general and SAP specific)
  - Allocated provisioned disks provided in input (both LVMs and block mounted)
  - Set default mounts in the `/etc/fstab` files, disks and NFS files systems. 

## SAP Router 
Provisions an EC2 instance and loads the SAP router and default configuration. This module provides: 
- IAM and security groups 
- EC2 instance with a user data shell script for OS setup
  - Updates system and installs software packages
  - Copies saprouter files and config files from S3 bucket
  - Installs and setups saprouter
- Elastic IP for internet IP address 
- Registers hostname/IP with DNS



