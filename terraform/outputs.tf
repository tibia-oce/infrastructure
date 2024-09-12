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

output "web_domain" {
  description = "The web application domain managed by Cloudflare"
  value       = module.domain.web_domain
}

output "game_domain" {
  description = "The game server domain managed by Cloudflare"
  value       = module.domain.game_domain
}

output "k3s_token" {
  value     = trimspace(data.hcp_vault_secrets_secret.k3s_token.secret_value)
  sensitive = true
}

# output "oracle_bgp_address" {
#   value = module.network.oracle_bgp_address
# }

# output "oracle_bgp_asn" {
#   value = module.network.oracle_bgp_asn
# }

# output "ipsec" {
#   value = module.network.ipsec
# }

# output "oracle_bgp_interface_ip" {
#   description = "Oracle BGP interface IP for the IPsec connection"
#   value       = module.network.oracle_bgp_interface_ip
# }

# output "cpe_bgp_interface_ip" {
#   description = "CPE (Bird) BGP interface IP for the IPsec connection"
#   value       = module.network.cpe_bgp_interface_ip
# }

# output "oracle_bgp_asn" {
#   description = "Oracle BGP ASN for the IPsec connection"
#   value       = module.network.oracle_bgp_asn
# }

# output "cpe_bgp_asn" {
#   description = "CPE (Bird) BGP ASN for the IPsec connection"
#   value       = module.network.cpe_bgp_asn
# }
