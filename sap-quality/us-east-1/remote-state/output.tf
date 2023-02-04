output "state_bucket_name" {
  value       = module.remote_state.state_bucket_name
  description = "State Bucket Name"
}

output "state_bucket_id" {
  value       = module.remote_state.state_bucket_id
  description = "State Bucket id"
}

output "state_bucket_arn" {
  value       = module.remote_state.state_bucket_arn
  description = "State Lock table arn"
}

output "state_lock_table_name" {
  value       = module.remote_state.state_lock_table_name
  description = "State Lock table Name"
}

output "state_lock_table_id" {
  value       = module.remote_state.state_lock_table_id
  description = "State Lock table id"
}

output "state_lock_table_arn" {
  value       = module.remote_state.state_lock_table_arn
  description = "State Lock table arn"
}

output "state_policy_name" {
  value       = module.remote_state.state_policy_name
  description = "State policy name"
}

output "state_policy_id" {
  value       = module.remote_state.state_policy_id
  description = "State policy id"
}

output "state_policy_arn" {
  value       = module.remote_state.state_policy_arn
  description = "State policy arn"
}

