resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "public_security_list"

  ingress_security_rules {
    description = "Allow HTTP traffic from the public"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "Allow HTTP traffic from the public"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 8081
      max = 8081
    }
  }

  ingress_security_rules {
    description = "Allow HTTPS traffic from the public"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description = "Allow all outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}
