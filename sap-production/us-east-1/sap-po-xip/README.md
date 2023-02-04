


```bash
aws iam upload-server-certificate \
	--server-certificate-name ORG76046_CERT_20190709_03 \
	--certificate-body file://ORG76046_CERT_20190709_03.der \
	--private-key file://ORG76046_CERT_20190709_03.key \
	--tags '[{"Key": "Name", "Value": "ORG76046"}, \
		{"Key": "sapm:environment", "Value": "QA"}, \
		{"Key": "sapm:customer", "Value": "CustomerSAPm"}]'
```