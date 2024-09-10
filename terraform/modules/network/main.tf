# ====================================================================
# VCN and Networking Infrastructure for K3s Cluster
# This section defines the core networking infrastructure including
# the Virtual Cloud Network (VCN), subnets, gateways, dynamic routing 
# gateway (DRG), and the route table configuration for the K3s cluster.
# ====================================================================

# Define the Virtual Cloud Network (VCN)
resource "oci_core_vcn" "k3s_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "k3s_vcn"
}

# Define the Subnet within the VCN
resource "oci_core_subnet" "k3s_subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.k3s_vcn.id
  display_name      = "k3s_subnet"
  route_table_id    = oci_core_route_table.k3s_route_table.id
  security_list_ids = var.security_lists
}

# Define the Internet Gateway for external traffic
resource "oci_core_internet_gateway" "k3s_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_internet_gateway"
}

# Define the Dynamic Routing Gateway (DRG) and its attachment to the VCN
resource "oci_core_drg" "k3s_drg" {
  compartment_id = var.compartment_id
  display_name   = "k3s_drg"
}

resource "oci_core_drg_attachment" "k3s_drg_attachment" {
  drg_id = oci_core_drg.k3s_drg.id
  vcn_id = oci_core_vcn.k3s_vcn.id
}

# Define the Route Table for directing traffic through the Internet Gateway and DRG
resource "oci_core_route_table" "k3s_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_route_table"

  # Route all internet-bound traffic via the Internet Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k3s_internet_gateway.id
  }

  # # Route traffic to external networks via the DRG
  # route_rules {
  #   destination       = var.metal_lb_cidr
  #   network_entity_id = oci_core_drg.k3s_drg.id
  # }
}

# # DRG Route Table
# resource "oci_core_drg_route_table" "k3s_drg_route_table" {
#   drg_id        = oci_core_drg.k3s_drg.id
#   display_name  = "k3s_drg_route_table"
# }

# # Create a DRG Route Distribution
# resource "oci_core_drg_route_distribution" "k3s_drg_route_distribution" {
#   drg_id         = oci_core_drg.k3s_drg.id
#   display_name   = "k3s_drg_route_distribution"
#   distribution_type = "IMPORT"
# }

# # Associate the Route Distribution with the DRG Route Table
# resource "oci_core_drg_route_distribution_statement" "k3s_drg_distribution_statement" {
#   drg_route_distribution_id = oci_core_drg_route_distribution.k3s_drg_route_distribution.id
#   priority = 100
#   action = "ACCEPT"

#   match_criteria {
#     match_type    = "MATCH_ALL"
#   }
# }

# # Create the CPE for the MetalLB peer's IP
# resource "oci_core_cpe" "metal_cpe" {
#   compartment_id = var.compartment_id
#   ip_address     = "10.0.1.10"  # MetalLB Speaker (worker node)
#   display_name   = "MetalLB CPE"
# }

# # Create the IPsec connection
# resource "oci_core_ipsec" "metal_ipsec" {
#   compartment_id = var.compartment_id
#   drg_id         = oci_core_drg.k3s_drg.id
#   cpe_id         = oci_core_cpe.metal_cpe.id
#   static_routes  = ["0.0.0.0/0"]  # Define your routing
# }

# # Retrieve IPsec connection tunnel information
# data "oci_core_ipsec_connection_tunnels" "metal_ipsec_tunnels" {
#   ipsec_id = oci_core_ipsec.metal_ipsec.id
# }

# resource "oci_core_ipsec_connection_tunnel_management" "bird_ipsec_tunnel" {
#   ipsec_id  = oci_core_ipsec.bird_ipsec.id
#   tunnel_id = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].id
#   routing   = "BGP"

#   # Correctly access the BGP session information
#   bgp_session_info {
#     customer_bgp_asn      = 64512
#     customer_interface_ip = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].customer_interface_ip
#     oracle_interface_ip   = data.oci_core_ipsec_connection_tunnels.bird_ipsec_tunnels.ip_sec_connection_tunnels[0].bgp_session_info[0].oracle_interface_ip
#   }
# }
