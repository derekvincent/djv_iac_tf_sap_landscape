output "admin_policy_arn" {
  value = join("", aws_iam_policy.commvault-admin-policy.*.arn)
}

output "admin_policy_id" {
  value = join("", aws_iam_policy.commvault-admin-policy.*.id)
}

output "admin_policy_name" {
  value = join("", aws_iam_policy.commvault-admin-policy.*.name)
}