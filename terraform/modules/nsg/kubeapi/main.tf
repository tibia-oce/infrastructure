// kubeapi\main.tf

resource "oci_core_network_security_group" "nsg_kubeapi" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s_kubeapi_nsg"
}

resource "oci_core_network_security_group_security_rule" "kubeapi_private_ingress" {
  description               = "Allow KubeAPI ingress traffic from nodes on port 6443"
  for_each                  = var.all_private_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  
  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "kubeapi_private_egress" {
  description               = "Allow KubeAPI egress traffic from nodes on port 6443"
  for_each                  = var.all_private_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination               = oci_core_network_security_group.nsg_kubeapi.id
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}


resource "oci_core_network_security_group_security_rule" "kubeapi_ingress" {
  description               = "Allow KubeAPI ingress traffic from nodes on port 6443"
  for_each                  = var.all_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  stateless                 = false
  
  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "kubeapi_egress" {
  description               = "Allow KubeAPI egress traffic from nodes on port 6443"
  for_each                  = var.all_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination               = oci_core_network_security_group.nsg_kubeapi.id
  destination_type          = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_from_my_ip" {
  description = "Allow KubeAPI access from whitelisted IPs"
  count                     = var.expose_kubeapi ? 1 : 0
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = 6 # TCP


  source      = var.my_public_ip_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.kube_api_port
      min = var.kube_api_port
    }
  }
}
