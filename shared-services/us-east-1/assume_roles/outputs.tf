output "assume_role_name" {
  value = aws_iam_role.cross_account_assume_role.name
}

output "assume_role_id" {
  value = aws_iam_role.cross_account_assume_role.id
}

output "assume_role_arn" {
  value = aws_iam_role.cross_account_assume_role.arn
}

output "sap_buckets_role_name" {
  value = aws_iam_role.cross_account_sap_buckets.name
}

output "sap_buckets_role_id" {
  value = aws_iam_role.cross_account_sap_buckets.id
}

output "sap_buckets_role_arn" {
  value = aws_iam_role.cross_account_sap_buckets.arn
}