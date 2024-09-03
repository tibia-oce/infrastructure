output "control_plane_private_ips" {
  description = "Private IPs of the control plane instances."
  value       = module.control_plane.control_plane_private_ips
}

output "control_plane_public_ips" {
  description = "Public IPs of the control plane instances."
  value       = module.control_plane.control_plane_public_ips
}


output "worker_public_ips" {
  description = "A list of public IP addresses for all worker nodes (ARM and x86)."
  value = concat(
    module.workers_arm.worker_arm_public_ips,
    module.workers_x86.worker_x86_public_ips
  )
}

output "worker_private_ips" {
  description = "A list of private IP addresses for all worker nodes (ARM and x86)."
  value = concat(
    module.workers_arm.worker_arm_private_ips,
    module.workers_x86.worker_x86_private_ips
  )
}

output "load_balancer_public_ip" {
  value       = module.reserved_ip.reserved_ip_address
  description = "The public IP address of the load balancer."
}

