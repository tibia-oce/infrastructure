# ====================================================================
# Resource: Load Balancer
# This resource defines the load balancer for the Kubernetes API 
# server, including its shape, associated subnet, and reserved public IP.
# ====================================================================

resource "oci_load_balancer_load_balancer" "kubeapi_lb" {
  compartment_id             = var.compartment_ocid
  shape                      = var.public_lb_shape
  subnet_ids                 = [var.subnet_id]
  network_security_group_ids = [var.public_lb_nsg_id]
  is_private                 = false
  display_name               = "kubeapi-lb"

  reserved_ips {
    id = var.reserved_ip_id
  }

  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

# ====================================================================
# Resource: Backend Set for KubeAPI
# This resource defines the backend set for the KubeAPI server, 
# using a round-robin load balancing policy and a TCP health check.
# ====================================================================

resource "oci_load_balancer_backend_set" "kubeapi_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.kubeapi_lb.id
  name             = "kubeapi-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = var.kube_api_port
  }
}

# ====================================================================
# Resource: KubeAPI Listener
# This resource defines the listener for the KubeAPI server, 
# associating it with the backend set and configuring it to listen 
# on the specified port using the TCP protocol.
# ====================================================================

resource "oci_load_balancer_listener" "kubeapi_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.kubeapi_lb.id
  name                     = "kubeapi-listener"
  protocol                 = "TCP"
  port                     = var.kube_api_port
  default_backend_set_name = oci_load_balancer_backend_set.kubeapi_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.kubeapi_backend_set]
}

# ====================================================================
# Resource: Backends for KubeAPI (Control Plane Nodes)
# This resource defines the backends for the KubeAPI server, associating 
# each control plane node with the backend set and configuring it to 
# communicate on the specified port.
# ====================================================================

resource "oci_load_balancer_backend" "kubeapi_backend" {
  count            = length(var.control_plane_private_ips)
  backendset_name  = oci_load_balancer_backend_set.kubeapi_backend_set.name
  ip_address       = element(var.control_plane_private_ips, count.index)
  load_balancer_id = oci_load_balancer_load_balancer.kubeapi_lb.id
  port             = var.kube_api_port
}
