data "oci_core_public_ips" "existing_ip" {
  compartment_id = var.compartment_ocid
  scope          = "REGION"
}

locals {
  existing_ip = [
    for ip in data.oci_core_public_ips.existing_ip.public_ips :
    ip if ip.display_name == "${var.lb_display_name}-public-ip"
  ]

  reserved_ip_id = length(local.existing_ip) > 0 ? local.existing_ip[0].id : null
  reserved_ip_address = length(local.existing_ip) > 0 ? local.existing_ip[0].ip_address : null
}

resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.lb_display_name}-public-ip"

  # Public IP is managed by the load balancer and should not be modified independently
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cannot destroy public IP managed by load balancer'"
    on_failure = continue
  }
}

resource "oci_load_balancer_load_balancer" "kubeapi_lb" {
  compartment_id             = var.compartment_ocid
  shape                      = var.public_lb_shape
  subnet_ids                 = [oci_core_subnet.k3s_subnet.id]
  network_security_group_ids = [oci_core_network_security_group.public_lb_nsg.id]
  is_private                 = false
  display_name               = "kubeapi-lb"

  reserved_ips {
    id = local.reserved_ip_id
  }

  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

# Backend set for KubeAPI
resource "oci_load_balancer_backend_set" "kubeapi_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.kubeapi_lb.id
  name             = "kubeapi-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = var.kube_api_port
  }
}

# KubeAPI Listener
resource "oci_load_balancer_listener" "kubeapi_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.kubeapi_lb.id
  name                     = "kubeapi-listener"
  protocol                 = "TCP"
  port                     = var.kube_api_port
  default_backend_set_name = oci_load_balancer_backend_set.kubeapi_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.kubeapi_backend_set]
}

# Backends for KubeAPI (control plane nodes)
resource "oci_load_balancer_backend" "kubeapi_backend" {
  count            = length(oci_core_instance.k3s_control_plane.*.private_ip) # Number of control plane nodes
  backendset_name  = oci_load_balancer_backend_set.kubeapi_backend_set.name
  ip_address       = element(oci_core_instance.k3s_control_plane.*.private_ip, count.index) # IP of the control plane nodes
  load_balancer_id = oci_load_balancer_load_balancer.kubeapi_lb.id
  port             = var.kube_api_port
}
