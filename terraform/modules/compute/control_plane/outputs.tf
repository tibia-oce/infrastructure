output "control_plane_instance_ids" {
  value = [for instance in oci_core_instance.k3s_control_plane : instance.id]
  description = "Instance IDs of the control plane instances."
}

output "control_plane_private_ips" {
  value = [for instance in oci_core_instance.k3s_control_plane : instance.private_ip]
  description = "Private IPs of the control plane instances."
}

output "control_plane_public_ips" {
  value = [for instance in oci_core_instance.k3s_control_plane : instance.public_ip]
  description = "Public IPs of the control plane instances."
}
