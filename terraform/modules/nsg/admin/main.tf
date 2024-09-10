// admin\main.tf

resource "oci_core_network_security_group" "nsg_admin" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s_admin_nsg"
}

# Traefik Dashboard
resource "oci_core_network_security_group_security_rule" "traefik_dashboard_ingress" {
  for_each                  = toset(concat([var.my_public_ip_cidr], var.additional_trusted_sources))
  source                    = each.value
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 9000
      max = 9000
    }
  }
}

# Prometheus
resource "oci_core_network_security_group_security_rule" "prometheus_ingress" {
  for_each                  = toset(concat([var.my_public_ip_cidr], var.additional_trusted_sources))
  source                    = each.value
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 9090
      max = 9090
    }
  }
}

# Grafana
resource "oci_core_network_security_group_security_rule" "grafana_ingress" {
  for_each                  = toset(concat([var.my_public_ip_cidr], var.additional_trusted_sources))
  source                    = each.value
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 3000
      max = 3000
    }
  }
}

# Kubernetes Dashboard
resource "oci_core_network_security_group_security_rule" "kubernetes_dashboard_ingress" {
  for_each                  = toset(concat([var.my_public_ip_cidr], var.additional_trusted_sources))
  source                    = each.value
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 8443
      max = 8443
    }
  }
}

# MetalLB
resource "oci_core_network_security_group_security_rule" "metallb_comms" {
  source                    = "0.0.0.0/0"
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 7946
      max = 7946
    }
  }
}

# BGP
resource "oci_core_network_security_group_security_rule" "bgp_comms" {
  source                    = "0.0.0.0/0"
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  
  tcp_options {
    destination_port_range {
      min = 179
      max = 179
    }
  }
}

# Cilium CIDR (Pod-to-pod traffic)
resource "oci_core_network_security_group_security_rule" "cilium_internal_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  description               = "Allow all internal Kubernetes pod traffic"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "10.52.0.0/16"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
}

# CoreDNS CIDR (Service-to-service traffic)
resource "oci_core_network_security_group_security_rule" "coredns_internal_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  description               = "Allow all internal Kubernetes service traffic"
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "10.43.0.0/16"
  source_type               = "CIDR_BLOCK"
  stateless                 = false
}

# Cilium Agent Communication and Metrics (4241, 9091)
resource "oci_core_network_security_group_security_rule" "cilium_agent_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  description               = "Allow Cilium agent communication"
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      min = 4241
      max = 4241
    }
  }
}

resource "oci_core_network_security_group_security_rule" "cilium_metrics_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  description               = "Allow Cilium metrics traffic"
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      min = 9091
      max = 9091
    }
  }
}

# CoreDNS DNS (UDP 53)
resource "oci_core_network_security_group_security_rule" "coredns_dns_ingress" {
  network_security_group_id = oci_core_network_security_group.nsg_admin.id
  description               = "Allow DNS traffic for CoreDNS"
  direction                 = "INGRESS"
  protocol                  = "17" # UDP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"

  udp_options {
    destination_port_range {
      min = 53
      max = 53
    }
  }
}