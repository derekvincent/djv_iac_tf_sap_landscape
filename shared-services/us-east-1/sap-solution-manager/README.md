


```bash
aws ssm put-parameter --name "/sapm/sap-qa/keypairs/sapm-sap-qa-us-east-1" --type SecureString --description "sapm QA us-east-1 keypair" --value="$(cat ~/Downloads/sapm-sap-qa-us-east-1.pem)" 
```

aws ssm put-parameter --name "/sapm/sap-dev/DEV/master_password" --value "<VALUE>" --type SecureString

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sap_ansible_input"></a> [sap\_ansible\_input](#module\_sap\_ansible\_input) | github.com/derekvincent/tf_sap_modules/sap-ansible-abap | n/a |
| <a name="module_sap_solman"></a> [sap\_solman](#module\_sap\_solman) | github.com/derekvincent/tf_sap_modules/sap-abap | n/a |
| <a name="module_sap_solman_dns_name"></a> [sap\_solman\_dns\_name](#module\_sap\_solman\_dns\_name) | github.com/derekvincent/tf_sap_landingzone | v0.0.1/route53-records |
| <a name="module_sap_solman_reverse_dns_name"></a> [sap\_solman\_reverse\_dns\_name](#module\_sap\_solman\_reverse\_dns\_name) | github.com/derekvincent/tf_sap_landingzone | v0.0.1/route53-records |

## Resources

| Name | Type |
|------|------|
| [null_resource.sap-ansible](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_arns"></a> [additional\_security\_group\_arns](#input\_additional\_security\_group\_arns) | ARNS of any addtional security groups to add to the instance. | `list(any)` | `[]` | no |
| <a name="input_ansible_playbook"></a> [ansible\_playbook](#input\_ansible\_playbook) | Path to the folder where the ansible playbook is stored. | `string` | `"../../../../ansible_sap_deployment/sap-abap-playbook/"` | no |
| <a name="input_base_infra_state_bucket"></a> [base\_infra\_state\_bucket](#input\_base\_infra\_state\_bucket) | SAP Development Base Infrastrucutre state bucket name | `string` | n/a | yes |
| <a name="input_base_infra_state_key"></a> [base\_infra\_state\_key](#input\_base\_infra\_state\_key) | SAP Development Base Infrastrucutre state file path | `string` | n/a | yes |
| <a name="input_block_devices"></a> [block\_devices](#input\_block\_devices) | List of devices that will be created as a simple block device. | <pre>list(object({<br>    name   = string<br>    device = string<br>    size   = string<br>    mount  = string<br>    fstype = string<br>  }))</pre> | `null` | no |
| <a name="input_customer"></a> [customer](#input\_customer) | Customer Name - billing tag | `string` | n/a | yes |
| <a name="input_ebs_disk_layouts"></a> [ebs\_disk\_layouts](#input\_ebs\_disk\_layouts) | Map of the additional ebs values to be added. | `map(any)` | <pre>{<br>  "sdf": {<br>    "description": "sap volume",<br>    "encrypted": true,<br>    "size": 100,<br>    "type": "gp2"<br>  }<br>}</pre> | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | Enable the EBS optimization on the instance if support. | `bool` | `false` | no |
| <a name="input_ec2_ami"></a> [ec2\_ami](#input\_ec2\_ami) | AMI for the Instance being created. | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 Instance Type. | `string` | n/a | yes |
| <a name="input_ec2_private_ip"></a> [ec2\_private\_ip](#input\_ec2\_private\_ip) | Sets the instances IP address. If not set then a random subnet IP address will be used. | `string` | `null` | no |
| <a name="input_efs_name"></a> [efs\_name](#input\_efs\_name) | The name provided to the access point in the shared services account. | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment - eg. 'sbx', 'dev','qa','prod' | `string` | `""` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for the instnace, omit the domain name as it will be applied as per the VPC. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 instance keypair to use. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace - 'clk' or 'clklab' | `string` | `""` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS Profiles to be used for artifact creation. | `string` | n/a | yes |
| <a name="input_reboot_after_patch"></a> [reboot\_after\_patch](#input\_reboot\_after\_patch) | Alow a system reboot the after ansible patching. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_root_volume_encrypted"></a> [root\_volume\_encrypted](#input\_root\_volume\_encrypted) | Enable Root Volume Encryption; default: true. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root Volume size; default: 20g. | `string` | `"20G"` | no |
| <a name="input_sap_application"></a> [sap\_application](#input\_sap\_application) | SAP Application being deployed - ie. ECC, S/4, BW, BW/4, CRM, GRC, EP, NW-ABAP. | `string` | n/a | yes |
| <a name="input_sap_application_version"></a> [sap\_application\_version](#input\_sap\_application\_version) | SAP Application version | `string` | n/a | yes |
| <a name="input_sap_ascs_sysnr"></a> [sap\_ascs\_sysnr](#input\_sap\_ascs\_sysnr) | SAP ASCS System Number | `string` | n/a | yes |
| <a name="input_sap_instance_type"></a> [sap\_instance\_type](#input\_sap\_instance\_type) | Type of SAP instance modes deployed on the host - ASCS, DIALOG | `any` | n/a | yes |
| <a name="input_sap_j2ee_ascs_sysnr"></a> [sap\_j2ee\_ascs\_sysnr](#input\_sap\_j2ee\_ascs\_sysnr) | SAP j2ee ASCS System Number | `string` | n/a | yes |
| <a name="input_sap_j2ee_sysnr"></a> [sap\_j2ee\_sysnr](#input\_sap\_j2ee\_sysnr) | SAP j2ee System Number | `string` | n/a | yes |
| <a name="input_sap_netweaver_version"></a> [sap\_netweaver\_version](#input\_sap\_netweaver\_version) | Technical version of the underlying Netweaver stack. | `string` | n/a | yes |
| <a name="input_sap_sid"></a> [sap\_sid](#input\_sap\_sid) | SAP 3 letter Sysem ID [SID] | `string` | n/a | yes |
| <a name="input_sap_sysnr"></a> [sap\_sysnr](#input\_sap\_sysnr) | SAP System Number | `string` | n/a | yes |
| <a name="input_sap_type"></a> [sap\_type](#input\_sap\_type) | Type of SAP system ABAP, J2EE, etc. | `any` | n/a | yes |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | List of Map rules - Default: Allow everything | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow everythig to everywhere.",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | List of Map rules - Default: Allow ICMP and SSH | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow ICMP from everywhere",<br>    "from_port": -1,<br>    "protocol": "icmp",<br>    "to_port": -1<br>  },<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow Ping from everywhere",<br>    "from_port": 22,<br>    "protocol": "tcp",<br>    "to_port": 22<br>  }<br>]</pre> | no |
| <a name="input_shared_service_role_arn"></a> [shared\_service\_role\_arn](#input\_shared\_service\_role\_arn) | An IAM role arn to access the shared service s3 bucket from the current landscape. | `string` | n/a | yes |
| <a name="input_ssh_key_parameter"></a> [ssh\_key\_parameter](#input\_ssh\_key\_parameter) | The key paramter store that contains the SSH key is to be used to connect to the targets. | `string` | n/a | yes |
| <a name="input_swap_volume_size"></a> [swap\_volume\_size](#input\_swap\_volume\_size) | Swap Volume size. | `string` | n/a | yes |
| <a name="input_volume_groups"></a> [volume\_groups](#input\_volume\_groups) | List of devices and volume groups to be created. | <pre>list(object({<br>    name    = string<br>    devices = list(string)<br>    logical_volumes = list(object({<br>      name   = string<br>      size   = string<br>      mount  = string<br>      fstype = string<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Hostname of the provisioned SAP system. |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The Instance ID of the provisioned system. |
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the provisioned SAP system. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->