# Shared Service Zone

## Remote State
Bootstrap terraforms to setup the remote state in AWS with an S3 bucket and DynamoDB table for locking. The bucket name is built using the namespace, environment, name, etc. 

## Base Infrastructure 
The base infrastructure module will deploy/manage the following: 

- VPC, public subnets (2), private (2) with the provided CIDRs
- Internet and NAT gateways
- Access to the Shared Services Base Infrastructure to retrieve common variables required
- S3 Endpoint - allows VPC traffic to access S3 buckets over a private link network. 
- Registers the VPC with the the Route53 DNS zones
- Registers the VPC with DNS Route53 resolvers 
- Virtual Gateway and Direct Connect association
- Transit Gateway attachment and routes to Shared Service Transit Gateway
- Base SAP security groups Both and ABAP and JAVA systems

## SAP ECC DEV 
Deploys an empty instance ready for the ECC migration to occur. A separate Ansible is run after the initial deployed that provisions the SAP software in preparation for the migration. This module will not destroy any installed software on the system so it can be used to maintain instance settings such as security groups etc. 

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

## SAP GRC 
Deploys an empty instance ready for the GRC migration to occur.  This module will not destroy any installed software on the system so it can be used to maintain instance settings such as security groups etc. 

The Module provides: 
- IAM roles and security groups
- AWS EC2 instance 
- Provisions EBS disk  
- Registers hostname/IP with DNS 

 ## SAP ADS 
Deploys an empty instance ready for the ADS migration to occur. This module will not destroy any installed software on the system so it can be used to maintain instance settings such as security groups etc. 

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

 ## SAP PO  
Deploys an empty instance ready for the PO migration to occur. This module will not destroy any installed software on the system so it can be used to maintain instance settings such as security groups etc. 

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



