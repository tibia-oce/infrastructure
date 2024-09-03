// ssh\main.tf

resource "oci_core_network_security_group" "nsg_ssh" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s_ssh_nsg"
}

resource "oci_core_network_security_group_security_rule" "ssh_ingress" {
  for_each                  = toset(concat([var.my_public_ip_cidr], var.additional_trusted_sources))
  source                    = each.value
  network_security_group_id = oci_core_network_security_group.nsg_ssh.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}
