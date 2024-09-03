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
