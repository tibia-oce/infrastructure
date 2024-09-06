# TODO: Set variables at root for Cilium and CoreDNS
resource "oci_core_security_list" "internal_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "internal_security_list"

  ingress_security_rules {
    description = "Allow all traffic within the subnet"
    source      = var.subnet_cidr
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Allow all traffic within the VCN"
    source      = var.vcn_cidr
    protocol    = "all"
  }

  egress_security_rules {
    description = "Allow all outbound traffic"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # NodePort services
  ingress_security_rules {
    description = "Allow NodePort traffic on ports 30000-32767"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 30000
      max = 32767
    }
  }

  # Cilium CIDR
  ingress_security_rules {
    description = "Allow all pod-to-pod traffic in Cilium CIDR"
    source      = "10.52.0.0/16"
    protocol    = "all"
  }

  egress_security_rules {
    description = "Allow all outbound traffic to VCN CIDR in Cilium CIDR"
    destination = "10.52.0.0/16"
    protocol    = "all"
  }

  # CoreDNS CIDR
  ingress_security_rules {
    description = "Allow all pod-to-pod traffic in CoreDNS CIDR"
    source      = "10.43.0.0/16"
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Allow API server communication on port 443"
    source      = "0.0.0.0/0"
    protocol    = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    description = "Allow all outbound traffic to VCN CIDR in CoreDNS CIDR"
    destination = "10.43.0.0/16"
    protocol    = "all"
  }

  # Allow all traffic within 10.0.0.0/16 network
  ingress_security_rules {
    description = "Allow all traffic from 10.0.0.0/16 network"
    source      = "10.0.0.0/16"
    protocol    = "all"
  }

  egress_security_rules {
    description = "Allow all traffic to 10.0.0.0/16 network"
    destination = "10.0.0.0/16"
    protocol    = "all"
  }

  # Cilium specific ports (health check, agent, metrics)
  ingress_security_rules {
    description = "Allow Cilium health check traffic (port 4240)"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 4240
      max = 4240
    }
  }

  ingress_security_rules {
    description = "Allow Cilium agent communication (port 4241)"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 4241
      max = 4241
    }
  }

  ingress_security_rules {
    description = "Allow Cilium metrics traffic (port 9091)"
    source      = "0.0.0.0/0"
    protocol    = "6" # TCP

    tcp_options {
      min = 9091
      max = 9091
    }
  }

  # CoreDNS DNS traffic
  ingress_security_rules {
    description = "Allow incoming DNS traffic (UDP port 53)"
    source      = "0.0.0.0/0"
    protocol    = "17" # UDP

    udp_options {
      min = 53
      max = 53
    }
  }

  egress_security_rules {
    description = "Allow outgoing DNS traffic (UDP port 53)"
    destination = "0.0.0.0/0"
    protocol    = "17" # UDP

    udp_options {
      min = 53
      max = 53
    }
  }
}
