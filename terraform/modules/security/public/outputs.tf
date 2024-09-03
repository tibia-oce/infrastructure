output "public_security_list_id" {
  value       = oci_core_security_list.public_security_list.id
  description = "The ID of the Public Security List."
}
