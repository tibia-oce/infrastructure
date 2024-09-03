# ====================================================================
# Virtual Cloud Network (VCN) Configuration
# This resource defines the VCN for the K3s cluster, including the 
# CIDR block and compartment it resides in.
# ====================================================================

resource "oci_core_vcn" "k3s_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "k3s_vcn"
}

# ====================================================================
# Subnet Configuration
# This resource defines the subnet within the VCN, including CIDR 
# block, route table, and security list associations.
# ====================================================================

resource "oci_core_subnet" "k3s_subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.k3s_vcn.id
  display_name      = "k3s_subnet"
  route_table_id    = oci_core_route_table.k3s_route_table.id
  security_list_ids = var.security_lists
}

# ====================================================================
# Internet Gateway Configuration
# This resource defines the internet gateway to allow external traffic 
# to and from the VCN.
# ====================================================================

resource "oci_core_internet_gateway" "k3s_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_internet_gateway"
}

# ====================================================================
# Route Table Configuration
# This resource defines the route table, including rules that direct 
# traffic to the internet gateway.
# ====================================================================

resource "oci_core_route_table" "k3s_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k3s_internet_gateway.id
  }
}
