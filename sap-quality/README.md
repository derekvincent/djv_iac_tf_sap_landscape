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

## SAP ECC QAS 
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


 ## SAP ADS ADQ 
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

 ## SAP PO QXI 
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
  - AWS Application Load Balancer with connectivity to the PO system on the specified paths 

## SAP File Gateway
The file gateway module deploys a file gateways instance and sets up the service along with the specified shares. 

The Module provides: 
- EC2 Instance from a standard Storage Gateway AMI
- Setup of a Storage Gateway in the service 
- Creation of supplied buckets to use a share sources
- Registers hostname/IP with DNS 
- File Gateway shares 
- IAM and Security groups

## SAP Business Connector 
The module deploys EC2 instance and deploys an SAP Business Connector service via an ansible. 

This Module provides:
- IAM roles and security groups 
- EC2 Instance 
- Registers hostname/IP with DNS
- Runs ansible that does:
  - Updates and install additional OS software
  - OS configuration (general and SAP specific)
  - Set default mounts in the `/etc/fstab` files, disks and NFS files systems. 
  - Downloads and deploys the SAP Business connector from the provided S3 bucket

## SFTP 
The SFTP module provisions an EC2 instance to use as an external SFTP server that is backed by S3 buckets for storage and interface processing.  

This Module provides:
- IAM roles and security groups 
- EC2 Instance 
- Elastic IP with association 
- Registers hostname/IP with DNS
- Runs shell scripts that:
  - Updates and install additional OS software (S3 Fuse)
  - OS configuration (general and SAP specific)
    - Includes `/etc/ssh/sshd_config` for mapping specific user ID and jailing them to the SFTP folder roots
  - Set default mounts in the `/etc/fstab` files, disks and S3 Fuse files systems. 


## SAP ECC QDR - __NOT IN USE__
This is a copy of the ECC QA file that provisions a Dry Run for test migration testing. 

