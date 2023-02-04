
output "ami_id" {
  value = module.file_gateway.ami_id
}

output "shares" {
  value = local.file_shares
}

output "bucket_arns" {
  value = local.bucket_arns
}