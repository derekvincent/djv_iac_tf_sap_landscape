
1. Create SAP Development `VPC` with the following
    1. `Internet Gateway`
    1. `DHCP Option Set`
    1. Default `Network Access Control List`
        - [] NACL is open and needs to allow base rules
    1. Default VPC `route table`
    1. Default VPC `security group`
       - [] Security Group is empty and needs to allow base rules
1. Create 2 Public subnets across 
2 Avaliablity Zones
    1. **Single** public subnet `route table` and default route set to `internet gateway`
    1. `NAT Gateway` with `Elastic IP`
1. Create 2 Private subnets across 2 Avaliability Zones
    1. Single private private subnet `route table` with the default route set to the `NAT Gateway` in the public zone. 


## Generated Artifacts
- 1 x `VPC`
- 4 x `Subnets` (2 Private and 2 Public)
- 3 x `Route Table` (VPC, Private Subnet, Public Subnet)
- 1 x `Internet Gateway`
- 1 x `DHCP Option Set`
- 1 x `Elastic IP` (NAT Gateway)
- 1 x `NAT Gateway`


## TODO 
- [ ] NACL is open and needs to allow base rules
- [ ] NACL is open and needs to allow base rules