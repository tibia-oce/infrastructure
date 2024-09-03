output "reserved_ip_id" {
  value       = oci_core_public_ip.reserved_ip.id
  description = "The ID of the reserved public IP."
}

output "reserved_ip_address" {
  value       = oci_core_public_ip.reserved_ip.ip_address
  description = "The IP address of the reserved public IP."
}
