output "control_plane_ips" {
  description = "A list of public IP addresses for all control plane nodes."
  value       = oci_core_instance.k3s_control_plane[*].public_ip
}

output "worker_ips" {
  description = "A list of public IP addresses for all worker nodes (ARM and x86)."
  value = concat(
    [for instance in oci_core_instance.k3s_worker_arm : instance.public_ip],
    [for instance in oci_core_instance.k3s_worker_x86 : instance.public_ip]
  )
}
