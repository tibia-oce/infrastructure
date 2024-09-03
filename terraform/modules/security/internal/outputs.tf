output "internal_security_list_id" {
  value       = oci_core_security_list.internal_security_list.id
  description = "The ID of the Internal Security List."
}
