output "vcn_id" {
  value       = oci_core_vcn.k3s_vcn.id
  description = "The ID of the VCN."
}

output "subnet_id" {
  value       = oci_core_subnet.k3s_subnet.id
  description = "The ID of the subnet."
}

output "security_list_id" {
  value       = oci_core_security_list.k3s_security_list.id
  description = "The ID of the security list associated with the subnet."
}

output "route_table_id" {
  value       = oci_core_route_table.k3s_route_table.id
  description = "The ID of the route table associated with the subnet."
}
