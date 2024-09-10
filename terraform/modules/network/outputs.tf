output "vcn_id" {
  value       = oci_core_vcn.k3s_vcn.id
  description = "The ID of the VCN."
}

output "subnet_id" {
  value       = oci_core_subnet.k3s_subnet.id
  description = "The ID of the subnet."
}

output "route_table_id" {
  value       = oci_core_route_table.k3s_route_table.id
  description = "The ID of the route table associated with the subnet."
}

# # Output the Oracle BGP interface IP for the IPsec tunnel
# output "oracle_bgp_address" {
#   value = try(data.oci_core_ipsec_connection_tunnels.metal_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].oracle_interface_ip, "Not available yet")
# }

# output "oracle_bgp_asn" {
#   value = try(data.oci_core_ipsec_connection_tunnels.metal_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].oracle_bgp_asn, "Not available yet")
# }

# output "ipsec" {
#   value = try(data.oci_core_ipsec_connection_tunnels.metal_ipsec_tunnels)
# }

# output "oracle_bgp_interface_ip" {
#   description = "Oracle BGP interface IP for the IPsec connection"
#   value       = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].oracle_interface_ip
# }

# # Output the CPE (Bird) BGP interface IP for the IPsec tunnel
# output "cpe_bgp_interface_ip" {
#   description = "CPE (Bird) BGP interface IP for the IPsec connection"
#   value       = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].customer_interface_ip
# }

# # Output the Oracle ASN for the IPsec tunnel
# output "oracle_bgp_asn" {
#   description = "Oracle BGP ASN for the IPsec connection"
#   value       = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].oracle_bgp_asn
# }

# # Output the CPE (Bird) ASN for the IPsec tunnel
# output "cpe_bgp_asn" {
#   description = "CPE (Bird) BGP ASN for the IPsec connection"
#   value       = 64512  # Bird ASN is hardcoded
# }
