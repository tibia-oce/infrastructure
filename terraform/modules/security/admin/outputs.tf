output "admin_security_list_id" {
  value       = oci_core_security_list.admin_security_list.id
  description = "The ID of the Admin Security List."
}
