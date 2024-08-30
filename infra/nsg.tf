// infra\nsg.tf

resource "oci_core_network_security_group" "public_lb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "Public Load Balancer NSG"
}

resource "oci_core_network_security_group" "lb_to_instances_http" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "Public LB to K3s Workers Compute Instances NSG"
}

resource "oci_core_network_security_group" "lb_to_instances_kubeapi" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k3s_vcn.id
  display_name   = "Public LB to K3s Master Compute Instances NSG (kubeapi)"
}

# Public load balancer nsg rules
resource "oci_core_network_security_group_security_rule" "allow_http_from_all" {
  network_security_group_id = oci_core_network_security_group.public_lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTP from all"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.http_lb_port
      min = var.http_lb_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_https_from_all" {
  network_security_group_id = oci_core_network_security_group.public_lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTPS from all"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.https_lb_port
      min = var.https_lb_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_from_my_ip" {
  count                     = var.expose_kubeapi ? 1 : 0
  network_security_group_id = oci_core_network_security_group.public_lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow KubeAPI access from my IP"

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

# Load Balancer to Instances Security Rules
resource "oci_core_network_security_group_security_rule" "nsg_to_instances_http" {
  network_security_group_id = oci_core_network_security_group.lb_to_instances_http.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTP traffic from Public LB NSG to K3s Workers"

  source      = oci_core_network_security_group.public_lb_nsg.id
  source_type = "NETWORK_SECURITY_GROUP"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.http_lb_port
      min = var.http_lb_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_to_instances_https" {
  network_security_group_id = oci_core_network_security_group.lb_to_instances_http.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow HTTPS traffic from Public LB NSG to K3s Workers"

  source      = oci_core_network_security_group.public_lb_nsg.id
  source_type = "NETWORK_SECURITY_GROUP"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.https_lb_port
      min = var.https_lb_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nsg_to_instances_kubeapi" {
  count                     = var.expose_kubeapi ? 1 : 0
  network_security_group_id = oci_core_network_security_group.lb_to_instances_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp

  description = "Allow KubeAPI traffic from Public LB NSG to K3s Master"

  source      = oci_core_network_security_group.public_lb_nsg.id
  source_type = "NETWORK_SECURITY_GROUP"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.kube_api_port
      min = var.kube_api_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_from_lb" {
  network_security_group_id = oci_core_network_security_group.lb_to_instances_kubeapi.id
  direction                 = "INGRESS"
  protocol                  = 6 # tcp
  description               = "Allow KubeAPI traffic from the Load Balancer to K3s Master"
  source                    = oci_core_network_security_group.public_lb_nsg.id
  source_type               = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = var.kube_api_port
      min = var.kube_api_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "allow_kubeapi_to_lb" {
  network_security_group_id = oci_core_network_security_group.lb_to_instances_kubeapi.id
  direction                 = "EGRESS"
  protocol                  = 6 # tcp
  description               = "Allow traffic from K3s Master to Load Balancer"
  destination               = oci_core_network_security_group.public_lb_nsg.id
  destination_type          = "NETWORK_SECURITY_GROUP"
  stateless                 = false

  tcp_options {
    destination_port_range {
      max = var.kube_api_port
      min = var.kube_api_port
    }
  }
}
