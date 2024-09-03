# ====================================================================
# Network Security Group (NSG) for KubeAPI
# This resource defines the NSG specifically for the KubeAPI, 
# which will control ingress and egress traffic for the K3s cluster 
# nodes communicating with the Kubernetes API server.
# ====================================================================

resource "oci_core_network_security_group" "nsg_kubeapi" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "k3s_kubeapi_nsg"
}

# ====================================================================
# KubeAPI Private Ingress Rules
# These rules allow ingress traffic to the KubeAPI server from 
# private nodes on port 6443, ensuring secure communication within 
# the private network.
# ====================================================================

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

# ====================================================================
# KubeAPI Ingress Rules
# These rules allow ingress traffic to the KubeAPI server from 
# all nodes on port 6443, supporting cluster communication.
# ====================================================================

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

# ====================================================================
# KubeAPI Egress Rules
# These rules allow egress traffic from the KubeAPI server to the 
# NSG on port 6443, ensuring that responses can be sent back to 
# the nodes after they communicate with the Kubernetes API server.
# ====================================================================

resource "oci_core_network_security_group_security_rule" "kubeapi_egress" {
  description               = "Allow KubeAPI egress traffic from nodes on port 6443"
  for_each                  = var.all_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination               = oci_core_network_security_group.nsg_kubeapi.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}

# ====================================================================
# KubeAPI Private Egress Rules
# These rules allow egress traffic from the KubeAPI server to the 
# NSG on port 6443, specifically for private nodes, ensuring secure 
# communication within the private network.
# ====================================================================

resource "oci_core_network_security_group_security_rule" "kubeapi_private_egress" {
  description               = "Allow KubeAPI egress traffic from nodes on port 6443"
  for_each                  = var.all_private_instance_ips_map
  source                    = "${each.value}/32"
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination               = oci_core_network_security_group.nsg_kubeapi.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.kube_api_port
      max = var.kube_api_port
    }
  }
}

# ====================================================================
# Allow KubeAPI Access from Whitelisted IPs
# This rule allows ingress traffic from specific IPs (whitelisted) 
# to access the KubeAPI server on port 6443, useful for secure 
# administrative access.
# ====================================================================

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_from_my_ip" {
  description               = "Allow KubeAPI access from whitelisted IPs"
  count                     = var.expose_kubeapi ? 1 : 0
  network_security_group_id = oci_core_network_security_group.nsg_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = 6 # TCP

  source                    = var.my_public_ip_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = var.kube_api_port
      min = var.kube_api_port
    }
  }
}
