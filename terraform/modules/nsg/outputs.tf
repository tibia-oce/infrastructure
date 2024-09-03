output "public_lb_nsg_id" {
  value       = oci_core_network_security_group.public_lb_nsg.id
  description = "The ID of the Public Load Balancer NSG."
}

output "lb_to_instances_http_nsg_id" {
  value       = oci_core_network_security_group.lb_to_instances_http.id
  description = "The ID of the NSG for HTTP traffic between LB and instances."
}

output "lb_to_instances_kubeapi_nsg_id" {
  value       = oci_core_network_security_group.lb_to_instances_kubeapi.id
  description = "The ID of the NSG for KubeAPI traffic between LB and instances."
}
