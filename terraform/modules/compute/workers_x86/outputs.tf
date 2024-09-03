output "worker_x86_private_ips" {
  value       = [for instance in oci_core_instance.k3s_worker_x86 : instance.private_ip]
  description = "Private IPs of the x86 worker instances."
}

output "worker_x86_public_ips" {
  value       = [for instance in oci_core_instance.k3s_worker_x86 : instance.public_ip]
  description = "Public IPs of the x86 worker instances."
}

output "worker_x86_instance_ids" {
  value       = [for instance in oci_core_instance.k3s_worker_x86 : instance.id]
  description = "Instance IDs of the x86 worker instances."
}
