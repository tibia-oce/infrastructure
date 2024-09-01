output "load_balancer_public_ip" {
  value       = local.reserved_ip_address
  description = "The public IP address of the load balancer."
}

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

# # Only neccessary when using Bastion (or private subnet comms).
# output "worker_private_ips" {
#   description = "A list of private IP addresses for all worker nodes (ARM and x86)."
#   value       = concat(
#     [for instance in oci_core_instance.k3s_worker_arm : instance.private_ip],
#     [for instance in oci_core_instance.k3s_worker_x86 : instance.private_ip]
#   )
# }

# output "control_plane_private_ips" {
#   description = "A list of private IP addresses for all control plane nodes."
#   value       = oci_core_instance.k3s_control_plane[*].private_ip
# }
