output "load_balancer_public_ip" {
  value       = oci_core_public_ip.reserved_ip.ip_address
  description = "The public IP address of the load balancer."
}

output "control_plane_ip" {
  description = "The public IP address of the first control plane node."
  value       = element(oci_core_instance.k3s_control_plane.*.public_ip, 0)
}
