# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
  cidr_block     = var.vcn_cidr_block
}

# Subnet for the Network Load Balancer
resource "oci_core_subnet" "nlb_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.subnet_display_name
  cidr_block     = var.subnet_cidr_block
  availability_domain = var.availability_domain
  security_list_ids = [oci_core_security_list.default_security_list.id]
  route_table_id     = oci_core_route_table.default_route_table.id
}

# Default Security List for the Subnet
resource "oci_core_security_list" "default_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "default-security-list"

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "1" # ICMP
    source = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

# Default Route Table for the Subnet
resource "oci_core_route_table" "default_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "default-route-table"

  route_rules {
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Internet Gateway for the VCN
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "internet-gateway"
}

# Network Load Balancer
resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_ocid
  display_name   = var.display_name
  subnet_id      = oci_core_subnet.nlb_subnet.id
  is_private     = var.is_private
  nlb_ip_version = "IPV4"
}

# KubeAPI Backend Set
resource "oci_network_load_balancer_backend_set" "kubeapi_backend_set" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  name                     = "kubeapi-backend-set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol          = "TCP"
    port              = 6443
    retries           = 3
    interval_in_millis = 10000
    timeout_in_millis = 3000
  }

  is_preserve_source = true
}

# SSH Backend Set
resource "oci_network_load_balancer_backend_set" "ssh_backend_set" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  name                     = "ssh-backend-set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol          = "TCP"
    port              = 22
    retries           = 3
    interval_in_millis = 10000
    timeout_in_millis = 3000
  }

  is_preserve_source = true
}

# KubeAPI Backend
resource "oci_network_load_balancer_backend" "kubeapi_backend" {
  count = length(var.control_plane_private_ips)

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.kubeapi_backend_set.name
  ip_address               = element(var.control_plane_private_ips, count.index)
  port                     = 6443
  weight                   = 1
}

# SSH Backend
resource "oci_network_load_balancer_backend" "ssh_backend" {
  count = length(var.control_plane_private_ips)

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.ssh_backend_set.name
  ip_address               = element(var.control_plane_private_ips, count.index)
  port                     = 22
  weight                   = 1
}

# KubeAPI Listener
resource "oci_network_load_balancer_listener" "kubeapi_listener" {
  network_load_balancer_id  = oci_network_load_balancer_network_load_balancer.nlb.id
  name                      = "kubeapi-listener"
  protocol                  = "TCP"
  port                      = 6443
  default_backend_set_name  = oci_network_load_balancer_backend_set.kubeapi_backend_set.name
}

# SSH Listener
resource "oci_network_load_balancer_listener" "ssh_listener" {
  network_load_balancer_id  = oci_network_load_balancer_network_load_balancer.nlb.id
  name                      = "ssh-listener"
  protocol                  = "TCP"
  port                      = 22
  default_backend_set_name  = oci_network_load_balancer_backend_set.ssh_backend_set.name
}

# Network Security Group for the NLB
resource "oci_core_network_security_group" "nlb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nlb_nsg"
}

resource "oci_core_network_security_group_security_rule" "kubeapi_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id

  direction = "INGRESS"
  protocol  = "6" # TCP

  source      = var.my_public_ip_cidr
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }

  stateless = false
  description = "Allow KubeAPI traffic from local IP"
}

resource "oci_core_network_security_group_security_rule" "ssh_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id

  direction = "INGRESS"
  protocol  = "6" # TCP

  source      = var.my_public_ip_cidr
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }

  stateless = false
  description = "Allow SSH traffic from local IP"
}

resource "oci_core_network_security_group_security_rule" "internal_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id

  direction = "INGRESS"
  protocol  = "6" # TCP

  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }

  stateless = false
  description = "Allow internal traffic from subnet"
}

resource "oci_core_network_security_group_security_rule" "egress_rule" {
  network_security_group_id = oci_core_network_security_group.nlb_nsg.id

  direction = "EGRESS"
  protocol  = "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"

  stateless = false
  description = "Allow all outbound traffic"
}
