output "nlb_id" {
  value       = oci_network_load_balancer_network_load_balancer.nlb.id
  description = "The ID of the Network Load Balancer."
}

output "nlb_display_name" {
  value       = oci_network_load_balancer_network_load_balancer.nlb.display_name
  description = "The display name of the Network Load Balancer."
}
