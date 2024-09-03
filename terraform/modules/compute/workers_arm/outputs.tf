output "worker_arm_private_ips" {
  value       = [for instance in oci_core_instance.k3s_worker_arm : instance.private_ip]
  description = "Private IPs of the ARM worker instances."
}

output "worker_arm_public_ips" {
  value       = [for instance in oci_core_instance.k3s_worker_arm : instance.public_ip]
  description = "Public IPs of the ARM worker instances."
}

output "worker_arm_instance_ids" {
  value       = [for instance in oci_core_instance.k3s_worker_arm : instance.id]
  description = "Instance IDs of the ARM worker instances."
}
