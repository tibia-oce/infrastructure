# ====================================================================
# Virtual Cloud Network (VCN) Configuration
# This resource defines the VCN for the K3s cluster, including the 
# CIDR block and compartment it resides in.
# ====================================================================

resource "oci_core_vcn" "k3s_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "k3s_vcn"
}

# ====================================================================
# Subnet Configuration
# This resource defines the subnet within the VCN, including CIDR 
# block, route table, and security list associations.
# ====================================================================

resource "oci_core_subnet" "k3s_subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k3s_vcn.id
  display_name      = "k3s_subnet"
  route_table_id    = oci_core_route_table.k3s_route_table.id
  security_list_ids = [oci_core_security_list.k3s_security_list.id]
}

# ====================================================================
# Security List Configuration
# This resource defines the security list associated with the subnet, 
# including ingress and egress rules to control traffic.
# ====================================================================

resource "oci_core_security_list" "k3s_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_security_list"

  egress_security_rules {
    description = "Allow outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all" # TCP
  }

  ingress_security_rules {
    description = "Allow inbound traffic from subnet"
    protocol    = "all"
    source      = "10.0.0.0/24"
  }

  ingress_security_rules {
    description = "Allow ssh traffic"
    source   = var.my_public_ip_cidr
    protocol = "6" # TCP

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.subnet_cidr
  }
  
  ingress_security_rules {
    description = "Allow k3s api traffic"
    source   = "0.0.0.0/0"
    protocol = "6" # TCP

    tcp_options {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }

  ingress_security_rules {
    description = "Allow http traffic"
    source = "0.0.0.0/0"
    protocol    = "6"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "Allow https traffic"
    source = "0.0.0.0/0"
    protocol    = "6"

    tcp_options {
      min = 443
      max = 443
    }
  }

}

# ====================================================================
# Internet Gateway Configuration
# This resource defines the internet gateway to allow external traffic 
# to and from the VCN.
# ====================================================================

resource "oci_core_internet_gateway" "k3s_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_internet_gateway"
}

# ====================================================================
# Route Table Configuration
# This resource defines the route table, including rules that direct 
# traffic to the internet gateway.
# ====================================================================

resource "oci_core_route_table" "k3s_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "k3s_route_table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.k3s_internet_gateway.id
  }
}
