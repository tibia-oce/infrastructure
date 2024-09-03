output "admin_security_list_id" {
  value       = module.admin_security_list.admin_security_list_id
  description = "The ID of the Admin Security List."
}

output "internal_security_list_id" {
  value       = module.internal_security_list.internal_security_list_id
  description = "The ID of the Internal Security List."
}

output "public_security_list_id" {
  value       = module.public_security_list.public_security_list_id
  description = "The ID of the Public Security List."
}
