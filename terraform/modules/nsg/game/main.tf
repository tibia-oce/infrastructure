// game\main.tf

resource "oci_core_network_security_group" "nsg_game_service" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s_game_service_nsg"
}

resource "oci_core_network_security_group_security_rule" "game_service_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_game_service.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 7171
      max = 7172
    }
  }
}

resource "oci_core_network_security_group_security_rule" "custom_service_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_game_service.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 5000
      max = 8000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_rule" {
  network_security_group_id = oci_core_network_security_group.nsg_game_service.id
  direction                 = "EGRESS"
  protocol                  = "all"  # Allow all protocols
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false
}
