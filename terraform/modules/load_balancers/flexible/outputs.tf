output "load_balancer_public_ip" {
  value       = var.reserved_ip_id
  description = "The public IP address of the load balancer."
}
