resource "oci_core_security_list" "admin_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "admin_security_list"

  ingress_security_rules {
    description = "Allow SSH traffic"
    source      = var.my_public_ip_cidr
    protocol    = "6" # TCP

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Allow K3s API traffic"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }

  egress_security_rules {
    description = "Allow all outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}
